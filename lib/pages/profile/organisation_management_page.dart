// import 'package:flutter/material.dart';
// import '../../services/organisation_service.dart';
// import '../../services/auth_service.dart';

// class OrganisationManagementPage extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final Map<String, dynamic> organisation;

//   const OrganisationManagementPage({
//     super.key,
//     required this.user,
//     required this.organisation,
//   });

//   @override
//   State<OrganisationManagementPage> createState() =>
//       _OrganisationManagementPageState();
// }

// class _OrganisationManagementPageState
//     extends State<OrganisationManagementPage> {
//   List<dynamic> _members = [];
//   bool _isLoadingMembers = true;
//   List<dynamic> _joinRequests = [];
//   bool _isLoadingRequests = true;

//   @override
//   void initState() {
//     super.initState();

//     _loadMembers();

//     if (widget.organisation['role'] == 'ADMIN') {
//       _loadJoinRequests();
//     }
//   }

//   Future<void> _approveJoinRequest(int userId) async {
//     try {
//       await AuthService.approveJoinRequest(
//         accessToken: widget.user['access_token'],
//         organisationId: widget.organisation['id'],
//         userId: userId,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Join request approved.')));

//       await _loadJoinRequests();
//       await _loadMembers();
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Unable to approve request: $e')));
//     }
//   }

//   Future<void> _rejectJoinRequest(int userId) async {
//     try {
//       await AuthService.rejectJoinRequest(
//         accessToken: widget.user['access_token'],
//         organisationId: widget.organisation['id'],
//         userId: userId,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Join request rejected.')));

//       await _loadJoinRequests();
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Unable to reject request: $e')));
//     }
//   }

//   Future<void> _loadJoinRequests() async {
//     setState(() {
//       _isLoadingRequests = true;
//     });

//     try {
//       final requests = await AuthService.getJoinRequests(
//         accessToken: widget.user['access_token'],
//         organisationId: widget.organisation['id'],
//       );

//       setState(() {
//         _joinRequests = requests;
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Unable to load join requests: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingRequests = false;
//         });
//       }
//     }
//   }

//   Future<void> _loadMembers() async {
//     try {
//       final members = await AuthService.getOrganisationMembers(
//         accessToken: widget.user['access_token'],
//         organisationId: widget.organisation['id'],
//       );

//       if (!mounted) return;

//       setState(() {
//         _members = members;
//         _isLoadingMembers = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoadingMembers = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Organisation Management'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(icon: Icon(Icons.business), text: 'Organisation'),
//               Tab(icon: Icon(Icons.people), text: 'Members'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [_buildOrganisationTab(), _buildMembersTab()],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrganisationTab() {
//     final role = widget.organisation['role'] ?? 'STAFF';
//     final isAdmin = role == 'ADMIN';

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const Icon(Icons.business, size: 60),

//           const SizedBox(height: 16),

//           Text(
//             widget.organisation['name'] ?? 'Organisation',
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 30),

//           _buildInfoCard(
//             title: 'Description',
//             value: widget.organisation['description'] ?? 'No description',
//           ),

//           _buildInfoCard(
//             title: 'Website',
//             value: widget.organisation['website'] ?? 'Not provided',
//           ),

//           _buildInfoCard(
//             title: 'Phone',
//             value: widget.organisation['phone_number'] ?? 'Not provided',
//           ),

//           _buildInfoCard(
//             title: 'Organisation Type',
//             value: widget.organisation['organisation_type'] ?? 'Unknown',
//           ),

//           const SizedBox(height: 20),

//           const Text(
//             'Farm Information',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 12),

//           Row(
//             children: [
//               Expanded(
//                 child: _buildPlaceholderCard(
//                   icon: Icons.location_on,
//                   title: 'Sites',
//                   value: '--',
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildPlaceholderCard(
//                   icon: Icons.view_module,
//                   title: 'Shelves',
//                   value: '--',
//                 ),
//               ),
//             ],
//           ),

//           if (isAdmin) ...[
//             const SizedBox(height: 20),

//             ElevatedButton.icon(
//               onPressed: _editOrganisation,
//               icon: const Icon(Icons.edit),
//               label: const Text('Edit Organisation'),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Future<void> _editOrganisation() async {
//     final nameController = TextEditingController(
//       text: widget.organisation['name'] ?? '',
//     );

//     final descriptionController = TextEditingController(
//       text: widget.organisation['description'] ?? '',
//     );

//     final websiteController = TextEditingController(
//       text: widget.organisation['website'] ?? '',
//     );

//     final phoneController = TextEditingController(
//       text: widget.organisation['phone_number'] ?? '',
//     );

//     final organisationType =
//         widget.organisation['organisation_type'] ?? 'Unknown';

//     final formKey = GlobalKey<FormState>();

//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Edit Organisation'),
//           content: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Organisation Name',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Organisation name is required.';
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 16),

//                   TextFormField(
//                     controller: descriptionController,
//                     maxLines: 3,
//                     decoration: const InputDecoration(
//                       labelText: 'Description',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Description is required.';
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 16),

//                   TextFormField(
//                     controller: websiteController,
//                     decoration: const InputDecoration(
//                       labelText: 'Website',
//                       hintText: 'https://example.com',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   TextFormField(
//                     controller: phoneController,
//                     decoration: const InputDecoration(
//                       labelText: 'Phone Number',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   DropdownButtonFormField<String>(
//                     value: organisationType,
//                     decoration: const InputDecoration(
//                       labelText: 'Organisation Type',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: [
//                       DropdownMenuItem(
//                         value: organisationType,
//                         child: Text(organisationType),
//                       ),
//                     ],
//                     onChanged: null,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text('Cancel'),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 if (formKey.currentState!.validate()) {
//                   Navigator.pop(context, true);
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );

//     if (result != true) {
//       return;
//     }

//     await _updateOrganisation(
//       name: nameController.text.trim(),
//       description: descriptionController.text.trim(),
//       website: websiteController.text.trim(),
//       phoneNumber: phoneController.text.trim(),
//       organisationType: organisationType,
//     );

//     nameController.dispose();
//     descriptionController.dispose();
//     websiteController.dispose();
//     phoneController.dispose();
//   }

//   Future<void> _updateOrganisation({
//     required String name,
//     required String description,
//     required String website,
//     required String phoneNumber,
//     required String organisationType,
//   }) async {
//     try {
//       final updatedOrganisation = await AuthService.updateOrganisation(
//         accessToken: widget.user['access_token'],
//         organisationId: widget.organisation['id'],
//         name: name,
//         description: description,
//         website: website.isEmpty ? null : website,
//         phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
//         organisationType: organisationType,
//       );

//       if (!mounted) return;

//       setState(() {
//         widget.organisation['name'] = updatedOrganisation['organisation_name'];

//         widget.organisation['description'] = updatedOrganisation['description'];

//         widget.organisation['website'] = updatedOrganisation['website'];

//         widget.organisation['phone_number'] =
//             updatedOrganisation['phone_number'];

//         widget.organisation['organisation_type'] =
//             updatedOrganisation['organisation_type'];
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Organisation updated successfully.')),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Unable to update organisation: $e')),
//       );
//     }
//   }

//   Widget _buildMembersTab() {
//     final admins = _members
//         .where((member) => member['role'] == 'ADMIN')
//         .toList();

//     final staff = _members
//         .where((member) => member['role'] == 'STAFF')
//         .toList();

//     return RefreshIndicator(
//       onRefresh: () async {
//         await _loadMembers();

//         // Only Admins are allowed to load join requests.
//         if (widget.organisation['role'] == 'ADMIN') {
//           await _loadJoinRequests();
//         }
//       },
//       child: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           // =====================================================
//           // EXISTING MEMBERS
//           // =====================================================

//           if (_isLoadingMembers)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           else ...[
//             if (admins.isNotEmpty) ...[
//               const Text(
//                 'Administrators',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 12),

//               ...admins.map(_buildMemberCard),

//               const SizedBox(height: 24),
//             ],

//             if (staff.isNotEmpty) ...[
//               const Text(
//                 'Staff',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 12),

//               ...staff.map(_buildMemberCard),

//               const SizedBox(height: 24),
//             ],

//             if (admins.isEmpty && staff.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 20),
//                 child: Center(
//                   child: Text(
//                     'No members found.',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ),
//           ],

//           // =====================================================
//           // JOIN REQUESTS
//           // =====================================================
//           if (widget.organisation['role'] == 'ADMIN') ...[
//             const Divider(height: 40),

//             const Text(
//               'Join Requests',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 12),

//             if (_isLoadingRequests)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: CircularProgressIndicator(),
//                 ),
//               )
//             else if (_joinRequests.isEmpty)
//               const Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     'No pending join requests.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               )
//             else
//               ..._joinRequests.map((request) => _buildJoinRequestCard(request)),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildMemberCard(dynamic member) {
//     final isAdmin = member['role'] == 'ADMIN';
//     final isCurrentUser = member['user_id'] == widget.user['id'];

//     final isOrganisationAdmin = widget.organisation['role'] == 'ADMIN';

//     return Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person),
//         ),

//         title: Text(
//           member['username'] ?? 'Unknown user',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),

//         subtitle: Text(member['email'] ?? ''),

//         trailing: isOrganisationAdmin && !isCurrentUser
//             ? PopupMenuButton<String>(
//                 onSelected: (value) {
//                   if (value == 'role') {
//                     _confirmChangeRole(member);
//                   } else if (value == 'remove') {
//                     _confirmRemoveMember(member);
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     value: 'role',
//                     child: Row(
//                       children: [
//                         Icon(
//                           isAdmin ? Icons.person : Icons.admin_panel_settings,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(isAdmin ? 'Make Staff' : 'Make Admin'),
//                       ],
//                     ),
//                   ),

//                   const PopupMenuItem(
//                     value: 'remove',
//                     child: Row(
//                       children: [
//                         Icon(Icons.person_remove),
//                         SizedBox(width: 8),
//                         Text('Remove Member'),
//                       ],
//                     ),
//                   ),
//                 ],
//               )
//             : Text(
//                 member['role'] ?? 'STAFF',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//       ),
//     );
//   }

//   Future<void> _confirmChangeRole(dynamic member) async {
//     final isAdmin = member['role'] == 'ADMIN';

//     final newRole = isAdmin ? 'STAFF' : 'ADMIN';

//     final actionText = isAdmin
//         ? 'change this member to Staff'
//         : 'make this member an Admin';

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(isAdmin ? 'Change Role' : 'Make Admin'),
//           content: Text('Are you sure you want to $actionText?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) {
//       return;
//     }

//     await _changeMemberRole(member['user_id'], newRole);
//   }

//   Future<void> _changeMemberRole(int userId, String newRole) async {
//     try {
//       await AuthService.changeMemberRole(
//         accessToken: widget.user['access_token'],
//         organisationId: widget.organisation['id'],
//         userId: userId,
//         newRole: newRole,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             newRole == 'ADMIN'
//                 ? 'Member is now an Admin.'
//                 : 'Member is now Staff.',
//           ),
//         ),
//       );

//       await _loadMembers();
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Unable to change member role: $e')),
//       );
//     }
//   }

//   Future<void> _confirmRemoveMember(dynamic member) async {
//     final username = member['username'] ?? 'this member';

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Remove Member'),
//           content: Text(
//             'Are you sure you want to remove $username from this organisation?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               child: const Text('Remove'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) {
//       return;
//     }

//     await _removeMember(member['user_id']);
//   }

//   Future<void> _removeMember(int userId) async {
//     try {
//       await AuthService.removeMember(
//         accessToken: widget.user['access_token'],
//         organisationId: widget.organisation['id'],
//         userId: userId,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Member removed successfully.')),
//       );

//       await _loadMembers();
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Unable to remove member: $e')));
//     }
//   }

//   Widget _buildInfoCard({required String title, required String value}) {
//     return Card(
//       child: ListTile(
//         title: Text(
//           title,
//           style: const TextStyle(fontSize: 13, color: Colors.grey),
//         ),
//         subtitle: Text(value, style: const TextStyle(fontSize: 16)),
//       ),
//     );
//   }

//   Widget _buildPlaceholderCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Icon(icon, size: 30),
//             const SizedBox(height: 8),
//             Text(title, style: const TextStyle(color: Colors.grey)),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildJoinRequestCard(Map<String, dynamic> request) {
//     final username = request['username'] ?? 'Unknown User';
//     final email = request['email'] ?? '';
//     final userId = request['user_id'];

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               username,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 4),

//             Text(email, style: const TextStyle(color: Colors.grey)),

//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => _rejectJoinRequest(userId),
//                     child: const Text('Reject'),
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _approveJoinRequest(userId),
//                     child: const Text('Approve'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../services/organisation_service.dart';

class OrganisationManagementPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const OrganisationManagementPage({
    super.key,
    required this.user,
    required this.organisation,
  });

  @override
  State<OrganisationManagementPage> createState() =>
      _OrganisationManagementPageState();
}

class _OrganisationManagementPageState
    extends State<OrganisationManagementPage> {
  List<dynamic> _members = [];
  bool _isLoadingMembers = true;
  List<dynamic> _joinRequests = [];
  bool _isLoadingRequests = true;

  @override
  void initState() {
    super.initState();

    _loadMembers();

    if (widget.organisation['role'] == 'ADMIN') {
      _loadJoinRequests();
    }
  }

  Future<void> _approveJoinRequest(int userId) async {
    try {
      await OrganisationService().approveJoinRequest(
        organisationId: widget.organisation['id'],
        userId: userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Join request approved.')));

      await _loadJoinRequests();
      await _loadMembers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to approve request: $e')));
    }
  }

  Future<void> _rejectJoinRequest(int userId) async {
    try {
      await OrganisationService().rejectJoinRequest(
        organisationId: widget.organisation['id'],
        userId: userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Join request rejected.')));

      await _loadJoinRequests();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to reject request: $e')));
    }
  }

  Future<void> _loadJoinRequests() async {
    setState(() {
      _isLoadingRequests = true;
    });

    try {
      final requests = await OrganisationService().getJoinRequests(
        organisationId: widget.organisation['id'],
      );

      setState(() {
        _joinRequests = requests;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load join requests: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRequests = false;
        });
      }
    }
  }

  Future<void> _loadMembers() async {
    try {
      final members = await OrganisationService().getOrganisationMembers(
        organisationId: widget.organisation['id'],
      );

      if (!mounted) return;

      setState(() {
        _members = members;
        _isLoadingMembers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMembers = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Organisation Management'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.business), text: 'Organisation'),
              Tab(icon: Icon(Icons.people), text: 'Members'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildOrganisationTab(), _buildMembersTab()],
        ),
      ),
    );
  }

  Widget _buildOrganisationTab() {
    final role = widget.organisation['role'] ?? 'STAFF';
    final isAdmin = role == 'ADMIN';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.business, size: 60),

          const SizedBox(height: 16),

          Text(
            widget.organisation['name'] ?? 'Organisation',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          _buildInfoCard(
            title: 'Description',
            value: widget.organisation['description'] ?? 'No description',
          ),

          _buildInfoCard(
            title: 'Website',
            value: widget.organisation['website'] ?? 'Not provided',
          ),

          _buildInfoCard(
            title: 'Phone',
            value: widget.organisation['phone_number'] ?? 'Not provided',
          ),

          _buildInfoCard(
            title: 'Organisation Type',
            value: widget.organisation['organisation_type'] ?? 'Unknown',
          ),

          const SizedBox(height: 20),

          const Text(
            'Farm Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildPlaceholderCard(
                  icon: Icons.location_on,
                  title: 'Sites',
                  value: '--',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlaceholderCard(
                  icon: Icons.view_module,
                  title: 'Shelves',
                  value: '--',
                ),
              ),
            ],
          ),

          if (isAdmin) ...[
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _editOrganisation,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Organisation'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editOrganisation() async {
    final nameController = TextEditingController(
      text: widget.organisation['name'] ?? '',
    );

    final descriptionController = TextEditingController(
      text: widget.organisation['description'] ?? '',
    );

    final websiteController = TextEditingController(
      text: widget.organisation['website'] ?? '',
    );

    final phoneController = TextEditingController(
      text: widget.organisation['phone_number'] ?? '',
    );

    final organisationType =
        widget.organisation['organisation_type'] ?? 'Unknown';

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Organisation'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Organisation Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Organisation name is required.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: organisationType,
                    decoration: const InputDecoration(
                      labelText: 'Organisation Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: organisationType,
                        child: Text(organisationType),
                      ),
                    ],
                    onChanged: null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    await _updateOrganisation(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      website: websiteController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      organisationType: organisationType,
    );

    nameController.dispose();
    descriptionController.dispose();
    websiteController.dispose();
    phoneController.dispose();
  }

  Future<void> _updateOrganisation({
    required String name,
    required String description,
    required String website,
    required String phoneNumber,
    required String organisationType,
  }) async {
    try {
      final updatedOrganisation = await OrganisationService()
          .updateOrganisation(
            organisationId: widget.organisation['id'],
            name: name,
            description: description,
            website: website.isEmpty ? null : website,
            phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
            organisationType: organisationType,
          );

      if (!mounted) return;

      setState(() {
        widget.organisation['name'] = updatedOrganisation['organisation_name'];

        widget.organisation['description'] = updatedOrganisation['description'];

        widget.organisation['website'] = updatedOrganisation['website'];

        widget.organisation['phone_number'] =
            updatedOrganisation['phone_number'];

        widget.organisation['organisation_type'] =
            updatedOrganisation['organisation_type'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organisation updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update organisation: $e')),
      );
    }
  }

  Widget _buildMembersTab() {
    final admins = _members
        .where((member) => member['role'] == 'ADMIN')
        .toList();

    final staff = _members
        .where((member) => member['role'] == 'STAFF')
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await _loadMembers();

        // Only Admins are allowed to load join requests.
        if (widget.organisation['role'] == 'ADMIN') {
          await _loadJoinRequests();
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // =====================================================
          // EXISTING MEMBERS
          // =====================================================

          if (_isLoadingMembers)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            if (admins.isNotEmpty) ...[
              const Text(
                'Administrators',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              ...admins.map(_buildMemberCard),

              const SizedBox(height: 24),
            ],

            if (staff.isNotEmpty) ...[
              const Text(
                'Staff',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              ...staff.map(_buildMemberCard),

              const SizedBox(height: 24),
            ],

            if (admins.isEmpty && staff.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No members found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],

          // =====================================================
          // JOIN REQUESTS
          // =====================================================
          if (widget.organisation['role'] == 'ADMIN') ...[
            const Divider(height: 40),

            const Text(
              'Join Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (_isLoadingRequests)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_joinRequests.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No pending join requests.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._joinRequests.map((request) => _buildJoinRequestCard(request)),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberCard(dynamic member) {
    final isAdmin = member['role'] == 'ADMIN';
    final isCurrentUser = member['user_id'] == widget.user['id'];

    final isOrganisationAdmin = widget.organisation['role'] == 'ADMIN';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person),
        ),

        title: Text(
          member['username'] ?? 'Unknown user',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(member['email'] ?? ''),

        trailing: isOrganisationAdmin && !isCurrentUser
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'role') {
                    _confirmChangeRole(member);
                  } else if (value == 'remove') {
                    _confirmRemoveMember(member);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        Icon(
                          isAdmin ? Icons.person : Icons.admin_panel_settings,
                        ),
                        const SizedBox(width: 8),
                        Text(isAdmin ? 'Make Staff' : 'Make Admin'),
                      ],
                    ),
                  ),

                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove),
                        SizedBox(width: 8),
                        Text('Remove Member'),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                member['role'] ?? 'STAFF',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _confirmChangeRole(dynamic member) async {
    final isAdmin = member['role'] == 'ADMIN';

    final newRole = isAdmin ? 'STAFF' : 'ADMIN';

    final actionText = isAdmin
        ? 'change this member to Staff'
        : 'make this member an Admin';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAdmin ? 'Change Role' : 'Make Admin'),
          content: Text('Are you sure you want to $actionText?'),
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
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _changeMemberRole(member['user_id'], newRole);
  }

  Future<void> _changeMemberRole(int userId, String newRole) async {
    try {
      await OrganisationService().changeMemberRole(
        organisationId: widget.organisation['id'],
        userId: userId,
        newRole: newRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newRole == 'ADMIN'
                ? 'Member is now an Admin.'
                : 'Member is now Staff.',
          ),
        ),
      );

      await _loadMembers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to change member role: $e')),
      );
    }
  }

  Future<void> _confirmRemoveMember(dynamic member) async {
    final username = member['username'] ?? 'this member';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: Text(
            'Are you sure you want to remove $username from this organisation?',
          ),
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
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _removeMember(member['user_id']);
  }

  Future<void> _removeMember(int userId) async {
    try {
      await OrganisationService().removeMember(
        organisationId: widget.organisation['id'],
        userId: userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed successfully.')),
      );

      await _loadMembers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to remove member: $e')));
    }
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildPlaceholderCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinRequestCard(Map<String, dynamic> request) {
    final username = request['username'] ?? 'Unknown User';
    final email = request['email'] ?? '';
    final userId = request['user_id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectJoinRequest(userId),
                    child: const Text('Reject'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveJoinRequest(userId),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
