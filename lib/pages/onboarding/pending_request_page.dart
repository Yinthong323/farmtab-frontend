import 'package:flutter/material.dart';

import 'organisation_selection_page.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';
import '../../services/organisation_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final organisationName = widget.organisation['name'] ?? 'this organisation';

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Request')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            const Icon(Icons.hourglass_top, size: 70, color: Colors.orange),

            const SizedBox(height: 24),

            const Text(
              'Request Pending',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              'Your request to join $organisationName '
              'has been submitted and is waiting for approval.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const Spacer(),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkStatus,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Check Status',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _cancelRequest,
                child: const Text(
                  'Cancel Request',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _logout,
                child: const Text('Logout', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
