import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/service_service.dart';

class AddServiceDialog extends StatefulWidget {
  const AddServiceDialog({super.key});

  @override
  State<AddServiceDialog> createState() =>
      _AddServiceDialogState();
}

class _AddServiceDialogState
    extends State<AddServiceDialog> {
  final ServiceService _serviceService =
      ServiceService();

  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();
  final _descriptionController =
      TextEditingController();
  final _priceController =
      TextEditingController();
  final _durationController =
      TextEditingController();

  String? _imagePath;
  String? _imageName;

  bool _isSaving = false;

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

    if (file == null) {
      return;
    }

    if (file.path == null) {
      return;
    }

    setState(() {
      _imagePath = file.path;
      _imageName = file.name;
    });
  }

  void _removeImage() {
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
      await _serviceService.createService(
        name: _nameController.text,
        description:
            _descriptionController.text,
        price: price,
        durationMinutes: duration,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding:
          const EdgeInsets.fromLTRB(
        28,
        26,
        28,
        0,
      ),
      contentPadding:
          const EdgeInsets.fromLTRB(
        28,
        22,
        28,
        8,
      ),
      actionsPadding:
          const EdgeInsets.fromLTRB(
        28,
        12,
        28,
        24,
      ),
      title: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Add service',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Create a new salon service.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color:
                  AppTheme.textSecondaryColor,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Service name',
                    hintText:
                        'e.g. Classic Haircut',
                  ),
                  validator: (value) {
                    final text =
                        value?.trim() ?? '';

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
                  controller:
                      _descriptionController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'Describe the service...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.trim().length >
                            500) {
                      return 'Description must not exceed 500 characters.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller:
                            _priceController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText: 'Price',
                          suffixText: 'KM',
                          hintText: '25.00',
                        ),
                        validator: (value) {
                          final price =
                              double.tryParse(
                            (value ?? '')
                                .trim()
                                .replaceAll(
                                  ',',
                                  '.',
                                ),
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
                        controller:
                            _durationController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          labelText: 'Duration',
                          suffixText: 'min',
                          hintText: '30',
                        ),
                        validator: (value) {
                          final duration =
                              int.tryParse(
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
                    color:
                        AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 9),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          const Color(0xFFE5E1DC),
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme
                              .accentColor
                              .withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color:
                              AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _imageName ??
                              'No image selected',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _imageName ==
                                    null
                                ? AppTheme
                                    .textSecondaryColor
                                : AppTheme
                                    .textPrimaryColor,
                          ),
                        ),
                      ),
                      if (_imageName != null)
                        IconButton(
                          tooltip:
                              'Remove image',
                          onPressed:
                              _isSaving
                                  ? null
                                  : _removeImage,
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : _pickImage,
                        icon: const Icon(
                          Icons.upload_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'Choose image',
                        ),
                      ),
                    ],
                  ),
                ),
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
                  Navigator.of(context)
                      .pop(false);
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.add,
                  size: 18,
                ),
          label: Text(
            _isSaving
                ? 'Creating...'
                : 'Add service',
          ),
        ),
      ],
    );
  }
}