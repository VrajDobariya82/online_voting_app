import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;
    
    setState(() => isLoading = true);
    try {
      final newName = _nameController.text.trim();
      
      // Update Auth
      await user?.updateDisplayName(newName);
      await user?.reload(); 
      
      // Update Firestore
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'name': newName,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated')),
      );
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _updateProfile,
              child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
