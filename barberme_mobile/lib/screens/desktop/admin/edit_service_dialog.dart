import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/service.dart';
import '../../../services/service_service.dart';

class EditServiceDialog extends StatefulWidget {
  final Service service;

  const EditServiceDialog({
    super.key,
    required this.service,
  });

  @override
  State<EditServiceDialog> createState() =>
      _EditServiceDialogState();
}

class _EditServiceDialogState
    extends State<EditServiceDialog> {
  final ServiceService _serviceService = ServiceService();

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;

  String? _imagePath;
  String? _imageName;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.service.name,
    );

    _descriptionController = TextEditingController(
      text: widget.service.description ?? '',
    );

    _priceController = TextEditingController(
      text: widget.service.defaultPrice.toStringAsFixed(2),
    );

    _durationController = TextEditingController(
      text: widget.service.defaultDurationMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'webp',
      ],
    );

    if (file == null || file.path == null) {
      return;
    }

    setState(() {
      _imagePath = file.path;
      _imageName = file.name;
    });
  }

  void _removeSelectedImage() {
    setState(() {
      _imagePath = null;
      _imageName = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(
      _priceController.text
          .trim()
          .replaceAll(',', '.'),
    );

    final duration = int.tryParse(
      _durationController.text.trim(),
    );

    if (price == null || duration == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _serviceService.updateService(
        serviceId: widget.service.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        durationMinutes: duration,
        isActive: widget.service.isActive,
        imagePath: _imagePath,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildServiceImage() {
    // A new image was selected:
    // show it immediately as a preview.
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(_imagePath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _buildImagePlaceholder();
          },
        ),
      );
    }

    // Otherwise show the existing service image.
    final imageUrl = widget.service.imageUrl?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    final url = imageUrl.startsWith('http')
        ? imageUrl
        : '${ApiConfig.baseUrl}/${imageUrl.replaceFirst(RegExp(r'^/+'), '')}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _buildImagePlaceholder();
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppTheme.accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingImage =
        widget.service.imageUrl?.trim().isNotEmpty == true;

    final hasNewImage =
        _imagePath != null && _imagePath!.isNotEmpty;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(
        28,
        26,
        28,
        0,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        28,
        22,
        28,
        8,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        28,
        12,
        28,
        24,
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit service',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Update service details, price, duration or image.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service name',
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return 'Service name is required.';
                    }

                    if (text.length < 2) {
                      return 'Service name must contain at least 2 characters.';
                    }

                    if (text.length > 100) {
                      return 'Service name must not exceed 100 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.trim().length > 500) {
                      return 'Description must not exceed 500 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          suffixText: 'KM',
                        ),
                        validator: (value) {
                          final price = double.tryParse(
                            (value ?? '')
                                .trim()
                                .replaceAll(',', '.'),
                          );

                          if (price == null) {
                            return 'Enter a valid price.';
                          }

                          if (price <= 0) {
                            return 'Price must be greater than 0.';
                          }

                          if (price > 10000) {
                            return 'Maximum price is 10000 KM.';
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                          suffixText: 'min',
                        ),
                        validator: (value) {
                          final duration = int.tryParse(
                            (value ?? '').trim(),
                          );

                          if (duration == null) {
                            return 'Enter a valid duration.';
                          }

                          if (duration < 1) {
                            return 'Duration must be at least 1 minute.';
                          }

                          if (duration > 1000) {
                            return 'Maximum duration is 1000 minutes.';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                const Text(
                  'Service image',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE5E1DC),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildServiceImage(),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasNewImage
                                  ? _imageName ?? 'New image'
                                  : hasExistingImage
                                      ? 'Current image'
                                      : 'No image selected',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: hasNewImage ||
                                        hasExistingImage
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                color: hasNewImage ||
                                        hasExistingImage
                                    ? AppTheme.textPrimaryColor
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),

                            if (hasNewImage) ...[
                              const SizedBox(height: 3),
                              const Text(
                                'New image selected',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (hasNewImage)
                        IconButton(
                          tooltip: 'Cancel new image',
                          onPressed: _isSaving
                              ? null
                              : _removeSelectedImage,
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),

                      OutlinedButton.icon(
                        onPressed:
                            _isSaving ? null : _pickImage,
                        icon: const Icon(
                          Icons.upload_outlined,
                          size: 18,
                        ),
                        label: Text(
                          hasExistingImage || hasNewImage
                              ? 'Change image'
                              : 'Choose image',
                        ),
                      ),
                    ],
                  ),
                ),

                if (hasExistingImage && !hasNewImage) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'The current image will be kept unless you choose a new one.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],

                if (hasNewImage) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'The selected image will replace the current image after saving.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text(
            'Cancel',
          ),
        ),

        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.save_outlined,
                  size: 18,
                ),
          label: Text(
            _isSaving
                ? 'Saving...'
                : 'Save changes',
          ),
        ),
      ],
    );
  }
}