import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/responsive.dart';
import '../../services/shelf_service.dart';
import 'shelf_detail_page.dart';

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
  static const Color amber = Color(0xFFF4A261);
  static const Color skyBlue = Color(0xFF457B9D);

  // Palette used to differentiate crop-type slices in the chart.
  static const List<Color> chartPalette = [
    grove,
    fern,
    amber,
    skyBlue,
    mint,
    forest,
  ];

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
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: border, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

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

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredShelves {
    if (_searchQuery.trim().isEmpty) {
      return _shelves;
    }

    final query = _searchQuery.trim().toLowerCase();

    return _shelves.where((shelf) {
      final name = (shelf['name'] ?? '').toString().toLowerCase();
      final description = (shelf['description'] ?? '').toString().toLowerCase();
      final cropType = (shelf['crop_type'] ?? '').toString().toLowerCase();
      final deviceSerial = (shelf['device_serial_number'] ?? '')
          .toString()
          .toLowerCase();

      return name.contains(query) ||
          description.contains(query) ||
          cropType.contains(query) ||
          deviceSerial.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadShelves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    String? validationMessage;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screenSize = MediaQuery.sizeOf(context);
            final viewInsets = MediaQuery.viewInsetsOf(context);

            final isMobile = screenSize.width < 600;

            final dialogWidth = isMobile ? screenSize.width - 32 : 520.0;

            final availableHeight = screenSize.height - viewInsets.bottom;

            final dialogMaxHeight = (availableHeight - 48).clamp(200.0, 720.0);

            InputDecoration fieldDecoration(String label, String hint) {
              return InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textM,
                ),
                hintStyle: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textM,
                ),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: FarmTabTheme.fern,
                    width: 1.5,
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: FarmTabTheme.white,
              insetPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 40,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: dialogWidth,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: dialogMaxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ==================================================
                      // TITLE
                      // ==================================================

                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Add Shelf',
                            style: FarmTabTheme.font(
                              size: 17,
                              weight: FontWeight.w700,
                              color: FarmTabTheme.textH,
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // FORM CONTENT
                      // ==================================================
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ------------------------------------------------
                              // SHELF IMAGE
                              // ------------------------------------------------
                              Text(
                                'Shelf Image',
                                style: FarmTabTheme.font(
                                  size: 13,
                                  weight: FontWeight.w500,
                                  color: FarmTabTheme.textH,
                                ),
                              ),

                              const SizedBox(height: 8),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  color: const Color(0xFFF2F2F2),
                                  child: selectedImage != null
                                      ? Image.file(
                                          File(selectedImage!.path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add_photo_alternate_rounded,
                                              size: 32,
                                              color: Color(0xFFB8B8B8),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'No image selected',
                                              style: FarmTabTheme.font(
                                                size: 12,
                                                weight: FontWeight.w400,
                                                color: const Color(0xFFB8B8B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 9),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          final image = await _pickShelfImage();

                                          if (image != null) {
                                            setDialogState(() {
                                              selectedImage = image;
                                              validationMessage = null;
                                            });
                                          }
                                        },
                                  icon: const Icon(
                                    Icons.photo_library_rounded,
                                    size: 15,
                                  ),
                                  label: Text(
                                    selectedImage == null
                                        ? 'Select Image'
                                        : 'Change Image',
                                    style: FarmTabTheme.font(
                                      size: 13,
                                      weight: FontWeight.w500,
                                      color: FarmTabTheme.grove,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: FarmTabTheme.grove,
                                    side: const BorderSide(
                                      color: FarmTabTheme.fern,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ------------------------------------------------
                              // SHELF NAME
                              // ------------------------------------------------
                              TextField(
                                controller: nameController,
                                enabled: !isSaving,
                                style: FarmTabTheme.font(
                                  size: 14,
                                  weight: FontWeight.w400,
                                  color: FarmTabTheme.textH,
                                ),
                                decoration: fieldDecoration(
                                  'Shelf Name',
                                  'e.g. Shelf 1',
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ------------------------------------------------
                              // DESCRIPTION
                              // ------------------------------------------------
                              TextField(
                                controller: descriptionController,
                                enabled: !isSaving,
                                maxLines: 3,
                                style: FarmTabTheme.font(
                                  size: 14,
                                  weight: FontWeight.w400,
                                  color: FarmTabTheme.textH,
                                ),
                                decoration: fieldDecoration(
                                  'Description',
                                  'Enter shelf description',
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ------------------------------------------------
                              // CROP TYPE
                              // ------------------------------------------------
                              TextField(
                                controller: cropTypeController,
                                enabled: !isSaving,
                                style: FarmTabTheme.font(
                                  size: 14,
                                  weight: FontWeight.w400,
                                  color: FarmTabTheme.textH,
                                ),
                                decoration: fieldDecoration(
                                  'Crop Type',
                                  'e.g. Lettuce',
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ------------------------------------------------
                              // DEVICE SERIAL NUMBER
                              // ------------------------------------------------
                              TextField(
                                controller: deviceSerialController,
                                enabled: !isSaving,
                                style: FarmTabTheme.font(
                                  size: 14,
                                  weight: FontWeight.w400,
                                  color: FarmTabTheme.textH,
                                ),
                                decoration: fieldDecoration(
                                  'Device Serial Number',
                                  'e.g. FARM-DEVICE-001',
                                ),
                              ),

                              const SizedBox(height: 4),
                              if (validationMessage != null) ...[
                                const SizedBox(height: 10),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FarmTabTheme.alertRed.withOpacity(
                                      0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      color: FarmTabTheme.alertRed.withOpacity(
                                        0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        size: 18,
                                        color: FarmTabTheme.alertRed,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          validationMessage!,
                                          style: FarmTabTheme.font(
                                            size: 12,
                                            weight: FontWeight.w500,
                                            color: FarmTabTheme.alertRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // ==================================================
                      // BUTTONS
                      // ==================================================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        FocusScope.of(dialogContext).unfocus();
                                        Navigator.pop(dialogContext);
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: FarmTabTheme.textM,
                                  side: const BorderSide(
                                    color: FarmTabTheme.border,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: FarmTabTheme.font(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: FarmTabTheme.textM,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        final name = nameController.text.trim();

                                        final description =
                                            descriptionController.text.trim();

                                        final cropType = cropTypeController.text
                                            .trim();

                                        final deviceSerial =
                                            deviceSerialController.text.trim();

                                        // --------------------------------
                                        // VALIDATION
                                        // --------------------------------

                                        if (name.isEmpty ||
                                            cropType.isEmpty ||
                                            deviceSerial.isEmpty) {
                                          setDialogState(() {
                                            validationMessage = 'Please fill in all required fields.';
                                          });

                                          return;
                                        }

                                        if (selectedImage == null) {
                                          setDialogState(() {
                                            validationMessage =
                                                'Please select a Shelf image.';
                                          });

                                          return;
                                        }

                                        // --------------------------------
                                        // START SAVING
                                        // --------------------------------

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

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Shelf added successfully.',
                                                  ),
                                                ),
                                              );
                                        } catch (e) {
                                          if (!dialogContext.mounted) {
                                            return;
                                          }

                                          setDialogState(() {
                                            isSaving = false;
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString()),
                                                ),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FarmTabTheme.grove,
                                  foregroundColor: FarmTabTheme.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: FarmTabTheme.white,
                                        ),
                                      )
                                    : Text(
                                        'Add Shelf',
                                        style: FarmTabTheme.font(
                                          size: 13,
                                          weight: FontWeight.w600,
                                          color: FarmTabTheme.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: FarmTabTheme.white,
        appBar: _buildAppBar(),
        body: TabBarView(children: [_buildBody(), _buildOverview()]),
        floatingActionButton: widget.organisation['role'] == 'ADMIN'
            ? _buildFab()
            : null,
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────
  // A standard AppBar (Flutter sizes this correctly on its own —
  // no manual height math, so no more overflow) with a gradient
  // background and a clean pill-style tab switcher underneath.

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 3,
      shadowColor: FarmTabTheme.fern.withOpacity(0.35),
      scrolledUnderElevation: 3,
      centerTitle: false,
      titleSpacing: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
      iconTheme: const IconThemeData(color: FarmTabTheme.white),
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [FarmTabTheme.fern, Color.fromARGB(255, 112, 212, 167)],
            ),
          ),
        ),
      ),
      title: Text(
        widget.site['name'] ?? 'Shelves',
        style: FarmTabTheme.font(
          size: 17,
          weight: FontWeight.w700,
          color: FarmTabTheme.white,
          letterSpacing: -0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Container(
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: FarmTabTheme.white,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: FarmTabTheme.grove,
              unselectedLabelColor: Colors.white,
              labelStyle: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w600,
                color: FarmTabTheme.grove,
              ),
              unselectedLabelStyle: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w500,
                color: Colors.white,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.view_module_rounded, size: 15),
                      SizedBox(width: 6),
                      Text('Shelves'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.insights_rounded, size: 15),
                      SizedBox(width: 6),
                      Text('Overview'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FarmTabTheme.grove, FarmTabTheme.fern],
        ),
        boxShadow: [
          BoxShadow(
            color: FarmTabTheme.fern.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _showAddShelfDialog,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: FarmTabTheme.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Shelf',
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.white,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OVERVIEW TAB
  // ============================================================

  Widget _buildOverview() {
    final description = widget.site['description']?.toString().trim() ?? '';

    final cropCounts = <String, int>{};

    for (final shelf in _shelves) {
      final cropType = shelf['crop_type']?.toString().trim();

      if (cropType == null || cropType.isEmpty) {
        continue;
      }

      cropCounts[cropType] = (cropCounts[cropType] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Total shelves stat
              _buildOverviewCard(
                icon: Icons.view_module_rounded,
                title: 'Total Shelves',
                value: '${_shelves.length}',
              ),

              const SizedBox(height: 20),

              // ── Crop composition (donut chart + legend)
              Text(
                'Crop Composition',
                style: FarmTabTheme.font(
                  size: 15,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),

              const SizedBox(height: 10),

              if (cropCounts.isEmpty)
                _buildOverviewSection(
                  child: Text(
                    'No crop information available.',
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                )
              else
                _buildOverviewSection(
                  child: _CropCompositionChart(cropCounts: cropCounts),
                ),

              const SizedBox(height: 20),

              // ── Description
              Text(
                'Description',
                style: FarmTabTheme.font(
                  size: 15,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),

              const SizedBox(height: 10),

              _buildOverviewSection(
                child: Text(
                  description.isEmpty
                      ? 'No description available.'
                      : description,
                  style: FarmTabTheme.font(
                    size: 13.5,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textB,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: FarmTabTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: FarmTabTheme.mist,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: FarmTabTheme.grove, size: 22),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: FarmTabTheme.font(
                size: 14,
                weight: FontWeight.w500,
                color: FarmTabTheme.textM,
              ),
            ),
          ),

          Text(
            value,
            style: FarmTabTheme.font(
              size: 24,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: FarmTabTheme.cardDecoration,
      child: child,
    );
  }

  double _shelfCardHeight(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final columns = Responsive.gridColumns(context);

    const horizontalPadding = 40.0;
    const spacing = 16.0;

    final availableWidth =
        screenWidth - horizontalPadding - ((columns - 1) * spacing);

    final cardWidth = availableWidth / columns;

    final imageHeight = cardWidth * 9 / 16;

    // Image + single name/crop-type row
    return imageHeight + 60;
  }
  // ============================================================
  // BODY (Shelves tab)
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: FarmTabTheme.grove,
          strokeWidth: 2,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: FarmTabTheme.alertRed.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 30,
                  color: FarmTabTheme.alertRed,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Unable to load Shelves',
                style: FarmTabTheme.font(
                  size: 17,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textH,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textM,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _loadShelves,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(
                  'Try Again',
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FarmTabTheme.grove,
                  foregroundColor: FarmTabTheme.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_shelves.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: FarmTabTheme.mist,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 36,
                  color: FarmTabTheme.fern,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'No Shelves Yet',
                style: FarmTabTheme.font(
                  size: 18,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textH,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Shelves added to this site will appear here.',
                textAlign: TextAlign.center,
                style: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textM,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ------------------------------------------------------------
    // SHELF LIST
    // ------------------------------------------------------------
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            style: FarmTabTheme.font(
              size: 14,
              weight: FontWeight.w400,
              color: FarmTabTheme.textH,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search shelves...',
              hintStyle: FarmTabTheme.font(
                size: 14,
                weight: FontWeight.w400,
                color: FarmTabTheme.textM,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: FarmTabTheme.textM,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 18,
                        color: FarmTabTheme.textM,
                      ),
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: FarmTabTheme.fern,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (_shelves.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_filteredShelves.length} ${_filteredShelves.length == 1 ? 'shelf' : 'shelves'}',
              style: FarmTabTheme.font(
                size: 12,
                weight: FontWeight.w500,
                color: FarmTabTheme.textM,
              ),
            ),
          ),

        if (_filteredShelves.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 26,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No matching Shelves found.',
                    style: FarmTabTheme.font(
                      size: 15,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridColumns(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: _shelfCardHeight(context),
            ),
            itemCount: _filteredShelves.length,
            itemBuilder: (context, index) {
              return _buildShelfCard(_filteredShelves[index]);
            },
          ),
      ],
    );
  }

  Widget _buildShelfCard(Map<String, dynamic> shelf) {
    final hasImage =
        shelf['image'] != null && shelf['image'].toString().isNotEmpty;

    final shelfName = shelf['name']?.toString().trim().isNotEmpty == true
        ? shelf['name'].toString()
        : 'Unnamed Shelf';

    final cropType = shelf['crop_type']?.toString().trim().isNotEmpty == true
        ? shelf['crop_type'].toString()
        : null;

    return GestureDetector(
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
      child: Container(
        decoration: FarmTabTheme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF2F2F2),
                child: hasImage
                    ? Image.network(
                        'http://98.88.222.75:8000${shelf['image']}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.eco_rounded,
                              size: 30,
                              color: Color(0xFFB0B0B0),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.eco_rounded,
                          size: 30,
                          color: Color(0xFFB0B0B0),
                        ),
                      ),
              ),
            ),

            // ── Shelf name + crop type — same row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shelfName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FarmTabTheme.font(
                        size: 14.5,
                        weight: FontWeight.w600,
                        color: FarmTabTheme.textH,
                      ),
                    ),
                  ),
                  if (cropType != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FarmTabTheme.mist,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: FarmTabTheme.fern.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        cropType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FarmTabTheme.font(
                          size: 11,
                          weight: FontWeight.w700,
                          color: FarmTabTheme.grove,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CROP COMPOSITION — donut chart + legend
// ─────────────────────────────────────────────────────────────
class _CropCompositionChart extends StatelessWidget {
  final Map<String, int> cropCounts;

  const _CropCompositionChart({required this.cropCounts});

  @override
  Widget build(BuildContext context) {
    final total = cropCounts.values.fold<int>(0, (a, b) => a + b);
    final entries = cropCounts.entries.toList();

    final slices = <_ChartSlice>[
      for (var i = 0; i < entries.length; i++)
        _ChartSlice(
          label: entries[i].key,
          value: entries[i].value,
          color:
              FarmTabTheme.chartPalette[i % FarmTabTheme.chartPalette.length],
        ),
    ];

    final isNarrow = MediaQuery.sizeOf(context).width < 420;

    final chart = SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(148, 148),
            painter: _DonutPainter(slices: slices, total: total),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: FarmTabTheme.font(
                  size: 24,
                  weight: FontWeight.w800,
                  color: FarmTabTheme.textH,
                ),
              ),
              Text(
                'shelves',
                style: FarmTabTheme.font(
                  size: 11,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textM,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final slice in slices)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: slice.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    slice.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.textB,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  total == 0 ? '0%' : '${(slice.value / total * 100).round()}%',
                  style: FarmTabTheme.font(
                    size: 13,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${slice.value})',
                  style: FarmTabTheme.font(
                    size: 12,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    if (isNarrow) {
      return Column(children: [chart, const SizedBox(height: 18), legend]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        chart,
        const SizedBox(width: 24),
        Expanded(child: legend),
      ],
    );
  }
}

class _ChartSlice {
  final String label;
  final int value;
  final Color color;

  _ChartSlice({required this.label, required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_ChartSlice> slices;
  final int total;

  _DonutPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;

    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.total != total;
  }
}
