import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import '../shelves/shelves_page.dart';
import '../../services/site_service.dart';

class SitesPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const SitesPage({super.key, required this.user, required this.organisation});

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  // Temporary sample data.
  // We will replace this with data from FastAPI later.
  final SiteService _siteService = SiteService();

  List<Map<String, dynamic>> _sites = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get isAdmin => widget.organisation['role'] == 'ADMIN';
  List<Map<String, dynamic>> get _filteredSites {
    if (_searchQuery.trim().isEmpty) {
      return _sites;
    }

    final query = _searchQuery.trim().toLowerCase();

    return _sites.where((site) {
      final name = (site['name'] ?? '').toString().toLowerCase();
      final description = (site['description'] ?? '').toString().toLowerCase();

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    try {
      // Only show the full-page loading screen
      // when Sites have never been loaded before.
      if (_sites.isEmpty) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final organisationId = widget.organisation['id'];

      final sites = await _siteService.getSites(organisationId: organisationId);

      if (!mounted) return;

      setState(() {
        _sites = List<Map<String, dynamic>>.from(sites);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),

      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showAddSiteDialog,
              child: const Icon(Icons.add),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),

              const SizedBox(height: 16),

              const Text(
                'Unable to load Sites',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loadSites,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_sites.isEmpty) {
      return _buildEmptyState();
    }

    if (_filteredSites.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          const Text(
            'Sites',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            isAdmin
                ? 'Manage your organisation\'s growing sites here.'
                : 'View the growing sites available in your organisation.',
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search sites...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 50),

          const Center(
            child: Text(
              'No matching Sites found.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'Sites',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        // Text(
        //   isAdmin
        //       ? 'Manage your organisation\'s growing sites here.'
        //       : 'View the growing sites available in your organisation.',
        //   style: const TextStyle(fontSize: 15, color: Colors.grey),
        // ),

        // const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search sites...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();

                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 20),

        ..._filteredSites.map((site) => _buildSiteCard(site)),
      ],
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShelvesPage(site: site, organisation: widget.organisation),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Site image
            Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey.shade200,
              child:
                  site['image'] != null && site['image'].toString().isNotEmpty
                  ? Image.network(
                      'http://98.88.222.75:8000${site['image']}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 40);
                      },
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, size: 55, color: Colors.green),
                        SizedBox(height: 8),
                        Text(
                          'Site Image',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          site['name'],
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (isAdmin)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditSiteDialog(site);
                            } else if (value == 'delete') {
                              _deleteSite(site);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Site'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Site'),
                            ),
                          ],
                        ),
                    ],
                  ),

                  if (site['description'] != null &&
                      site['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      site['description'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],

                  const SizedBox(height: 12),

                  const Row(
                    children: [
                      Icon(Icons.arrow_forward, size: 18, color: Colors.green),
                      SizedBox(width: 6),
                      Text(
                        'View shelves',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 70, color: Colors.green),

            const SizedBox(height: 16),

            const Text(
              'No Sites Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your first Site to start managing your growing areas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            if (isAdmin)
              ElevatedButton.icon(
                onPressed: _showAddSiteDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Site'),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD SITE
  // ============================================================

  void _showAddSiteDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Site'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Site Name *',
                        hintText: 'Enter site name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Optional',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Site Image *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedImage == null
                                  ? Colors.grey
                                  : Colors.green,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: selectedImage == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'No image selected',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  )
                                : Image.file(
                                    File(selectedImage!.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        OutlinedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();

                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );

                            if (image != null) {
                              setDialogState(() {
                                selectedImage = image;
                              });
                            }
                          },
                          icon: const Icon(Icons.photo),
                          label: Text(
                            selectedImage == null
                                ? 'Select Image'
                                : 'Change Image',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Site name is required.')),
                      );
                      return;
                    }

                    if (selectedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Site image is required.'),
                        ),
                      );
                      return;
                    }

                    try {
                      await _siteService.createSite(
                        organisationId: widget.organisation['id'],
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        imagePath: selectedImage!.path,
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      await _loadSites();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Site added successfully.'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unable to add Site: $e')),
                      );
                    }
                  },
                  child: const Text('Add Site'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // EDIT SITE
  // ============================================================

  void _showEditSiteDialog(Map<String, dynamic> site) {
    final nameController = TextEditingController(text: site['name']);

    final descriptionController = TextEditingController(
      text: site['description'] ?? '',
    );

    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Site'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Site Name *',
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Optional',
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Site Image',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 8),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: selectedImage != null
                                ? Image.file(
                                    File(selectedImage!.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : (site['image'] != null &&
                                      site['image'].toString().isNotEmpty)
                                ? Image.network(
                                    'http://98.88.222.75:8000${site['image']}',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.eco,
                                      size: 50,
                                      color: Colors.green,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        OutlinedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();

                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );

                            if (image != null) {
                              setDialogState(() {
                                selectedImage = image;
                              });
                            }
                          },
                          icon: const Icon(Icons.photo),
                          label: Text(
                            selectedImage == null
                                ? 'Change Image'
                                : 'Choose Another Image',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Site name is required.')),
                      );
                      return;
                    }

                    try {
                      await _siteService.updateSite(
                        organisationId: widget.organisation['id'],
                        siteId: site['id'],
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        imagePath: selectedImage?.path,
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      await _loadSites();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Site updated successfully.'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unable to update Site: $e')),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DELETE SITE
  // ============================================================

  void _deleteSite(Map<String, dynamic> site) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Site?'),

          content: Text('Are you sure you want to delete "${site['name']}"?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                try {
                  await _siteService.deleteSite(
                    organisationId: widget.organisation['id'],
                    siteId: site['id'],
                  );

                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  await _loadSites();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Site deleted successfully.')),
                  );
                } catch (e) {
                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to delete Site: $e')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
