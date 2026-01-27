import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // Refresh user data (if needed manually, but StreamBuilder handles Firestore updates)
  // EditProfileScreen might update Auth display name, but Firestore needs separate update if we want consistency.
  // For now, we just rely on Firestore stream for the UI.

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text("Not Logged In"));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Data from Firestore
          final data = snapshot.data?.data() as Map<String, dynamic>?;

          // Fallbacks usually from Auth if Firestore is empty (e.g. old users)
          final String displayName = data?['name'] ?? user!.displayName ?? 'Voter';
          final String voterId = data?['voterId'] ?? 'Not Set';
          final String email = data?['email'] ?? user!.email ?? '-';
          final String phone = data?['phone'] ?? '-';
          final bool isVerified = data?['isVerified'] ?? false;
          
          // Department and Year are removed as they are not collected yet.
          // If the user adds them to Firestore later, we can show them.
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Card: User Info
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFF00C853),
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'V',
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B1E48),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Voter ID: $voterId',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Edit Profile Button
                      OutlinedButton.icon(
                        onPressed: () async {
                          // Pass current name to edit screen
                          // (Assuming EditScreen updates Auth name, it should also update Firestore if we want consistency)
                          // We will just let it update Auth for now. 
                          // Or better: update EditScreen to update Firestore too.
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                          // Stream will auto-update if Firestore changed. 
                          // If only Auth changed, 'displayName' var (if fallback used) might not update unless we setState.
                          // But we prefer Firestore data 'name'.
                          setState(() {}); 
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text("Edit Profile"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B1E48),
                          side: const BorderSide(color: Colors.grey),
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Middle Card: Voter Details
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Voter Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1E48),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      _buildDetailRow("Email", email),
                      const Divider(height: 30),
                      _buildDetailRow("Phone", phone), // Added Phone instead of Dept
                      const Divider(height: 30),
                      
                      // Verified Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Verified",
                            style: TextStyle(color: Color(0xFF525F7F), fontSize: 15),
                          ),
                          Row(
                            children: [
                              if (isVerified)
                                const Icon(Icons.check, color: Color(0xFF00C853), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                isVerified ? "Verified" : "Pending",
                                style: TextStyle(
                                  color: isVerified ? const Color(0xFF00C853) : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Settings Button
                _buildActionCard(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: 12),

                // Logout Button
                _buildActionCard(
                  icon: Icons.logout,
                  title: "Logout",
                  isDestructive: true,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    // MainScreen StreamBuilder handles nav
                  },
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF525F7F), fontSize: 15),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0B1E48),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0xFFFFEBEE) : const Color(0xFFF5F6FA),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF525F7F),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : const Color(0xFF0B1E48),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
