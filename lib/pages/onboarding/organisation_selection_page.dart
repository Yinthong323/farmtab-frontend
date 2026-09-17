import 'package:flutter/material.dart';

import 'organisation_page.dart';
import 'pending_request_page.dart';
import '../../services/organisation_service.dart';

class OrganisationSelectionPage extends StatefulWidget {
  final String accessToken;

  const OrganisationSelectionPage({super.key, required this.accessToken});

  @override
  State<OrganisationSelectionPage> createState() =>
      _OrganisationSelectionPageState();
}

class _OrganisationSelectionPageState extends State<OrganisationSelectionPage> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _organisations = [];
  List<dynamic> _filteredOrganisations = [];

  dynamic _selectedOrganisation;

  bool _isLoading = true;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();

    _loadOrganisations();

    _searchController.addListener(_filterOrganisations);
  }

  Future<void> _loadOrganisations() async {
    try {
      final organisations = await OrganisationService().getSharedOrganisations(
        setupToken: widget.accessToken,
      );

      if (!mounted) return;

      setState(() {
        _organisations = organisations;
        _filteredOrganisations = organisations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _filterOrganisations() {
    final searchText = _searchController.text.trim().toLowerCase();

    setState(() {
      if (searchText.isEmpty) {
        _filteredOrganisations = _organisations;
      } else {
        _filteredOrganisations = _organisations.where((organisation) {
          final name = organisation['name'].toString().toLowerCase();

          return name.contains(searchText);
        }).toList();
      }
    });
  }

  Future<void> _requestToJoin() async {
    if (_selectedOrganisation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organisation first.')),
      );
      return;
    }

    final organisationId = _selectedOrganisation['id'];

    try {
      final result = await OrganisationService().requestToJoin(
        organisationId: organisationId,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Request Submitted'),
            content: Text(
              result['message'] ?? 'Your request has been submitted and is waiting for approval.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PendingRequestPage(
            user: {'access_token': widget.accessToken},
            organisation: _selectedOrganisation,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showOrganisationInfo(Map<String, dynamic> organisation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(organisation['name'] ?? 'Organisation'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(organisation['description'] ?? 'No description provided.'),

                const SizedBox(height: 20),

                if (organisation['website'] != null &&
                    organisation['website'].toString().isNotEmpty) ...[
                  const Text(
                    'Website',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(organisation['website']),

                  const SizedBox(height: 20),
                ],

                if (organisation['phone_number'] != null &&
                    organisation['phone_number'].toString().isNotEmpty) ...[
                  const Text(
                    'Phone Number',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(organisation['phone_number']),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _createOwnOrganisation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganisationPage(setupToken: widget.accessToken),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Organisation')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const Text(
              'Choose how you want to use FarmTab',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Join an existing organisation or create your own.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _searchController,

              decoration: InputDecoration(
                labelText: 'Search shared organisations',
                hintText: 'Enter organisation name',

                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredOrganisations.isEmpty
                  ? const Center(child: Text('No shared organisations found.'))
                  : ListView.builder(
                      itemCount: _filteredOrganisations.length,

                      itemBuilder: (context, index) {
                        final organisation = _filteredOrganisations[index];

                        final isSelected =
                            _selectedOrganisation != null &&
                            _selectedOrganisation['id'] == organisation['id'];

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.business),
                            ),

                            title: Text(
                              organisation['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              organisation['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    _showOrganisationInfo(
                                      Map<String, dynamic>.from(organisation),
                                    );
                                  },
                                ),

                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                              ],
                            ),

                            selected: isSelected,

                            onTap: () {
                              setState(() {
                                _selectedOrganisation = organisation;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,

              child: ElevatedButton(
                onPressed: _isRequesting ? null : _requestToJoin,

                child: _isRequesting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text(
                        'Request to Join',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,

              child: OutlinedButton(
                onPressed: _isRequesting ? null : _createOwnOrganisation,

                child: const Text(
                  'Create Your Own Organisation',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
