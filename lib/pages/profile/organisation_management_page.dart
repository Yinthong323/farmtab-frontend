import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/organisation_service.dart';
import '../../services/site_service.dart';
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
  static const Color amber = Color(0xFFF4A261);

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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static InputDecoration fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: font(size: 13, weight: FontWeight.w500, color: textM),
      hintStyle: font(size: 13, weight: FontWeight.w400, color: textM),
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
    );
  }
}

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

  // ── Farm stats (Sites / Shelves count) ─────────────────────
  final SiteService _siteService = SiteService();
  final ShelfService _shelfService = ShelfService();

  int? _totalSites;
  int? _totalShelves;
  bool _isLoadingFarmStats = true;

  @override
  void initState() {
    super.initState();

    _loadMembers();
    _loadFarmStats();

    if (widget.organisation['role'] == 'ADMIN') {
      _loadJoinRequests();
    }
  }

  // ------------------------------------------------------------
  // Farm stats — total sites, and total shelves across all sites.
  // ------------------------------------------------------------
  Future<void> _loadFarmStats() async {
    setState(() {
      _isLoadingFarmStats = true;
    });

    try {
      final sites = await _siteService.getSites(
        organisationId: widget.organisation['id'],
      );

      int shelfCount = 0;

      for (final site in sites) {
        try {
          final shelves = await _shelfService.getShelves(siteId: site['id']);
          shelfCount += shelves.length;
        } catch (_) {
          // If one site's shelves fail to load, skip it rather than
          // failing the whole stats card.
        }
      }

      if (!mounted) return;

      setState(() {
        _totalSites = sites.length;
        _totalShelves = shelfCount;
        _isLoadingFarmStats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingFarmStats = false;
      });
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: FarmTabTheme.white,
        appBar: _buildAppBar(),
        body: TabBarView(
          children: [_buildOrganisationTab(), _buildMembersTab()],
        ),
      ),
    );
  }

  // ── APP BAR (gradient + embedded pill tab switcher) ─────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 3,
      shadowColor: FarmTabTheme.fern.withOpacity(0.35),
      scrolledUnderElevation: 3,
      centerTitle: false,
      titleSpacing: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      iconTheme: const IconThemeData(color: FarmTabTheme.white),
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
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
        'Organisation',
        style: FarmTabTheme.font(
          size: 18,
          weight: FontWeight.w700,
          color: FarmTabTheme.white,
          letterSpacing: -0.2,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Container(
            height: 44,
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
                      Icon(Icons.business_rounded, size: 15),
                      SizedBox(width: 6),
                      Text('Organisation'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.people_rounded, size: 15),
                      SizedBox(width: 6),
                      Text('Members'),
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
  // ORGANISATION TAB
  // ============================================================

  Widget _buildOrganisationTab() {
    final role = widget.organisation['role'] ?? 'STAFF';
    final isAdmin = role == 'ADMIN';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero — logo on the left, name on the right
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FarmTabTheme.fern, FarmTabTheme.grove],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: FarmTabTheme.fern.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.business_rounded,
                  size: 26,
                  color: FarmTabTheme.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.organisation['name'] ?? 'Organisation',
                  style: FarmTabTheme.font(
                    size: 19,
                    weight: FontWeight.w800,
                    color: FarmTabTheme.textH,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Farm Information (real counts)
          _sectionLabel('Farm Information'),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.location_on_rounded,
                  title: 'Sites',
                  value: _isLoadingFarmStats
                      ? null
                      : (_totalSites?.toString() ?? '--'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.view_module_rounded,
                  title: 'Shelves',
                  value: _isLoadingFarmStats
                      ? null
                      : (_totalShelves?.toString() ?? '--'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // ── Details
          _sectionLabel('Details'),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: FarmTabTheme.cardDecoration,
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.notes_rounded,
                  title: 'Description',
                  value: widget.organisation['description'] ?? 'No description',
                ),
                const Divider(color: FarmTabTheme.border, height: 1),
                _buildInfoTile(
                  icon: Icons.language_rounded,
                  title: 'Website',
                  value: widget.organisation['website'] ?? 'Not provided',
                ),
                const Divider(color: FarmTabTheme.border, height: 1),
                _buildInfoTile(
                  icon: Icons.phone_rounded,
                  title: 'Phone',
                  value: widget.organisation['phone_number'] ?? 'Not provided',
                ),
                const Divider(color: FarmTabTheme.border, height: 1),
                _buildInfoTile(
                  icon: Icons.category_rounded,
                  title: 'Organisation Type',
                  value: widget.organisation['organisation_type'] ?? 'Unknown',
                  isLast: true,
                ),
              ],
            ),
          ),

          if (isAdmin) ...[
            const SizedBox(height: 22),

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
                  onTap: _editOrganisation,
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: FarmTabTheme.white,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Edit Organisation',
                            style: FarmTabTheme.font(
                              size: 14,
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
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String? value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: FarmTabTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: FarmTabTheme.mist,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: FarmTabTheme.grove),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w500,
                color: FarmTabTheme.textM,
              ),
            ),
          ),
          value == null
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: FarmTabTheme.grove,
                  ),
                )
              : Text(
                  value,
                  style: FarmTabTheme.font(
                    size: 20,
                    weight: FontWeight.w800,
                    color: FarmTabTheme.textH,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: FarmTabTheme.textM),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FarmTabTheme.font(
                    size: 12,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textM,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: FarmTabTheme.font(
                    size: 14.5,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.textH,
                  ),
                ),
              ],
            ),
          ),
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
          backgroundColor: FarmTabTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Organisation',
            style: FarmTabTheme.font(
              size: 16.5,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.textH,
                    ),
                    decoration: FarmTabTheme.fieldDecoration(
                      'Organisation Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Organisation name is required.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textH,
                    ),
                    decoration: FarmTabTheme.fieldDecoration('Description'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: websiteController,
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textH,
                    ),
                    decoration: FarmTabTheme.fieldDecoration(
                      'Website',
                      hint: 'https://example.com',
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: phoneController,
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textH,
                    ),
                    decoration: FarmTabTheme.fieldDecoration('Phone Number'),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: organisationType,
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.textH,
                    ),
                    decoration: FarmTabTheme.fieldDecoration(
                      'Organisation Type',
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
              style: FarmTabTheme.primaryButton,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(
                'Save',
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

  // ============================================================
  // MEMBERS TAB
  // ============================================================

  Widget _buildMembersTab() {
    final admins = _members
        .where((member) => member['role'] == 'ADMIN')
        .toList();

    final staff = _members
        .where((member) => member['role'] == 'STAFF')
        .toList();

    return RefreshIndicator(
      color: FarmTabTheme.grove,
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
                child: CircularProgressIndicator(
                  color: FarmTabTheme.grove,
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            if (admins.isNotEmpty) ...[
              _sectionLabel('Administrators'),

              const SizedBox(height: 10),

              ...admins.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildMemberCard(m),
                ),
              ),

              const SizedBox(height: 20),
            ],

            if (staff.isNotEmpty) ...[
              _sectionLabel('Staff'),

              const SizedBox(height: 10),

              ...staff.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildMemberCard(m),
                ),
              ),

              const SizedBox(height: 20),
            ],

            if (admins.isEmpty && staff.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'No members found.',
                    style: FarmTabTheme.font(
                      size: 13.5,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ),
              ),
          ],

          // =====================================================
          // JOIN REQUESTS
          // =====================================================
          if (widget.organisation['role'] == 'ADMIN') ...[
            const SizedBox(height: 10),
            const Divider(color: FarmTabTheme.border, height: 30),

            _sectionLabel('Join Requests'),

            const SizedBox(height: 10),

            if (_isLoadingRequests)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: FarmTabTheme.grove,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_joinRequests.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'No pending join requests.',
                  textAlign: TextAlign.center,
                  style: FarmTabTheme.font(
                    size: 13.5,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),
              )
            else
              ..._joinRequests.map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildJoinRequestCard(request),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberCard(dynamic member) {
    final isAdmin = member['role'] == 'ADMIN';
    final isCurrentUser = member['user_id'] == widget.user['id'];

    final isOrganisationAdmin = widget.organisation['role'] == 'ADMIN';

    return Container(
      decoration: FarmTabTheme.cardDecoration,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isAdmin ? FarmTabTheme.mist : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_rounded,
              size: 20,
              color: isAdmin ? FarmTabTheme.grove : FarmTabTheme.textM,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['username'] ?? 'Unknown user',
                  style: FarmTabTheme.font(
                    size: 14.5,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member['email'] ?? '',
                  style: FarmTabTheme.font(
                    size: 12.5,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          if (isOrganisationAdmin && !isCurrentUser)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_vert_rounded,
                size: 19,
                color: FarmTabTheme.textM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                        isAdmin
                            ? Icons.person_rounded
                            : Icons.admin_panel_settings_rounded,
                        size: 16,
                        color: FarmTabTheme.grove,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isAdmin ? 'Make Staff' : 'Make Admin',
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
                  value: 'remove',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_remove_rounded,
                        size: 16,
                        color: FarmTabTheme.alertRed,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Remove Member',
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
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isAdmin ? FarmTabTheme.mist : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                member['role'] ?? 'STAFF',
                style: FarmTabTheme.font(
                  size: 11,
                  weight: FontWeight.w700,
                  color: isAdmin ? FarmTabTheme.grove : FarmTabTheme.textM,
                ),
              ),
            ),
        ],
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
          backgroundColor: FarmTabTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isAdmin ? 'Change Role' : 'Make Admin',
            style: FarmTabTheme.font(
              size: 16,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
          content: Text(
            'Are you sure you want to $actionText?',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
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
              style: FarmTabTheme.primaryButton,
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Confirm',
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
                  Icons.person_remove_rounded,
                  color: FarmTabTheme.alertRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Remove Member',
                style: FarmTabTheme.font(
                  size: 16,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove $username from this organisation?',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
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
                Navigator.pop(context, true);
              },
              child: Text(
                'Remove',
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

  Widget _buildJoinRequestCard(Map<String, dynamic> request) {
    final username = request['username'] ?? 'Unknown User';
    final email = request['email'] ?? '';
    final userId = request['user_id'];

    return Container(
      decoration: FarmTabTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: FarmTabTheme.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 19,
                  color: FarmTabTheme.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: FarmTabTheme.font(
                        size: 14.5,
                        weight: FontWeight.w700,
                        color: FarmTabTheme.textH,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: FarmTabTheme.font(
                        size: 12.5,
                        weight: FontWeight.w400,
                        color: FarmTabTheme.textM,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectJoinRequest(userId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FarmTabTheme.alertRed,
                    side: const BorderSide(color: Color(0xFFF4B9BE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: Text(
                    'Reject',
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.alertRed,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approveJoinRequest(userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FarmTabTheme.grove,
                    foregroundColor: FarmTabTheme.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Approve',
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
        ],
      ),
    );
  }
}
