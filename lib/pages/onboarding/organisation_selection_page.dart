// import 'package:flutter/material.dart';

// import 'organisation_page.dart';
// import 'pending_request_page.dart';
// import '../../services/organisation_service.dart';

// class OrganisationSelectionPage extends StatefulWidget {
//   final String accessToken;

//   const OrganisationSelectionPage({super.key, required this.accessToken});

//   @override
//   State<OrganisationSelectionPage> createState() =>
//       _OrganisationSelectionPageState();
// }

// class _OrganisationSelectionPageState extends State<OrganisationSelectionPage> {
//   final TextEditingController _searchController = TextEditingController();

//   List<dynamic> _organisations = [];
//   List<dynamic> _filteredOrganisations = [];

//   dynamic _selectedOrganisation;

//   bool _isLoading = true;
//   bool _isRequesting = false;

//   @override
//   void initState() {
//     super.initState();

//     _loadOrganisations();

//     _searchController.addListener(_filterOrganisations);
//   }

//   Future<void> _loadOrganisations() async {
//     try {
//       final organisations = await OrganisationService().getSharedOrganisations(
//         setupToken: widget.accessToken,
//       );

//       if (!mounted) return;

//       setState(() {
//         _organisations = organisations;
//         _filteredOrganisations = organisations;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       showMessage(e.toString().replaceFirst('Exception: ', ''));
//     }
//   }

//   void _filterOrganisations() {
//     final searchText = _searchController.text.trim().toLowerCase();

//     setState(() {
//       if (searchText.isEmpty) {
//         _filteredOrganisations = _organisations;
//       } else {
//         _filteredOrganisations = _organisations.where((organisation) {
//           final name = organisation['name'].toString().toLowerCase();

//           return name.contains(searchText);
//         }).toList();
//       }
//     });
//   }

//   Future<void> _requestToJoin() async {
//     if (_selectedOrganisation == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an organisation first.')),
//       );
//       return;
//     }

//     final organisationId = _selectedOrganisation['id'];

//     try {
//       final result = await OrganisationService().requestToJoin(
//         organisationId: organisationId,
//         setupToken: widget.accessToken,
//       );

//       if (!mounted) return;

//       await showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('Request Submitted'),
//             content: Text(
//               result['message'] ?? 'Your request has been submitted and is waiting for approval.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         },
//       );

//       if (!mounted) return;

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => PendingRequestPage(
//             user: {'access_token': widget.accessToken},
//             organisation: _selectedOrganisation,
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   void _showOrganisationInfo(Map<String, dynamic> organisation) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(organisation['name'] ?? 'Organisation'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Description',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 5),

//                 Text(organisation['description'] ?? 'No description provided.'),

//                 const SizedBox(height: 20),

//                 if (organisation['website'] != null &&
//                     organisation['website'].toString().isNotEmpty) ...[
//                   const Text(
//                     'Website',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 5),

//                   Text(organisation['website']),

//                   const SizedBox(height: 20),
//                 ],

//                 if (organisation['phone_number'] != null &&
//                     organisation['phone_number'].toString().isNotEmpty) ...[
//                   const Text(
//                     'Phone Number',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 5),

//                   Text(organisation['phone_number']),
//                 ],
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _createOwnOrganisation() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => OrganisationPage(setupToken: widget.accessToken),
//       ),
//     );
//   }

//   void showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Choose Organisation')),

//       body: Padding(
//         padding: const EdgeInsets.all(20),

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,

//           children: [
//             const Text(
//               'Choose how you want to use FarmTab',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 8),

//             const Text(
//               'Join an existing organisation or create your own.',
//               style: TextStyle(color: Colors.grey),
//             ),

//             const SizedBox(height: 24),

//             TextField(
//               controller: _searchController,

//               decoration: InputDecoration(
//                 labelText: 'Search shared organisations',
//                 hintText: 'Enter organisation name',

//                 prefixIcon: const Icon(Icons.search),

//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),

//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                         },
//                       )
//                     : null,
//               ),
//             ),

//             const SizedBox(height: 16),

//             Expanded(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _filteredOrganisations.isEmpty
//                   ? const Center(child: Text('No shared organisations found.'))
//                   : ListView.builder(
//                       itemCount: _filteredOrganisations.length,

//                       itemBuilder: (context, index) {
//                         final organisation = _filteredOrganisations[index];

//                         final isSelected =
//                             _selectedOrganisation != null &&
//                             _selectedOrganisation['id'] == organisation['id'];

//                         return Card(
//                           child: ListTile(
//                             leading: const CircleAvatar(
//                               child: Icon(Icons.business),
//                             ),

//                             title: Text(
//                               organisation['name'],
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),

//                             subtitle: Text(
//                               organisation['description'] ?? '',
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),

//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.info_outline),
//                                   onPressed: () {
//                                     _showOrganisationInfo(
//                                       Map<String, dynamic>.from(organisation),
//                                     );
//                                   },
//                                 ),

//                                 if (isSelected)
//                                   const Icon(
//                                     Icons.check_circle,
//                                     color: Colors.green,
//                                   ),
//                               ],
//                             ),

//                             selected: isSelected,

//                             onTap: () {
//                               setState(() {
//                                 _selectedOrganisation = organisation;
//                               });
//                             },
//                           ),
//                         );
//                       },
//                     ),
//             ),

//             const SizedBox(height: 12),

//             SizedBox(
//               height: 50,

//               child: ElevatedButton(
//                 onPressed: _isRequesting ? null : _requestToJoin,

//                 child: _isRequesting
//                     ? const SizedBox(
//                         height: 24,
//                         width: 24,
//                         child: CircularProgressIndicator(),
//                       )
//                     : const Text(
//                         'Request to Join',
//                         style: TextStyle(fontSize: 16),
//                       ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             SizedBox(
//               height: 50,

//               child: OutlinedButton(
//                 onPressed: _isRequesting ? null : _createOwnOrganisation,

//                 child: const Text(
//                   'Create Your Own Organisation',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'organisation_page.dart';
import 'pending_request_page.dart';
import '../../services/organisation_service.dart';

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
}

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
        setupToken: widget.accessToken,
      );

      if (!mounted) return;

      await showDialog(
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
                    color: FarmTabTheme.mist,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: FarmTabTheme.grove,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Request Submitted',
                    style: FarmTabTheme.font(
                      size: 16.5,
                      weight: FontWeight.w700,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              result['message'] ??
                  'Your request has been submitted and is waiting for '
                      'approval.',
              style: FarmTabTheme.font(
                size: 13.5,
                weight: FontWeight.w400,
                color: FarmTabTheme.textB,
                height: 1.5,
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FarmTabTheme.grove,
                  foregroundColor: FarmTabTheme.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
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
                  color: FarmTabTheme.mist,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.business_rounded,
                  size: 17,
                  color: FarmTabTheme.grove,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  organisation['name'] ?? 'Organisation',
                  style: FarmTabTheme.font(
                    size: 16.5,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBlock(
                  'Description',
                  organisation['description'] ?? 'No description provided.',
                ),

                if (organisation['website'] != null &&
                    organisation['website'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoBlock('Website', organisation['website']),
                ],

                if (organisation['phone_number'] != null &&
                    organisation['phone_number'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoBlock('Phone Number', organisation['phone_number']),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textM,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FarmTabTheme.font(
            size: 12,
            weight: FontWeight.w600,
            color: FarmTabTheme.textM,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: FarmTabTheme.font(
            size: 14,
            weight: FontWeight.w500,
            color: FarmTabTheme.textH,
          ),
        ),
      ],
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose how you want to use FarmTab',
              style: FarmTabTheme.font(
                size: 20,
                weight: FontWeight.w800,
                color: FarmTabTheme.textH,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Join an existing organisation or create your own.',
              style: FarmTabTheme.font(
                size: 13.5,
                weight: FontWeight.w400,
                color: FarmTabTheme.textM,
              ),
            ),

            const SizedBox(height: 20),

            Container(
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
                decoration: InputDecoration(
                  hintText: 'Search organisation name…',
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
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
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

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: FarmTabTheme.grove,
                        strokeWidth: 2,
                      ),
                    )
                  : _filteredOrganisations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.business_outlined,
                              size: 28,
                              color: FarmTabTheme.textM,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No shared organisations found',
                            style: FarmTabTheme.font(
                              size: 14,
                              weight: FontWeight.w600,
                              color: FarmTabTheme.textH,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 4),
                      itemCount: _filteredOrganisations.length,
                      itemBuilder: (context, index) {
                        final organisation = _filteredOrganisations[index];

                        final isSelected =
                            _selectedOrganisation != null &&
                            _selectedOrganisation['id'] == organisation['id'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildOrganisationCard(
                            organisation,
                            isSelected,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 14),

            // ── Request to Join — primary gradient button
            Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [FarmTabTheme.grove, FarmTabTheme.fern],
                ),
                boxShadow: [
                  BoxShadow(
                    color: FarmTabTheme.fern.withOpacity(0.3),
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
                  onTap: _isRequesting ? null : _requestToJoin,
                  child: Center(
                    child: _isRequesting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: FarmTabTheme.white,
                            ),
                          )
                        : Text(
                            'Request to Join',
                            style: FarmTabTheme.font(
                              size: 14.5,
                              weight: FontWeight.w600,
                              color: FarmTabTheme.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Create Your Own Organisation — outlined button
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: _isRequesting ? null : _createOwnOrganisation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: FarmTabTheme.grove,
                  side: const BorderSide(color: FarmTabTheme.fern),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create Your Own Organisation',
                  style: FarmTabTheme.font(
                    size: 14.5,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.grove,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 3,
      shadowColor: FarmTabTheme.fern.withOpacity(0.35),
      centerTitle: false,
      automaticallyImplyLeading: false,
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
        'Choose Organisation',
        style: FarmTabTheme.font(
          size: 17,
          weight: FontWeight.w700,
          color: FarmTabTheme.white,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // ============================================================
  // ORGANISATION CARD
  // ============================================================

  Widget _buildOrganisationCard(
    Map<String, dynamic> organisation,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrganisation = organisation;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: FarmTabTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? FarmTabTheme.fern : FarmTabTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? FarmTabTheme.mist : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.business_rounded,
                size: 21,
                color: isSelected ? FarmTabTheme.grove : FarmTabTheme.textM,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organisation['name'],
                    style: FarmTabTheme.font(
                      size: 14.5,
                      weight: FontWeight.w700,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    organisation['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FarmTabTheme.font(
                      size: 12.5,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  _showOrganisationInfo(
                    Map<String, dynamic>.from(organisation),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 19,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ),
            ),

            if (isSelected) ...[
              const SizedBox(width: 2),
              const Icon(
                Icons.check_circle_rounded,
                size: 22,
                color: FarmTabTheme.grove,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
