import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/shelf_service.dart';
import 'shelf_detail_page.dart';

class ShelvesPage extends StatefulWidget {
  final Map<String, dynamic> site;
  final Map<String, dynamic> organisation;

  const ShelvesPage({
    super.key,
    required this.site,
    required this.organisation,
  });

  @override
  State<ShelvesPage> createState() => _ShelvesPageState();
}

class _ShelvesPageState extends State<ShelvesPage> {
  final ShelfService _shelfService = ShelfService();

  final ImagePicker _imagePicker = ImagePicker();

  List<Map<String, dynamic>> _shelves = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadShelves();
  }

  // ============================================================
  // LOAD SHELVES
  // ============================================================

  Future<void> _loadShelves() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final siteId = widget.site['id'];

      final shelves = await _shelfService.getShelves(siteId: siteId);

      if (!mounted) return;

      setState(() {
        _shelves = List<Map<String, dynamic>>.from(shelves);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // SELECT IMAGE
  // ============================================================

  Future<XFile?> _pickShelfImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      return image;
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to select image: $e')));

      return null;
    }
  }

  // ============================================================
  // ADD SHELF
  // ============================================================

  Future<void> _showAddShelfDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final cropTypeController = TextEditingController();
    final deviceSerialController = TextEditingController();

    XFile? selectedImage;

    try {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          bool isSaving = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Add Shelf'),

                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ------------------------------------------------
                      // SHELF IMAGE
                      // ------------------------------------------------

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Shelf Image *',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(selectedImage!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No image selected',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final image = await _pickShelfImage();

                                  if (image == null) return;

                                  setDialogState(() {
                                    selectedImage = image;
                                  });
                                },
                          icon: const Icon(Icons.photo_library),
                          label: Text(
                            selectedImage == null
                                ? 'Select Image'
                                : 'Change Image',
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // SHELF NAME
                      // ------------------------------------------------
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Shelf Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // DESCRIPTION
                      // ------------------------------------------------
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // CROP TYPE
                      // ------------------------------------------------
                      TextField(
                        controller: cropTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Crop Type *',
                          hintText: 'e.g. Lettuce',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // DEVICE SERIAL NUMBER
                      // ------------------------------------------------
                      TextField(
                        controller: deviceSerialController,
                        decoration: const InputDecoration(
                          labelText: 'Device Serial Number *',
                          hintText: 'e.g. RPI-0001',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                // ======================================================
                // BUTTONS
                // ======================================================
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            Navigator.pop(dialogContext);
                          },
                    child: const Text('Cancel'),
                  ),

                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name = nameController.text.trim();

                            final description = descriptionController.text
                                .trim();

                            final cropType = cropTypeController.text.trim();

                            final deviceSerial = deviceSerialController.text
                                .trim();

                            // ------------------------------------------------
                            // VALIDATION
                            // ------------------------------------------------

                            if (name.isEmpty ||
                                cropType.isEmpty ||
                                deviceSerial.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill in all required fields.',
                                  ),
                                ),
                              );

                              return;
                            }

                            if (selectedImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a Shelf image.'),
                                ),
                              );

                              return;
                            }

                            // ------------------------------------------------
                            // START SAVING
                            // ------------------------------------------------

                            setDialogState(() {
                              isSaving = true;
                            });

                            try {
                              final siteId = widget.site['id'];

                              await _shelfService.createShelf(
                                siteId: siteId,
                                name: name,
                                description: description.isEmpty
                                    ? null
                                    : description,
                                cropType: cropType,
                                deviceSerialNumber: deviceSerial,
                                imagePath: selectedImage!.path,
                              );

                              if (!dialogContext.mounted) {
                                return;
                              }

                              Navigator.pop(dialogContext);

                              await _loadShelves();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Shelf added successfully.'),
                                ),
                              );
                            } catch (e) {
                              setDialogState(() {
                                isSaving = false;
                              });

                              if (!dialogContext.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Shelf'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      cropTypeController.dispose();
      deviceSerialController.dispose();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.site['name'] ?? 'Shelves')),

      body: _buildBody(),

      // ------------------------------------------------------------
      // ADMIN CAN ADD SHELF
      // ------------------------------------------------------------
      floatingActionButton: widget.organisation['role'] == 'ADMIN'
          ? FloatingActionButton(
              onPressed: _showAddShelfDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // ============================================================
  // BODY
  // ============================================================

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
                'Unable to load Shelves',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(_errorMessage!, textAlign: TextAlign.center),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loadShelves,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_shelves.isEmpty) {
      return const Center(
        child: Text(
          'No Shelves found.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // ------------------------------------------------------------
    // SHELF LIST
    // ------------------------------------------------------------

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _shelves.length,
      itemBuilder: (context, index) {
        final shelf = _shelves[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),

          clipBehavior: Clip.antiAlias,

          child: InkWell(
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShelfDetailPage(
                    shelf: shelf,
                    organisation: widget.organisation,
                  ),
                ),
              );

              if (updated == true && mounted) {
                await _loadShelves();
              }
            },

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------
                // SHELF IMAGE
                // ----------------------------------------------------

                Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade200,

                  child:
                      shelf['image'] != null &&
                          shelf['image'].toString().isNotEmpty
                      ? Image.network(
                          'http://98.88.222.75:8000${shelf['image']}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,

                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(Icons.eco, size: 50, color: Colors.green),
                        ),
                ),

                // ----------------------------------------------------
                // SHELF INFORMATION
                // ----------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shelf['name'] ?? 'Unnamed Shelf',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              shelf['crop_type'] ?? '',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            if (shelf['description'] != null &&
                                shelf['description'].toString().isNotEmpty) ...[
                              const SizedBox(height: 6),

                              Text(
                                shelf['description'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
