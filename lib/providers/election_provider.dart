import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Global state management for election & voting CRUD operations.
/// Centralizes Firestore operations so screens don't need direct
/// Firestore references for mutations.
class ElectionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  // ---- Election CRUD ----

  /// Create a new election with candidates.
  /// Returns the election document ID on success, or throws on failure.
  Future<String> createElection({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    required bool isPrivate,
    required bool allowOther,
    String? imageUrl,
    required List<Map<String, String>> options, // [{title, desc}, ...]
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'Not logged in';
    if (options.length < 2) throw 'Minimum 2 options required';

    _isBusy = true;
    notifyListeners();

    try {
      final electionRef = _firestore.collection('elections').doc();

      await electionRef.set({
        'title': title,
        'description': description,
        'startTime': Timestamp.fromDate(start),
        'endTime': Timestamp.fromDate(end),
        'isPrivate': isPrivate,
        'allowOther': allowOther,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        'createdBy': user.uid,
        'creatorName': user.displayName ?? 'Unknown',
        'status': 'upcoming',
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (var o in options) {
        await electionRef.collection('candidates').add({
          'name': o['title']?.trim() ?? '',
          'description': o['desc']?.trim() ?? '',
          'emailOrId': null,
          'voteCount': 0,
        });
      }

      _isBusy = false;
      notifyListeners();
      return electionRef.id;
    } catch (e) {
      _isBusy = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Delete an election and its subcollections (candidates, votes).
  Future<void> deleteElection(String electionId) async {
    _isBusy = true;
    notifyListeners();

    try {
      final electionRef = _firestore.collection('elections').doc(electionId);

      // Delete candidates subcollection
      final candidates = await electionRef.collection('candidates').get();
      for (var doc in candidates.docs) {
        await doc.reference.delete();
      }

      // Delete votes subcollection
      final votes = await electionRef.collection('votes').get();
      for (var doc in votes.docs) {
        await doc.reference.delete();
      }

      // Delete election document
      await electionRef.delete();

      _isBusy = false;
      notifyListeners();
    } catch (e) {
      _isBusy = false;
      notifyListeners();
      rethrow;
    }
  }

  // ---- Voting ----

  /// Cast a vote for a candidate in an election.
  /// Returns null on success, or an error string.
  Future<String?> castVote({
    required String electionId,
    required String candidateId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Not logged in';

    try {
      final electionRef = _firestore.collection('elections').doc(electionId);

      // Check if already voted
      final voteDoc = await electionRef.collection('votes').doc(user.uid).get();
      if (voteDoc.exists) {
        return 'already_voted';
      }

      // Transaction: record vote + increment count
      await _firestore.runTransaction((transaction) async {
        transaction.set(electionRef.collection('votes').doc(user.uid), {
          'votedAt': FieldValue.serverTimestamp(),
          'candidateId': candidateId,
        });

        final candRef = electionRef.collection('candidates').doc(candidateId);
        transaction.update(candRef, {
          'voteCount': FieldValue.increment(1),
        });
      });

      return null; // success
    } catch (e) {
      return 'Error voting: $e';
    }
  }

  /// Check if the current user has already voted in an election.
  /// Returns the candidateId if voted, null if not.
  Future<String?> getVotedCandidateId(String electionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final voteDoc = await _firestore
        .collection('elections')
        .doc(electionId)
        .collection('votes')
        .doc(user.uid)
        .get();

    if (voteDoc.exists) {
      return voteDoc.data()?['candidateId'] as String?;
    }
    return null;
  }

  /// Add a custom "Other" candidate option to an election (voter-submitted).
  Future<String?> addOtherOption({
    required String electionId,
    required String optionTitle,
  }) async {
    try {
      final electionRef = _firestore.collection('elections').doc(electionId);
      final docRef = await electionRef.collection('candidates').add({
        'name': optionTitle.trim(),
        'description': 'Voter-submitted option',
        'emailOrId': null,
        'voteCount': 0,
        'isCustom': true,
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }
}
