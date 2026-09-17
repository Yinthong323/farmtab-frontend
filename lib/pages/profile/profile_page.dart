import 'package:flutter/material.dart';

import 'organisation_management_page.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const ProfilePage({
    super.key,
    required this.user,
    required this.organisation,
  });

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = user['username'] ?? 'User';
    final email = user['email'] ?? '';
    final organisationName = organisation['name'] ?? 'Organisation';
    final role = organisation['role'] ?? 'STAFF';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // Profile header
            const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),

            const SizedBox(height: 16),

            Text(
              username,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),

            const SizedBox(height: 30),

            // Organisation section
            const Text(
              'Organisation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.business)),
                title: Text(
                  organisationName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Role: $role'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrganisationManagementPage(
                        user: user,
                        organisation: organisation,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Account section
            const Text(
              'Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Account Settings'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Account settings will be implemented later.',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
