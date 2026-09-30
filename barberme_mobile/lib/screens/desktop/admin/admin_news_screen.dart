import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/news.dart';
import '../../../services/news_service.dart';
import 'add_news_dialog.dart';
import 'edit_news_dialog.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() =>
      _AdminNewsScreenState();
}

class _AdminNewsScreenState
    extends State<AdminNewsScreen> {
  final NewsService _newsService = NewsService();

  final TextEditingController _searchController =
      TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  List<News> _news = [];

  int _page = 1;
  final int _pageSize = 10;

  int _totalCount = 0;
  int _totalPages = 0;

  bool? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews({
    int? page,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _newsService.getNews(
        fts: _searchController.text.trim(),
        isActive: _selectedStatus,
        page: page ?? _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _news = result.items;
        _page = result.page;
        _totalCount = result.totalCount;
        _totalPages = result.totalPages;
      });
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
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : null,
      ),
    );
  }

  void _search() {
    _page = 1;

    _loadNews(
      page: 1,
    );
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _selectedStatus = null;
      _page = 1;
    });

    _loadNews(
      page: 1,
    );
  }

  Future<void> _addNews() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddNewsDialog(),
    );

    if (created != true) {
      return;
    }

    _page = 1;

    await _loadNews(
      page: 1,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      'News created successfully.',
    );
  }

  Future<void> _editNews(
    News news,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditNewsDialog(
        news: news,
      ),
    );

    if (updated != true) {
      return;
    }

    await _loadNews(
      page: _page,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      'News updated successfully.',
    );
  }

  Future<void> _changeNewsStatus(
    News news,
  ) async {
    final activating = !news.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            activating
                ? 'Activate news'
                : 'Deactivate news',
          ),
          content: Text(
            activating
                ? 'Are you sure you want to activate "${news.title}"?'
                : 'Are you sure you want to deactivate "${news.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                activating
                    ? 'Activate'
                    : 'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      if (activating) {
        await _newsService.activateNews(
          news.id,
        );
      } else {
        await _newsService.deactivateNews(
          news.id,
        );
      }

      await _loadNews(
        page: _page,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        activating
            ? 'News activated successfully.'
            : 'News deactivated successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    }
  }

  Future<void> _deleteNews(
    News news,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete news',
          ),
          content: Text(
            'Are you sure you want to permanently delete '
            '"${news.title}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _newsService.deleteNews(
        news.id,
      );

      var pageToLoad = _page;

      if (_news.length == 1 && _page > 1) {
        pageToLoad = _page - 1;
      }

      await _loadNews(
        page: pageToLoad,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'News deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          32,
          28,
          32,
          32,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildFilters(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'News',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color:
                      AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage news and announcements for clients and barbers.',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed:
              _isLoading ? null : _addNews,
          icon: const Icon(
            Icons.add,
          ),
          label: const Text(
            'Add news',
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E1DC),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) {
                _search();
              },
              decoration:
                  const InputDecoration(
                hintText: 'Search news...',
                prefixIcon: Icon(
                  Icons.search,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          SizedBox(
            width: 180,
            child: DropdownButtonFormField<bool?>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: const [
                DropdownMenuItem<bool?>(
                  value: null,
                  child: Text('All'),
                ),
                DropdownMenuItem<bool?>(
                  value: true,
                  child: Text('Active'),
                ),
                DropdownMenuItem<bool?>(
                  value: false,
                  child: Text('Inactive'),
                ),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedStatus = value;
                        _page = 1;
                      });

                      _loadNews(
                        page: 1,
                      );
                    },
            ),
          ),

          const SizedBox(width: 16),

          FilledButton.icon(
            onPressed:
                _isLoading ? null : _search,
            icon: const Icon(
              Icons.search,
            ),
            label: const Text(
              'Search',
            ),
          ),

          const SizedBox(width: 10),

          OutlinedButton(
            onPressed: _isLoading
                ? null
                : _clearFilters,
            child: const Text(
              'Clear',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 46,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadNews,
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildTable(),
        ),
        const SizedBox(height: 18),
        _buildPagination(),
      ],
    );
  }

  Widget _buildTable() {
    if (_news.isEmpty) {
      return const Center(
        child: Text(
          'No news found.',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E1DC),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(
                const Color(0xFFF2EFEA),
              ),
              columnSpacing: 32,
              columns: const [
                DataColumn(
                  label: Text('News'),
                ),
                DataColumn(
                  label: Text('Content'),
                ),
                DataColumn(
                  label: Text('Created'),
                ),
                DataColumn(
                  label: Text('Status'),
                ),
                DataColumn(
                  label: Text('Actions'),
                ),
              ],
              rows: _news
                  .map(_buildNewsRow)
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildNewsRow(
    News news,
  ) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 230,
            child: Row(
              children: [
                _buildNewsImage(news),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    news.title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        DataCell(
          SizedBox(
            width: 330,
            child: Text(
              news.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        DataCell(
          Text(
            _formatDate(
              news.createdAt,
            ),
          ),
        ),

        DataCell(
          _buildStatusBadge(
            news.isActive,
          ),
        ),

        DataCell(
          PopupMenuButton<String>(
            tooltip: 'News actions',
            onSelected: (value) async {
              if (value == 'edit') {
                await _editNews(news);
              }

              if (value == 'status') {
                await _changeNewsStatus(news);
              }

              if (value == 'delete') {
                await _deleteNews(news);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 19,
                    ),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    Icon(
                      news.isActive
                          ? Icons.block_outlined
                          : Icons
                              .check_circle_outline,
                      size: 19,
                      color: news.isActive
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      news.isActive
                          ? 'Deactivate'
                          : 'Activate',
                    ),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 19,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsImage(
    News news,
  ) {
    final image = news.image?.trim();

    if (image == null || image.isEmpty) {
      return _buildImagePlaceholder();
    }

    final url = image.startsWith('http')
        ? image
        : '${ApiConfig.baseUrl}/${image.replaceFirst(RegExp(r'^/+'), '')}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 44,
        height: 44,
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.article_outlined,
        size: 21,
        color: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildStatusBadge(
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFEAF7ED)
            : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive
              ? const Color(0xFF28783A)
              : const Color(0xFF777777),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    final localDate = date.toLocal();

    final day =
        localDate.day.toString().padLeft(2, '0');

    final month =
        localDate.month.toString().padLeft(2, '0');

    return '$day.$month.${localDate.year}.';
  }

  Widget _buildPagination() {
    final from = _totalCount == 0
        ? 0
        : ((_page - 1) * _pageSize) + 1;

    final calculatedTo =
        _page * _pageSize;

    final to = calculatedTo > _totalCount
        ? _totalCount
        : calculatedTo;

    return Row(
      children: [
        Text(
          'Showing $from-$to of $_totalCount news',
          style: const TextStyle(
            color:
                AppTheme.textSecondaryColor,
            fontSize: 13,
          ),
        ),

        const Spacer(),

        IconButton(
          tooltip: 'Previous page',
          onPressed: _page > 1
              ? () {
                  _loadNews(
                    page: _page - 1,
                  );
                }
              : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Text(
            'Page $_page of ${_totalPages == 0 ? 1 : _totalPages}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          tooltip: 'Next page',
          onPressed: _page < _totalPages
              ? () {
                  _loadNews(
                    page: _page + 1,
                  );
                }
              : null,
          icon: const Icon(
            Icons.chevron_right,
          ),
        ),
      ],
    );
  }
}