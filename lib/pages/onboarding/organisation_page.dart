import 'package:flutter/material.dart';

import '../auth/login_page.dart';
import '../../services/organisation_service.dart';

class OrganisationPage extends StatefulWidget {
  final String setupToken;

  const OrganisationPage({super.key, required this.setupToken});

  @override
  State<OrganisationPage> createState() => _OrganisationPageState();
}

class _OrganisationPageState extends State<OrganisationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();

  String _organisationType = 'PERSONAL';

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _createOrganisation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await OrganisationService().createOrganisation(
        setupToken: widget.setupToken,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        organisationType: _organisationType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Organisation created successfully.',
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organisation Setup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                const Text(
                  'Set Up Your Organisation',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Create an organisation to continue using FarmTab.',
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Organisation Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Organisation name is required.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Organisation Type *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                RadioListTile<String>(
                  title: const Text('Personal'),
                  subtitle: const Text(
                    'Only you can belong to this organisation.',
                  ),
                  value: 'PERSONAL',
                  groupValue: _organisationType,
                  onChanged: (value) {
                    setState(() {
                      _organisationType = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  title: const Text('Shared'),
                  subtitle: const Text('Other users can request to join.'),
                  value: 'SHARED',
                  groupValue: _organisationType,
                  onChanged: (value) {
                    setState(() {
                      _organisationType = value!;
                    });
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createOrganisation,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Create Organisation',
                            style: TextStyle(fontSize: 16),
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
}
