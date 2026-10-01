// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../services/shelf_service.dart';

// class ShelfSettingsPage extends StatefulWidget {
//   final Map<String, dynamic> shelf;
//   final Map<String, dynamic> organisation;
//   final bool embedded;
//   final VoidCallback? onShelfDeleted;

//   const ShelfSettingsPage({
//     super.key,
//     required this.shelf,
//     required this.organisation,
//     this.embedded = false,
//     this.onShelfDeleted,
//   });

//   @override
//   State<ShelfSettingsPage> createState() => _ShelfSettingsPageState();
// }

// class _ShelfSettingsPageState extends State<ShelfSettingsPage> {
//   final ShelfService _shelfService = ShelfService();
//   final ImagePicker _imagePicker = ImagePicker();

//   static const String baseUrl = 'http://98.88.222.75:8000';

//   late TextEditingController _nameController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _cropTypeController;

//   XFile? _selectedImage;

//   bool _isSaving = false;

//   bool get _isAdmin => widget.organisation['role'] == 'ADMIN';

//   @override
//   void initState() {
//     super.initState();

//     _nameController = TextEditingController(text: widget.shelf['name'] ?? '');

//     _descriptionController = TextEditingController(
//       text: widget.shelf['description'] ?? '',
//     );

//     _cropTypeController = TextEditingController(
//       text: widget.shelf['crop_type'] ?? '',
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _cropTypeController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // PICK IMAGE
//   // ============================================================

//   Future<void> _pickImage() async {
//     if (!_isAdmin) return;

//     final image = await _imagePicker.pickImage(source: ImageSource.gallery);

//     if (image == null) return;

//     setState(() {
//       _selectedImage = image;
//     });
//   }

//   Future<void> _deleteShelf() async {
//     if (!_isAdmin) return;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: const Text(
//             'Delete Shelf?',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           content: Text(
//             'Are you sure you want to delete '
//             '"${widget.shelf['name']}"?\n\n'
//             'This action cannot be undone.',
//             style: const TextStyle(fontSize: 14, color: Colors.black87),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, false);
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () {
//                 Navigator.pop(dialogContext, true);
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true || !mounted) {
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       await _shelfService.deleteShelf(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//       );

//       if (!mounted) return;

//       // Tell ShelfDetailPage that this shelf was deleted.
//       widget.onShelfDeleted?.call();
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage(e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   Widget _buildShelfImageSection() {
//     final existingImage = widget.shelf['image'];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Shelf Image',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),

//         const SizedBox(height: 12),

//         if (_selectedImage != null)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.file(
//               File(_selectedImage!.path),
//               width: double.infinity,
//               height: 220,
//               fit: BoxFit.cover,
//             ),
//           )
//         else if (existingImage != null && existingImage.toString().isNotEmpty)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               '$baseUrl$existingImage',
//               width: double.infinity,
//               height: 220,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   width: double.infinity,
//                   height: 220,
//                   color: Colors.grey.shade200,
//                   child: const Icon(Icons.image_not_supported, size: 60),
//                 );
//               },
//             ),
//           )
//         else
//           Container(
//             width: double.infinity,
//             height: 220,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(Icons.image, size: 60),
//           ),

//         const SizedBox(height: 12),

//         if (_isAdmin)
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.image_outlined),
//               label: Text(
//                 _selectedImage == null
//                     ? 'Change Image'
//                     : 'Choose Different Image',
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//   // ============================================================
//   // SAVE
//   // ============================================================

//   Future<void> _saveShelf() async {
//     if (!_isAdmin) return;

//     final name = _nameController.text.trim();
//     final description = _descriptionController.text.trim();
//     final cropType = _cropTypeController.text.trim();

//     if (name.isEmpty) {
//       _showMessage('Shelf name is required.');
//       return;
//     }

//     if (cropType.isEmpty) {
//       _showMessage('Crop type is required.');
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final result = await _shelfService.updateShelf(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//         name: name,
//         description: description.isEmpty ? null : description,
//         cropType: cropType,

//         // IMPORTANT:
//         // Device serial number is intentionally NOT edited here.
//         deviceSerialNumber: widget.shelf['device_serial_number'] ?? '',

//         imagePath: _selectedImage?.path,
//       );

//       if (!mounted) return;

//       if (result['id'] != null) {
//         widget.shelf['id'] = result['id'];
//       }

//       if (result['site_id'] != null) {
//         widget.shelf['site_id'] = result['site_id'];
//       }

//       if (result['name'] != null) {
//         widget.shelf['name'] = result['name'];
//       }

//       widget.shelf['description'] = result['description'];

//       if (result['crop_type'] != null) {
//         widget.shelf['crop_type'] = result['crop_type'];
//       }

//       if (result['image'] != null) {
//         widget.shelf['image'] = result['image'];
//       }

//       _showMessage('Shelf information updated successfully.');

//       await Future.delayed(const Duration(milliseconds: 500));

//       if (!mounted) return;

//       if (!widget.embedded) {
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage(e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     if (widget.embedded) {
//       return _buildContent();
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Shelf Settings')),
//       body: _buildContent(),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.shelf['name'] ?? 'Shelf',
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 6),

//           Text(
//             _isAdmin ? 'Manage shelf information.' : 'View shelf information.',
//             style: TextStyle(color: Colors.grey.shade600),
//           ),

//           const SizedBox(height: 24),

//           // ====================================================
//           // IMAGE
//           // ====================================================
//           const Text(
//             'Shelf Image',
//             style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 12),

//           _buildImageSection(),

//           const SizedBox(height: 24),

//           // ====================================================
//           // SHELF NAME
//           // ====================================================
//           TextField(
//             controller: _nameController,
//             enabled: _isAdmin,
//             decoration: const InputDecoration(
//               labelText: 'Shelf Name',
//               border: OutlineInputBorder(),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // ====================================================
//           // DESCRIPTION
//           // ====================================================
//           TextField(
//             controller: _descriptionController,
//             enabled: _isAdmin,
//             maxLines: 4,
//             decoration: const InputDecoration(
//               labelText: 'Description',
//               border: OutlineInputBorder(),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // ====================================================
//           // CROP TYPE
//           // ====================================================
//           TextField(
//             controller: _cropTypeController,
//             enabled: _isAdmin,
//             decoration: const InputDecoration(
//               labelText: 'Crop Type',
//               border: OutlineInputBorder(),
//             ),
//           ),

//           if (_isAdmin) ...[
//             const SizedBox(height: 30),

//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton.icon(
//                 onPressed: _isSaving ? null : _saveShelf,
//                 icon: _isSaving
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.save_outlined),
//                 label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
//               ),
//             ),

//             const SizedBox(height: 14),

//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: OutlinedButton.icon(
//                 onPressed: _isSaving ? null : _deleteShelf,
//                 icon: const Icon(Icons.delete_outline),
//                 label: const Text('Delete Shelf'),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.red,
//                   side: const BorderSide(color: Colors.red),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // IMAGE SECTION
//   // ============================================================

//   Widget _buildImageSection() {
//     if (_selectedImage != null) {
//       return Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(14),
//             child: Image.file(
//               File(_selectedImage!.path),
//               width: double.infinity,
//               height: 220,
//               fit: BoxFit.cover,
//             ),
//           ),

//           if (_isAdmin)
//             Positioned(
//               right: 12,
//               top: 12,
//               child: FloatingActionButton.small(
//                 onPressed: _pickImage,
//                 child: const Icon(Icons.edit),
//               ),
//             ),
//         ],
//       );
//     }

//     final imagePath = widget.shelf['image'];

//     if (imagePath != null && imagePath.toString().isNotEmpty) {
//       return Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(14),
//             child: Image.network(
//               '$baseUrl$imagePath',
//               width: double.infinity,
//               height: 220,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return _buildImagePlaceholder();
//               },
//             ),
//           ),

//           if (_isAdmin)
//             Positioned(
//               right: 12,
//               top: 12,
//               child: FloatingActionButton.small(
//                 onPressed: _pickImage,
//                 child: const Icon(Icons.edit),
//               ),
//             ),
//         ],
//       );
//     }

//     return _buildImagePlaceholder();
//   }

//   Widget _buildImagePlaceholder() {
//     return GestureDetector(
//       onTap: _isAdmin ? _pickImage : null,
//       child: Container(
//         width: double.infinity,
//         height: 220,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.image_outlined, size: 55, color: Colors.grey),

//             const SizedBox(height: 10),

//             Text(
//               _isAdmin ? 'Tap to add shelf image' : 'No shelf image',
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/shelf_service.dart';

// ─────────────────────────────────────────────────────────────
// FARMTAB DESIGN TOKENS (same system used across the app)
// ─────────────────────────────────────────────────────────────
class FarmTabTheme {
  static const Color forest = Color(0xFF1B4332);
  static const Color grove = Color(0xFF2D6A4F);
  static const Color fern = Color(0xFF40916C);
  static const Color mint = Color(0xFF95D5B2);
  static const Color mist = Color(0xFFD8F3DC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E8E8);
  static const Color textH = Color(0xFF111111);
  static const Color textB = Color(0xFF444444);
  static const Color textM = Color(0xFF888888);
  static const Color alertRed = Color(0xFFE63946);

  static TextStyle font({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: grove,
    foregroundColor: white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ButtonStyle dangerOutlinedButton = OutlinedButton.styleFrom(
    foregroundColor: alertRed,
    side: const BorderSide(color: Color(0xFFF4B9BE)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: font(size: 13.5, weight: FontWeight.w500, color: textM),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: fern, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class ShelfSettingsPage extends StatefulWidget {
  final Map<String, dynamic> shelf;
  final Map<String, dynamic> organisation;
  final bool embedded;
  final VoidCallback? onShelfDeleted;

  const ShelfSettingsPage({
    super.key,
    required this.shelf,
    required this.organisation,
    this.embedded = false,
    this.onShelfDeleted,
  });

  @override
  State<ShelfSettingsPage> createState() => _ShelfSettingsPageState();
}

class _ShelfSettingsPageState extends State<ShelfSettingsPage> {
  final ShelfService _shelfService = ShelfService();
  final ImagePicker _imagePicker = ImagePicker();

  static const String baseUrl = 'http://98.88.222.75:8000';

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cropTypeController;

  XFile? _selectedImage;

  bool _isSaving = false;

  bool get _isAdmin => widget.organisation['role'] == 'ADMIN';

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.shelf['name'] ?? '');

    _descriptionController = TextEditingController(
      text: widget.shelf['description'] ?? '',
    );

    _cropTypeController = TextEditingController(
      text: widget.shelf['crop_type'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cropTypeController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    if (!_isAdmin) return;

    final image = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _deleteShelf() async {
    if (!_isAdmin) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: FarmTabTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FarmTabTheme.alertRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: FarmTabTheme.alertRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Shelf?',
                style: FarmTabTheme.font(
                  size: 16.5,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete '
            '"${widget.shelf['name']}"?\n\n'
            'This action cannot be undone.',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textM,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FarmTabTheme.alertRed,
                foregroundColor: FarmTabTheme.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Delete',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _shelfService.deleteShelf(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
      );

      if (!mounted) return;

      // Tell ShelfDetailPage that this shelf was deleted.
      widget.onShelfDeleted?.call();
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveShelf() async {
    if (!_isAdmin) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final cropType = _cropTypeController.text.trim();

    if (name.isEmpty) {
      _showMessage('Shelf name is required.');
      return;
    }

    if (cropType.isEmpty) {
      _showMessage('Crop type is required.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await _shelfService.updateShelf(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
        name: name,
        description: description.isEmpty ? null : description,
        cropType: cropType,

        // IMPORTANT:
        // Device serial number is intentionally NOT edited here.
        deviceSerialNumber: widget.shelf['device_serial_number'] ?? '',

        imagePath: _selectedImage?.path,
      );

      if (!mounted) return;

      if (result['id'] != null) {
        widget.shelf['id'] = result['id'];
      }

      if (result['site_id'] != null) {
        widget.shelf['site_id'] = result['site_id'];
      }

      if (result['name'] != null) {
        widget.shelf['name'] = result['name'];
      }

      widget.shelf['description'] = result['description'];

      if (result['crop_type'] != null) {
        widget.shelf['crop_type'] = result['crop_type'];
      }

      if (result['image'] != null) {
        widget.shelf['image'] = result['image'];
      }

      _showMessage('Shelf information updated successfully.');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      if (!widget.embedded) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Container(color: FarmTabTheme.white, child: _buildContent());
    }

    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 3,
        shadowColor: FarmTabTheme.fern.withOpacity(0.35),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        iconTheme: const IconThemeData(color: FarmTabTheme.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [FarmTabTheme.fern, Color(0xFF52B788)],
            ),
          ),
        ),
        title: Text(
          'Shelf Settings',
          style: FarmTabTheme.font(
            size: 17,
            weight: FontWeight.w700,
            color: FarmTabTheme.white,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.shelf['name'] ?? 'Shelf',
            style: FarmTabTheme.font(
              size: 21,
              weight: FontWeight.w800,
              color: FarmTabTheme.textH,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _isAdmin ? 'Manage shelf information.' : 'View shelf information.',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textM,
            ),
          ),

          const SizedBox(height: 22),

          // ====================================================
          // IMAGE
          // ====================================================
          _sectionLabel('Shelf Image'),

          const SizedBox(height: 12),

          _buildImageSection(),

          const SizedBox(height: 22),

          // ====================================================
          // DETAILS CARD
          // ====================================================
          _sectionLabel('Details'),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: FarmTabTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  enabled: _isAdmin,
                  style: FarmTabTheme.font(
                    size: 14.5,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textH,
                  ),
                  decoration: FarmTabTheme.fieldDecoration('Shelf Name'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _descriptionController,
                  enabled: _isAdmin,
                  maxLines: 4,
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textH,
                  ),
                  decoration: FarmTabTheme.fieldDecoration('Description'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _cropTypeController,
                  enabled: _isAdmin,
                  style: FarmTabTheme.font(
                    size: 14.5,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textH,
                  ),
                  decoration: FarmTabTheme.fieldDecoration('Crop Type'),
                ),
              ],
            ),
          ),

          if (_isAdmin) ...[
            const SizedBox(height: 26),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [FarmTabTheme.grove, FarmTabTheme.fern],
                ),
                boxShadow: [
                  BoxShadow(
                    color: FarmTabTheme.fern.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isSaving ? null : _saveShelf,
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FarmTabTheme.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.save_rounded,
                                  size: 19,
                                  color: FarmTabTheme.white,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'Save Changes',
                                  style: FarmTabTheme.font(
                                    size: 14.5,
                                    weight: FontWeight.w600,
                                    color: FarmTabTheme.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _deleteShelf,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(
                  'Delete Shelf',
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.alertRed,
                  ),
                ),
                style: FarmTabTheme.dangerOutlinedButton,
              ),
            ),
          ],

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: FarmTabTheme.font(
        size: 15,
        weight: FontWeight.w700,
        color: FarmTabTheme.textH,
        letterSpacing: -0.2,
      ),
    );
  }

  // ============================================================
  // IMAGE SECTION
  // ============================================================

  Widget _buildImageSection() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_selectedImage!.path),
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
            ),
          ),

          if (_isAdmin) _buildEditImageButton(),
        ],
      );
    }

    final imagePath = widget.shelf['image'];

    if (imagePath != null && imagePath.toString().isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              '$baseUrl$imagePath',
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            ),
          ),

          if (_isAdmin) _buildEditImageButton(),
        ],
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildEditImageButton() {
    return Positioned(
      right: 12,
      top: 12,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _pickImage,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_rounded,
              size: 17,
              color: FarmTabTheme.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return GestureDetector(
      onTap: _isAdmin ? _pickImage : null,
      child: Container(
        width: double.infinity,
        height: 210,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FarmTabTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: FarmTabTheme.mist,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                size: 26,
                color: FarmTabTheme.fern,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _isAdmin ? 'Tap to add shelf image' : 'No shelf image',
              style: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w500,
                color: FarmTabTheme.textM,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
