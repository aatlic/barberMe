import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/news.dart';
import '../../../services/news_service.dart';

class EditNewsDialog extends StatefulWidget {
  final News news;

  const EditNewsDialog({
    super.key,
    required this.news,
  });

  @override
  State<EditNewsDialog> createState() =>
      _EditNewsDialogState();
}

class _EditNewsDialogState
    extends State<EditNewsDialog> {
  final NewsService _newsService = NewsService();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  String? _imagePath;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.news.title,
    );

    _contentController = TextEditingController(
      text: widget.news.content,
    );
  }

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

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _newsService.updateNews(
        newsId: widget.news.id,
        title: title,
        content: content,
        isActive: widget.news.isActive,
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

  String? _getCurrentImageUrl() {
    final image = widget.news.image?.trim();

    if (image == null || image.isEmpty) {
      return null;
    }

    if (image.startsWith('http')) {
      return image;
    }

    return '${ApiConfig.baseUrl}/${image.replaceFirst(RegExp(r'^/+'), '')}';
  }

  Widget _buildImagePreview() {
    if (_imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_imagePath!),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    }

    final imageUrl = _getCurrentImageUrl();

    if (imageUrl == null) {
      return Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(
            alpha: 0.10,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.article_outlined,
            size: 40,
            color: AppTheme.accentColor,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: AppTheme.accentColor,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.backgroundColor,
      title: const Text(
        'Edit news',
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

              _buildImagePreview(),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed:
                    _isSaving ? null : _pickImage,
                icon: const Icon(
                  Icons.image_outlined,
                ),
                label: const Text(
                  'Change image',
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
              : const Icon(Icons.save_outlined),
          label: Text(
            _isSaving ? 'Saving...' : 'Save changes',
          ),
        ),
      ],
    );
  }
}