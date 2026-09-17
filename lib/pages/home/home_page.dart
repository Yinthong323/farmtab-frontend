import 'package:flutter/material.dart';

import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';
import '../sites/sites_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const HomePage({super.key, required this.user, required this.organisation});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      _buildHomePage(),
      SitesPage(user: widget.user, organisation: widget.organisation),
      const NotificationsPage(),
      ProfilePage(user: widget.user, organisation: widget.organisation),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Change the content when a tab is selected.
      body: IndexedStack(index: _currentIndex, children: _pages),

      // This stays permanently at the bottom.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        backgroundColor: Colors.white,

        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Sites'),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // ============================================================
  // HOME PAGE CONTENT
  // ============================================================

  Widget _buildHomePage() {
    final username = widget.user['username'] ?? 'User';
    final organisationName = widget.organisation['name'] ?? 'Organisation';
    final role = widget.organisation['role'] ?? 'STAFF';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text(
            'Welcome, $username! 👋',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Here\'s your farm overview.',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // Organisation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.business)),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Organisation',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          organisationName,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Role: $role',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Farm Overview
          const Text(
            'Farm Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.eco,
                  title: 'Sites',
                  value: '2',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.view_module,
                  title: 'Shelves',
                  value: '8',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Recent Shelves
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Shelves',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                child: const Text('See all'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildRecentShelfCard(
            icon: Icons.eco,
            shelfName: 'Lettuce Shelf 01',
            details: 'Site A • Lettuce',
          ),

          _buildRecentShelfCard(
            icon: Icons.eco,
            shelfName: 'Lettuce Shelf 03',
            details: 'Site B • Lettuce',
          ),

          _buildRecentShelfCard(
            icon: Icons.local_florist,
            shelfName: 'Tomato Shelf 02',
            details: 'Site A • Tomato',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Colors.green),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentShelfCard({
    required IconData icon,
    required String shelfName,
    required String details,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

        leading: CircleAvatar(child: Icon(icon)),

        title: Text(
          shelfName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(details),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: () {
          // Shelf details will be implemented later.
        },
      ),
    );
  }
}
