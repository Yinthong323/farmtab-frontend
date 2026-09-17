import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/shelf_service.dart';

class EditShelfPage extends StatefulWidget {
  final Map<String, dynamic> shelf;
  final Map<String, dynamic> organisation;

  const EditShelfPage({
    super.key,
    required this.shelf,
    required this.organisation,
  });

  @override
  State<EditShelfPage> createState() => _EditShelfPageState();
}

class _EditShelfPageState extends State<EditShelfPage>
    with SingleTickerProviderStateMixin {
  final ShelfService _shelfService = ShelfService();
  final ImagePicker _imagePicker = ImagePicker();

  late TabController _tabController;

  // Shelf information controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cropTypeController;
  late TextEditingController _deviceSerialController;

  // Sensor threshold controllers
  late TextEditingController _phMinController;
  late TextEditingController _phMaxController;

  late TextEditingController _ecMinController;
  late TextEditingController _ecMaxController;

  late TextEditingController _orpMinController;
  late TextEditingController _orpMaxController;

  late TextEditingController _temperatureMinController;
  late TextEditingController _temperatureMaxController;

  XFile? _selectedImage;

  bool _isSavingInformation = false;
  bool _isSavingThresholds = false;

  static const String baseUrl = 'http://98.88.222.75:8000';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // =========================================================
    // Shelf Information
    // =========================================================

    _nameController = TextEditingController(text: widget.shelf['name'] ?? '');

    _descriptionController = TextEditingController(
      text: widget.shelf['description'] ?? '',
    );

    _cropTypeController = TextEditingController(
      text: widget.shelf['crop_type'] ?? '',
    );

    _deviceSerialController = TextEditingController(
      text: widget.shelf['device_serial_number'] ?? '',
    );

    // =========================================================
    // Sensor Thresholds
    // =========================================================

    _phMinController = TextEditingController(
      text: '${widget.shelf['ph_min'] ?? ''}',
    );

    _phMaxController = TextEditingController(
      text: '${widget.shelf['ph_max'] ?? ''}',
    );

    _ecMinController = TextEditingController(
      text: '${widget.shelf['ec_min'] ?? ''}',
    );

    _ecMaxController = TextEditingController(
      text: '${widget.shelf['ec_max'] ?? ''}',
    );

    _orpMinController = TextEditingController(
      text: '${widget.shelf['orp_min'] ?? ''}',
    );

    _orpMaxController = TextEditingController(
      text: '${widget.shelf['orp_max'] ?? ''}',
    );

    _temperatureMinController = TextEditingController(
      text: '${widget.shelf['temperature_min'] ?? ''}',
    );

    _temperatureMaxController = TextEditingController(
      text: '${widget.shelf['temperature_max'] ?? ''}',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    _nameController.dispose();
    _descriptionController.dispose();
    _cropTypeController.dispose();
    _deviceSerialController.dispose();

    _phMinController.dispose();
    _phMaxController.dispose();

    _ecMinController.dispose();
    _ecMaxController.dispose();

    _orpMinController.dispose();
    _orpMaxController.dispose();

    _temperatureMinController.dispose();
    _temperatureMaxController.dispose();

    super.dispose();
  }

  // =========================================================
  // Pick New Image
  // =========================================================

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  // =========================================================
  // Save Shelf Information
  // =========================================================

  Future<void> _saveInformation() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final cropType = _cropTypeController.text.trim();
    final deviceSerial = _deviceSerialController.text.trim();

    if (name.isEmpty) {
      _showMessage('Shelf name is required.');
      return;
    }

    if (cropType.isEmpty) {
      _showMessage('Crop type is required.');
      return;
    }

    if (deviceSerial.isEmpty) {
      _showMessage('Device serial number is required.');
      return;
    }

    setState(() {
      _isSavingInformation = true;
    });

    try {
      final result = await _shelfService.updateShelf(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
        name: name,
        description: description.isEmpty ? null : description,
        cropType: cropType,
        deviceSerialNumber: deviceSerial,
        imagePath: _selectedImage?.path,
      );

      if (!mounted) return;

      // =====================================================
      // Update the existing shelf Map
      // =====================================================

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

      if (result['device_serial_number'] != null) {
        widget.shelf['device_serial_number'] = result['device_serial_number'];
      }

      if (result['image'] != null) {
        widget.shelf['image'] = result['image'];
      }

      _showMessage('Shelf information updated successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingInformation = false;
        });
      }
    }
  }

  // =========================================================
  // Save Sensor Thresholds
  // =========================================================

  Future<void> _saveThresholds() async {
    final phMin = double.tryParse(_phMinController.text.trim());

    final phMax = double.tryParse(_phMaxController.text.trim());

    final ecMin = double.tryParse(_ecMinController.text.trim());

    final ecMax = double.tryParse(_ecMaxController.text.trim());

    final orpMin = double.tryParse(_orpMinController.text.trim());

    final orpMax = double.tryParse(_orpMaxController.text.trim());

    final temperatureMin = double.tryParse(
      _temperatureMinController.text.trim(),
    );

    final temperatureMax = double.tryParse(
      _temperatureMaxController.text.trim(),
    );

    // ========================================================
    // Validate numbers
    // ========================================================

    if (phMin == null || phMax == null) {
      _showMessage('Please enter valid pH values.');
      return;
    }

    if (ecMin == null || ecMax == null) {
      _showMessage('Please enter valid EC values.');
      return;
    }

    if (orpMin == null || orpMax == null) {
      _showMessage('Please enter valid ORP values.');
      return;
    }

    if (temperatureMin == null || temperatureMax == null) {
      _showMessage('Please enter valid temperature values.');
      return;
    }

    // ========================================================
    // Validate ranges
    // ========================================================

    if (phMin >= phMax) {
      _showMessage('pH minimum must be lower than maximum.');
      return;
    }

    if (ecMin >= ecMax) {
      _showMessage('EC minimum must be lower than maximum.');
      return;
    }

    if (orpMin >= orpMax) {
      _showMessage('ORP minimum must be lower than maximum.');
      return;
    }

    if (temperatureMin >= temperatureMax) {
      _showMessage('Temperature minimum must be lower than maximum.');
      return;
    }

    setState(() {
      _isSavingThresholds = true;
    });

    try {
      final result = await _shelfService.updateShelfThresholds(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
        phMin: phMin,
        phMax: phMax,
        ecMin: ecMin,
        ecMax: ecMax,
        orpMin: orpMin,
        orpMax: orpMax,
        temperatureMin: temperatureMin,
        temperatureMax: temperatureMax,
      );

      if (!mounted) return;

      // =====================================================
      // Update the existing shelf Map
      // =====================================================

      final updatedShelf = result['shelf'];

      if (updatedShelf != null) {
        widget.shelf['ph_min'] = updatedShelf['ph_min'];
        widget.shelf['ph_max'] = updatedShelf['ph_max'];

        widget.shelf['ec_min'] = updatedShelf['ec_min'];
        widget.shelf['ec_max'] = updatedShelf['ec_max'];

        widget.shelf['orp_min'] = updatedShelf['orp_min'];
        widget.shelf['orp_max'] = updatedShelf['orp_max'];

        widget.shelf['temperature_min'] = updatedShelf['temperature_min'];

        widget.shelf['temperature_max'] = updatedShelf['temperature_max'];

        widget.shelf['updated_at'] = updatedShelf['updated_at'];
      }

      _showMessage('Sensor thresholds updated successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingThresholds = false;
        });
      }
    }
  }

  // =========================================================
  // Message
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Shelf'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Shelf Information'),
            Tab(text: 'Sensor Threshold'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildShelfInformationTab(), _buildSensorThresholdTab()],
      ),
    );
  }

  // =========================================================
  // Shelf Information Tab
  // =========================================================

  Widget _buildShelfInformationTab() {
    final existingImage = widget.shelf['image'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shelf Image',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // New selected image
          // ==================================================
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImage!.path),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            )
          // ==================================================
          // Existing image
          // ==================================================
          else if (existingImage != null && existingImage.toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                '$baseUrl$existingImage',
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 60),
                  );
                },
              ),
            )
          // ==================================================
          // No image
          // ==================================================
          else
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, size: 60),
            ),

          const SizedBox(height: 12),

          // ==================================================
          // Change Image
          // ==================================================
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(
                _selectedImage == null
                    ? 'Change Image'
                    : 'Choose Different Image',
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ==================================================
          // Shelf Name
          // ==================================================
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Shelf Name *',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // ==================================================
          // Description
          // ==================================================
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // ==================================================
          // Crop Type
          // ==================================================
          TextField(
            controller: _cropTypeController,
            decoration: const InputDecoration(
              labelText: 'Crop Type *',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // ==================================================
          // Device Serial Number
          // ==================================================
          TextField(
            controller: _deviceSerialController,
            decoration: const InputDecoration(
              labelText: 'Device Serial Number *',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          // ==================================================
          // Save Shelf Information
          // ==================================================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSavingInformation ? null : _saveInformation,
              child: _isSavingInformation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Shelf Information'),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Sensor Threshold Tab
  // =========================================================

  Widget _buildSensorThresholdTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sensor Threshold',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text('Set the acceptable range for each sensor.'),

          const SizedBox(height: 24),

          // ==================================================
          // pH
          // ==================================================
          const Text(
            'pH',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phMinController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Minimum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phMaxController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Maximum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==================================================
          // EC
          // ==================================================
          const Text(
            'EC (mS/cm)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ecMinController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Minimum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ecMaxController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Maximum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==================================================
          // ORP
          // ==================================================
          const Text(
            'ORP (mV)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _orpMinController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Minimum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _orpMaxController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Maximum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==================================================
          // Temperature
          // ==================================================
          const Text(
            'Temperature (°C)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _temperatureMinController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Minimum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _temperatureMaxController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Maximum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ==================================================
          // Save Thresholds
          // ==================================================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSavingThresholds ? null : _saveThresholds,
              child: _isSavingThresholds
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Sensor Thresholds'),
            ),
          ),
        ],
      ),
    );
  }
}
