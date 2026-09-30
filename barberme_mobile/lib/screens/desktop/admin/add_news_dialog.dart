import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/news_service.dart';

class AddNewsDialog extends StatefulWidget {
  const AddNewsDialog({super.key});

  @override
  State<AddNewsDialog> createState() =>
      _AddNewsDialogState();
}

class _AddNewsDialogState
    extends State<AddNewsDialog> {
  final NewsService _newsService = NewsService();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _contentController =
      TextEditingController();

  String? _imagePath;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFile(
      dialogTitle: 'Select news image',
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'webp',
      ],
    );

    if (result == null) {
      return;
    }

    setState(() {
      _imagePath = result.path;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.length < 3 || title.length > 100) {
      setState(() {
        _errorMessage =
            'Title must be between 3 and 100 characters.';
      });
      return;
    }

    if (content.length < 10 ||
        content.length > 2000) {
      setState(() {
        _errorMessage =
            'Content must be between 10 and 2000 characters.';
      });
      return;
    }

    if (_imagePath == null) {
      setState(() {
        _errorMessage = 'News image is required.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _newsService.createNews(
        title: title,
        content: content,
        imagePath: _imagePath!,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
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
      backgroundColor: AppTheme.backgroundColor,
      title: const Text(
        'Add news',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _titleController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter news title',
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _contentController,
                minLines: 5,
                maxLines: 8,
                maxLength: 2000,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter news content',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Image',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              if (_imagePath != null) ...[
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Image.file(
                    File(_imagePath!),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              OutlinedButton.icon(
                onPressed:
                    _isSaving ? null : _pickImage,
                icon: const Icon(
                  Icons.image_outlined,
                ),
                label: Text(
                  _imagePath == null
                      ? 'Choose image'
                      : 'Change image',
                ),
              ),
            ],
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
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.add),
          label: Text(
            _isSaving ? 'Saving...' : 'Add news',
          ),
        ),
      ],
    );
  }
}