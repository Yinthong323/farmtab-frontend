import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import '../notifications/notifications_page.dart';
import '../shelves/shelves_page.dart';
import '../../services/site_service.dart';
import '../../utils/responsive.dart';
import '../../services/notification_service.dart';

// ─────────────────────────────────────────────────────────────
// FARMTAB DESIGN TOKENS
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

  // ── Professional typeface — Plus Jakarta Sans everywhere.
  // Swap this one helper if you ever want to change the app's font.
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

// ─────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────
class SitesPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const SitesPage({super.key, required this.user, required this.organisation});

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  final SiteService _siteService = SiteService();

  List<Map<String, dynamic>> _sites = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get isAdmin => widget.organisation['role'] == 'ADMIN';

  List<Map<String, dynamic>> get _filteredSites {
    if (_searchQuery.trim().isEmpty) return _sites;
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
    _loadUnreadNotificationCount();
  }

  final NotificationService _notificationService = NotificationService();

  int _unreadNotificationCount = 0;

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final notifications = await _notificationService.getNotifications();

      if (!mounted) return;

      final unreadCount = notifications.where((notification) {
        return notification['is_read'] == false;
      }).length;

      setState(() {
        _unreadNotificationCount = unreadCount;
      });
    } catch (e) {
      // Do not show an error message on the Sites page
      // just because the notification count failed.
      debugPrint('Unable to load unread notification count: $e');
    }
  }

  Future<void> _loadSites() async {
    try {
      if (_sites.isEmpty) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
      final sites = await _siteService.getSites(
        organisationId: widget.organisation['id'],
      );
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

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTabTheme.white,

      appBar: _buildAppBar(),

      body: _buildBody(),

      floatingActionButton: isAdmin ? _buildFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── APP BAR ────────────────────────────────────────────────
  // Lighter gradient (grove → fern) with the search box built
  // right into it, and the notification bell in its own square.

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(118),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FarmTabTheme.fern, Color.fromARGB(255, 112, 212, 167)],
          ),
          boxShadow: [
            BoxShadow(
              color: FarmTabTheme.grove.withOpacity(0.14),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Sites',
                        style: FarmTabTheme.font(
                          size: 20,
                          weight: FontWeight.w700,
                          color: FarmTabTheme.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    // Notification bell inside its own square box
                    // Notification bell with unread count
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationsPage(
                                    organisation: widget.organisation,
                                  ),
                                ),
                              );

                              // Refresh unread count after returning
                              // from the Notifications page.
                              _loadUnreadNotificationCount();
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 20,
                                color: FarmTabTheme.white,
                              ),
                            ),
                          ),
                        ),

                        // Unread notification badge
                        if (_unreadNotificationCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: BoxDecoration(
                                color: FarmTabTheme.alertRed,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: FarmTabTheme.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _unreadNotificationCount > 99
                                    ? '99+'
                                    : _unreadNotificationCount.toString(),
                                textAlign: TextAlign.center,
                                style: FarmTabTheme.font(
                                  size: 9,
                                  weight: FontWeight.w700,
                                  color: FarmTabTheme.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Search box, embedded in the header
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: FarmTabTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                      hintText: 'Search sites...',
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
                      suffixIcon: _searchController.text.isNotEmpty
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
                      fillColor: FarmTabTheme.white,
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
                        borderSide: BorderSide.none,
                      ),
                    ),
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
  // Extended FAB with a soft gradient fill so it reads as a
  // polished primary action rather than a flat button.

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
          onTap: _showAddSiteDialog,
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
                  'Add Site',
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

  // ── BODY STATES ────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();
    if (_sites.isEmpty) return _buildEmptyState();
    return _buildSitesList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: FarmTabTheme.grove,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorState() {
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
              'Unable to load Sites',
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
            _PrimaryButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              onPressed: _loadSites,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.eco_rounded,
                size: 38,
                color: FarmTabTheme.fern,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Sites Yet',
              style: FarmTabTheme.font(
                size: 18,
                weight: FontWeight.w600,
                color: FarmTabTheme.textH,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first site to start managing\nyour growing areas.',
              textAlign: TextAlign.center,
              style: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w400,
                color: FarmTabTheme.textM,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (isAdmin)
              _PrimaryButton(
                label: 'Add Site',
                icon: Icons.add_rounded,
                onPressed: _showAddSiteDialog,
              ),
          ],
        ),
      ),
    );
  }

  // ── MAIN LIST ──────────────────────────────────────────────

  Widget _buildSitesList() {
    return CustomScrollView(
      slivers: [
        // ── Site count
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: _sites.isNotEmpty
                ? Text(
                    '${_filteredSites.length} site(s)',
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),

        // ── Empty search result
        if (_filteredSites.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    'No sites found',
                    style: FarmTabTheme.font(
                      size: 15,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Try a different keyword',
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Site cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildSiteCard(_filteredSites[index]);
            }, childCount: _filteredSites.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridColumns(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: _siteCardHeight(context),
            ),
          ),
        ),
      ],
    );
  }

  double _siteCardHeight(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final columns = Responsive.gridColumns(context);

    const horizontalPadding = 40.0;
    const spacing = 16.0;

    final availableWidth =
        screenWidth - horizontalPadding - ((columns - 1) * spacing);

    final cardWidth = availableWidth / columns;

    final imageHeight = cardWidth * 9 / 16;

    // Image + site name section
    return imageHeight + 62;
  }

  // ── SITE CARD ──────────────────────────────────────────────

  Widget _buildSiteCard(Map<String, dynamic> site) {
    final hasImage =
        site['image'] != null && site['image'].toString().isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ShelvesPage(site: site, organisation: widget.organisation),
          ),
        );
      },
      child: Container(
        decoration: FarmTabTheme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: hasImage
                        ? Image.network(
                            'http://98.88.222.75:8000${site['image']}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),

                  // Admin menu — top right of image
                  if (isAdmin)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _CardMenuButton(
                        onEdit: () => _showEditSiteDialog(site),
                        onDelete: () => _deleteSite(site),
                      ),
                    ),
                ],
              ),
            ),

            // ── Site Name
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Text(
                site['name']?.toString() ?? 'Unnamed Site',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FarmTabTheme.font(
                  size: 15,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textH,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco_rounded, size: 32, color: Color(0xFFB0B0B0)),
          const SizedBox(height: 6),
          Text(
            'No image',
            style: FarmTabTheme.font(
              size: 12,
              weight: FontWeight.w400,
              color: const Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ADD SITE
  // ══════════════════════════════════════════════════════════

  void _showAddSiteDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    XFile? selectedImage;
    String? validationMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _FarmDialog(
              title: 'Add New Site',
              confirmLabel: 'Add Site',
              errorMessage: validationMessage,
              onCancel: () => Navigator.pop(dialogContext),
              onConfirm: () async {
                if (nameController.text.trim().isEmpty) {
                  setDialogState(() {
                    validationMessage = 'Site name is required.';
                  });
                  return;
                }

                if (selectedImage == null) {
                  setDialogState(() {
                    validationMessage = 'Site image is required.';
                  });
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
                    const SnackBar(content: Text('Site added successfully.')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to add Site: $e')),
                  );
                }
              },
              content: _SiteFormContent(
                nameController: nameController,
                descriptionController: descriptionController,
                selectedImage: selectedImage,
                existingImageUrl: null,
                onImagePicked: (img) =>
                    setDialogState(() => selectedImage = img),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════
  // EDIT SITE
  // ══════════════════════════════════════════════════════════

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
            return _FarmDialog(
              title: 'Edit Site',
              confirmLabel: 'Save Changes',
              onCancel: () => Navigator.pop(dialogContext),
              onConfirm: () async {
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
                    const SnackBar(content: Text('Site updated successfully.')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to update Site: $e')),
                  );
                }
              },
              content: _SiteFormContent(
                nameController: nameController,
                descriptionController: descriptionController,
                selectedImage: selectedImage,
                existingImageUrl:
                    (site['image'] != null &&
                        site['image'].toString().isNotEmpty)
                    ? 'http://98.88.222.75:8000${site['image']}'
                    : null,
                onImagePicked: (img) =>
                    setDialogState(() => selectedImage = img),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════
  // DELETE SITE
  // ══════════════════════════════════════════════════════════

  void _deleteSite(Map<String, dynamic> site) {
    showDialog(
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: FarmTabTheme.alertRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: FarmTabTheme.alertRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Delete Site',
                style: FarmTabTheme.font(
                  size: 16,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textH,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${site['name']}"?\nThis cannot be undone.',
            style: FarmTabTheme.font(
              size: 13,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: FarmTabTheme.font(
                  size: 14,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textM,
                ),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: FarmTabTheme.alertRed,
                foregroundColor: FarmTabTheme.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: Text(
                'Delete',
                style: FarmTabTheme.font(
                  size: 14,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Primary Button
// ─────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(
        label,
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card menu button (edit / delete)
// ─────────────────────────────────────────────────────────────
class _CardMenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardMenuButton({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_vert_rounded,
          size: 17,
          color: FarmTabTheme.textH,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(
                  Icons.edit_rounded,
                  size: 15,
                  color: FarmTabTheme.grove,
                ),
                const SizedBox(width: 10),
                Text(
                  'Edit Site',
                  style: FarmTabTheme.font(
                    size: 13,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textH,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 15,
                  color: FarmTabTheme.alertRed,
                ),
                const SizedBox(width: 10),
                Text(
                  'Delete Site',
                  style: FarmTabTheme.font(
                    size: 13,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.alertRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared dialog shell
// ─────────────────────────────────────────────────────────────
class _FarmDialog extends StatelessWidget {
  final String title;
  final String confirmLabel;
  final String? errorMessage;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Widget content;

  const _FarmDialog({
    required this.title,
    required this.confirmLabel,
    this.errorMessage,
    required this.onCancel,
    required this.onConfirm,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    final isMobile = screenSize.width < 600;

    final availableHeight = screenSize.height - viewInsets.bottom;

    final dialogWidth = isMobile ? screenSize.width - 32 : 520.0;

    final dialogMaxHeight = (availableHeight - 48).clamp(320.0, 720.0);

    return Dialog(
      backgroundColor: FarmTabTheme.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─────────────────────────────────────────
            // TITLE
            // ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: FarmTabTheme.font(
                    size: 17,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),
              ),
            ),

            // ─────────────────────────────────────────
            // CONTENT
            // ─────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
                child: content,
              ),
            ),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorMessage!,
                    style: FarmTabTheme.font(
                      size: 12,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.alertRed,
                    ),
                  ),
                ),
              ),

            // ─────────────────────────────────────────
            // ACTIONS
            // ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FarmTabTheme.textM,
                        side: const BorderSide(color: FarmTabTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FarmTabTheme.grove,
                        foregroundColor: FarmTabTheme.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Site form (shared by Add & Edit)
// ─────────────────────────────────────────────────────────────
class _SiteFormContent extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final XFile? selectedImage;
  final String? existingImageUrl;
  final ValueChanged<XFile> onImagePicked;

  const _SiteFormContent({
    required this.nameController,
    required this.descriptionController,
    required this.selectedImage,
    required this.existingImageUrl,
    required this.onImagePicked,
  });

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: FarmTabTheme.font(
      size: 13,
      weight: FontWeight.w400,
      color: FarmTabTheme.textM,
    ),
    filled: true,
    fillColor: const Color(0xFFF7F7F7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
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
      borderSide: const BorderSide(color: FarmTabTheme.fern, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final hasNewImage = selectedImage != null;
    final hasExisting =
        existingImageUrl != null && existingImageUrl!.isNotEmpty;
    final showImage = hasNewImage || hasExisting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        const _FieldLabel('Site Name'),
        const SizedBox(height: 6),
        TextField(
          controller: nameController,
          style: FarmTabTheme.font(
            size: 14,
            weight: FontWeight.w400,
            color: FarmTabTheme.textH,
          ),
          decoration: _fieldDecoration('e.g. Ladang Hijau'),
        ),

        const SizedBox(height: 14),

        // Description
        const _FieldLabel('Description'),
        const SizedBox(height: 6),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          style: FarmTabTheme.font(
            size: 14,
            weight: FontWeight.w400,
            color: FarmTabTheme.textH,
          ),
          decoration: _fieldDecoration('Optional'),
        ),

        const SizedBox(height: 18),

        // Image
        const _FieldLabel('Site Image'),
        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 140,
            width: double.infinity,
            color: const Color(0xFFF2F2F2),
            child: showImage
                ? (hasNewImage
                      ? Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Image.network(
                          existingImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: FarmTabTheme.textM,
                              size: 28,
                            ),
                          ),
                        ))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
            onPressed: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) onImagePicked(image);
            },
            icon: const Icon(Icons.photo_library_rounded, size: 15),
            label: Text(
              showImage ? 'Change Image' : 'Select Image',
              style: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w500,
                color: FarmTabTheme.grove,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: FarmTabTheme.grove,
              side: const BorderSide(color: FarmTabTheme.fern),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),

        const SizedBox(height: 2),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Field label
// ─────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FarmTabTheme.font(
        size: 13,
        weight: FontWeight.w500,
        color: FarmTabTheme.textH,
      ),
    );
  }
}
