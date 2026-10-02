// import 'package:flutter/material.dart';

// import 'organisation_selection_page.dart';
// import '../auth/login_page.dart';
// import '../home/home_page.dart';
// import '../../services/organisation_service.dart';

// class PendingRequestPage extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final Map<String, dynamic> organisation;

//   const PendingRequestPage({
//     super.key,
//     required this.user,
//     required this.organisation,
//   });

//   @override
//   State<PendingRequestPage> createState() => _PendingRequestPageState();
// }

// class _PendingRequestPageState extends State<PendingRequestPage> {
//   bool _isLoading = false;

//   Future<void> _checkStatus() async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final organisationId = widget.organisation['id'];

//       final result = await OrganisationService().getJoinRequestStatus(
//         organisationId: organisationId,
//       );

//       if (!mounted) return;

//       final status = result['membership_status'];

//       if (status == 'APPROVED') {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (_) => HomePage(
//               user: widget.user,
//               organisation: {
//                 ...widget.organisation,
//                 'id': result['organisation_id'],
//                 'name': result['organisation_name'],
//                 'role': result['role'],
//               },
//             ),
//           ),
//           (route) => false,
//         );

//         return;
//       }

//       if (status == 'PENDING') {
//         setState(() {
//           _isLoading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Your request is still waiting for approval.'),
//           ),
//         );

//         return;
//       }

//       if (status == 'REJECTED') {
//         setState(() {
//           _isLoading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Your request was not approved.')),
//         );

//         return;
//       }

//       if (status == 'NONE') {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => OrganisationSelectionPage(
//               accessToken: widget.user['access_token'],
//             ),
//           ),
//         );

//         return;
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   Future<void> _cancelRequest() async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final organisationId = widget.organisation['id'];

//       await OrganisationService().cancelJoinRequest(
//         organisationId: organisationId,
//       );

//       if (!mounted) return;

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => OrganisationSelectionPage(
//             accessToken: widget.user['access_token'],
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   void _logout() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final organisationName = widget.organisation['name'] ?? 'this organisation';

//     return Scaffold(
//       appBar: AppBar(title: const Text('Pending Request')),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 30),

//             const Icon(Icons.hourglass_top, size: 70, color: Colors.orange),

//             const SizedBox(height: 24),

//             const Text(
//               'Request Pending',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 16),

//             Text(
//               'Your request to join $organisationName '
//               'has been submitted and is waiting for approval.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),

//             const Spacer(),

//             SizedBox(
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _checkStatus,
//                 child: _isLoading
//                     ? const SizedBox(
//                         width: 22,
//                         height: 22,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text(
//                         'Check Status',
//                         style: TextStyle(fontSize: 16),
//                       ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             SizedBox(
//               height: 50,
//               child: OutlinedButton(
//                 onPressed: _isLoading ? null : _cancelRequest,
//                 child: const Text(
//                   'Cancel Request',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             SizedBox(
//               height: 50,
//               child: OutlinedButton(
//                 onPressed: _isLoading ? null : _logout,
//                 child: const Text('Logout', style: TextStyle(fontSize: 16)),
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

import 'organisation_selection_page.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';
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
}

class PendingRequestPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const PendingRequestPage({
    super.key,
    required this.user,
    required this.organisation,
  });

  @override
  State<PendingRequestPage> createState() => _PendingRequestPageState();
}

class _PendingRequestPageState extends State<PendingRequestPage> {
  bool _isLoading = false;

  Future<void> _checkStatus() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final organisationId = widget.organisation['id'];

      final result = await OrganisationService().getJoinRequestStatus(
        organisationId: organisationId,
      );

      if (!mounted) return;

      final status = result['membership_status'];

      if (status == 'APPROVED') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              user: widget.user,
              organisation: {
                ...widget.organisation,
                'id': result['organisation_id'],
                'name': result['organisation_name'],
                'role': result['role'],
              },
            ),
          ),
          (route) => false,
        );

        return;
      }

      if (status == 'PENDING') {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your request is still waiting for approval.'),
          ),
        );

        return;
      }

      if (status == 'REJECTED') {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your request was not approved.')),
        );

        return;
      }

      if (status == 'NONE') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrganisationSelectionPage(
              accessToken: widget.user['access_token'],
            ),
          ),
        );

        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _cancelRequest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final organisationId = widget.organisation['id'];

      await OrganisationService().cancelJoinRequest(
        organisationId: organisationId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrganisationSelectionPage(
            accessToken: widget.user['access_token'],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final organisationName = widget.organisation['name'] ?? 'this organisation';

    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FarmTabTheme.amber,
                        FarmTabTheme.amber.withOpacity(0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: FarmTabTheme.amber.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 44,
                    color: FarmTabTheme.white,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Text(
                'Request Pending',
                textAlign: TextAlign.center,
                style: FarmTabTheme.font(
                  size: 24,
                  weight: FontWeight.w800,
                  color: FarmTabTheme.textH,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 12),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Your request to join ',
                      style: FarmTabTheme.font(
                        size: 14.5,
                        weight: FontWeight.w400,
                        color: FarmTabTheme.textM,
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: organisationName,
                      style: FarmTabTheme.font(
                        size: 14.5,
                        weight: FontWeight.w700,
                        color: FarmTabTheme.textB,
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' has been submitted and is waiting for '
                          'approval.',
                      style: FarmTabTheme.font(
                        size: 14.5,
                        weight: FontWeight.w400,
                        color: FarmTabTheme.textM,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // ── Check Status — primary gradient button
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
                    onTap: _isLoading ? null : _checkStatus,
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FarmTabTheme.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: FarmTabTheme.white,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'Check Status',
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

              const SizedBox(height: 12),

              // ── Cancel Request — outlined button
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancelRequest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FarmTabTheme.grove,
                    side: const BorderSide(color: FarmTabTheme.fern),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel Request',
                    style: FarmTabTheme.font(
                      size: 14.5,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.grove,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Logout — muted text button
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: _isLoading ? null : _logout,
                  child: Text(
                    'Logout',
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
