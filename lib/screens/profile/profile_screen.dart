import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return const Center(child: Text("Not Logged In"));
        }

        final String displayName = authProvider.displayName;
        final String voterId = authProvider.voterId;
        final String email = authProvider.email;
        final String phone = authProvider.phone;
        final bool isVerified = authProvider.isVerified;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
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
          body: SingleChildScrollView(
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
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
                      _buildDetailRow("Phone", phone.isNotEmpty ? phone : '-'),
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
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Logout", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<AppAuthProvider>().signOut();
                    }
                  },
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
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
