import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/barber_level.dart';
import '../../../services/barber_level_service.dart';

class AdminBarberLevelsScreen extends StatefulWidget {
  const AdminBarberLevelsScreen({super.key});

  @override
  State<AdminBarberLevelsScreen> createState() =>
      _AdminBarberLevelsScreenState();
}

class _AdminBarberLevelsScreenState
    extends State<AdminBarberLevelsScreen> {
  final BarberLevelService _barberLevelService =
      BarberLevelService();

  final TextEditingController _searchController =
      TextEditingController();

  List<BarberLevel> _levels = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _page = 1;
  final int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalPages {
    if (_totalCount == 0) {
      return 1;
    }

    return (_totalCount / _pageSize).ceil();
  }

  Future<void> _loadLevels({
    int? page,
  }) async {
    final requestedPage = page ?? _page;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _barberLevelService.getBarberLevels(
        fts: _searchController.text.trim(),
        page: requestedPage,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _levels = result.items;
        _totalCount = result.totalCount;
        _page = result.page;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
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

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              final name = controller.text.trim();

              if (name.isEmpty) {
                _showMessage(
                  'Barber level name is required.',
                  isError: true,
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                await _barberLevelService
                    .createBarberLevel(
                  name: name,
                );

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                setDialogState(() {
                  isSaving = false;
                });

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

            return AlertDialog(
              title: const Text(
                'Add barber level',
              ),
              content: SizedBox(
                width: 430,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  enabled: !isSaving,
                  onSubmitted: (_) {
                    if (!isSaving) {
                      save();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Senior',
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext)
                              .pop(false);
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed:
                      isSaving ? null : save,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
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
                    isSaving
                        ? 'Adding...'
                        : 'Add',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (created == true) {
      await _loadLevels(page: 1);

      if (!mounted) {
        return;
      }

      _showMessage(
        'Barber level added successfully.',
      );
    }
  }

  Future<void> _showEditDialog(
    BarberLevel level,
  ) async {
    final controller = TextEditingController(
      text: level.name,
    );

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              final name = controller.text.trim();

              if (name.isEmpty) {
                _showMessage(
                  'Barber level name is required.',
                  isError: true,
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                await _barberLevelService
                    .updateBarberLevel(
                  id: level.id,
                  name: name,
                );

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                setDialogState(() {
                  isSaving = false;
                });

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

            return AlertDialog(
              title: const Text(
                'Edit barber level',
              ),
              content: SizedBox(
                width: 430,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  enabled: !isSaving,
                  onSubmitted: (_) {
                    if (!isSaving) {
                      save();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext)
                              .pop(false);
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed:
                      isSaving ? null : save,
                  child: Text(
                    isSaving
                        ? 'Saving...'
                        : 'Save changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (updated == true) {
      await _loadLevels(page: _page);

      if (!mounted) {
        return;
      }

      _showMessage(
        'Barber level updated successfully.',
      );
    }
  }

  Future<void> _changeStatus(
    BarberLevel level,
  ) async {
    final activating = !level.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            activating
                ? 'Activate barber level'
                : 'Deactivate barber level',
          ),
          content: Text(
            activating
                ? 'Are you sure you want to activate "${level.name}"?'
                : 'Are you sure you want to deactivate "${level.name}"?',
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
        await _barberLevelService
            .activateBarberLevel(level.id);
      } else {
        await _barberLevelService
            .deactivateBarberLevel(level.id);
      }

      await _loadLevels(page: _page);

      if (!mounted) {
        return;
      }

      _showMessage(
        activating
            ? 'Barber level activated successfully.'
            : 'Barber level deactivated successfully.',
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

  Future<void> _deleteLevel(
    BarberLevel level,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete barber level',
          ),
          content: Text(
            'Are you sure you want to permanently delete '
            '"${level.name}"?\n\n'
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
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
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
      await _barberLevelService
          .deleteBarberLevel(level.id);

      var pageToLoad = _page;

      if (_levels.length == 1 && _page > 1) {
        pageToLoad = _page - 1;
      }

      await _loadLevels(
        page: pageToLoad,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Barber level deleted successfully.',
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
      backgroundColor:
          AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Barber Levels',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Barber Levels',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppTheme.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Manage barber experience levels.',
                        style: TextStyle(
                          color:
                              AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    'Add Barber Level',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
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
                      onSubmitted: (_) {
                        _loadLevels(page: 1);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search barber levels...',
                        prefixIcon: Icon(
                          Icons.search,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  SizedBox(
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: () {
                        _loadLevels(page: 1);
                      },
                      icon: const Icon(
                        Icons.search,
                        size: 19,
                      ),
                      label: const Text(
                        'Search',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        _searchController.clear();

                        _loadLevels(page: 1);
                      },
                      child: const Text(
                        'Clear',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
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
              size: 44,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadLevels,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_levels.isEmpty) {
      return const Center(
        child: Text(
          'No barber levels found.',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE8E4DF),
              ),
            ),
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text('Name'),
                  ),
                  DataColumn(
                    label: Text('Status'),
                  ),
                  DataColumn(
                    label: Text('Actions'),
                  ),
                ],
                rows: _levels.map((level) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          level.name,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      DataCell(
                        _buildStatus(level),
                      ),

                      DataCell(
                        PopupMenuButton<String>(
                          tooltip: 'Actions',
                          onSelected:
                              (value) async {
                            if (value == 'edit') {
                              await _showEditDialog(
                                level,
                              );
                            }

                            if (value ==
                                'status') {
                              await _changeStatus(
                                level,
                              );
                            }

                            if (value ==
                                'delete') {
                              await _deleteLevel(
                                level,
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .edit_outlined,
                                    size: 19,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
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
                                    level.isActive
                                        ? Icons
                                            .block_outlined
                                        : Icons
                                            .check_circle_outline,
                                    size: 19,
                                    color:
                                        level.isActive
                                            ? Colors
                                                .orange
                                            : Colors
                                                .green,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    level.isActive
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
                                    Icons
                                        .delete_outline,
                                    size: 19,
                                    color:
                                        Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Delete',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.red,
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
                }).toList(),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        _buildPagination(),
      ],
    );
  }

  Widget _buildStatus(
    BarberLevel level,
  ) {
    final active = level.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withValues(
                alpha: 0.10,
              )
            : Colors.grey.withValues(
                alpha: 0.12,
              ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active
              ? Colors.green.shade700
              : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      children: [
        Text(
          '$_totalCount barber level${_totalCount == 1 ? '' : 's'}',
          style: const TextStyle(
            color:
                AppTheme.textSecondaryColor,
          ),
        ),

        const Spacer(),

        IconButton(
          tooltip: 'Previous page',
          onPressed: _page > 1
              ? () {
                  _loadLevels(
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
            'Page $_page of $_totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          tooltip: 'Next page',
          onPressed: _page < _totalPages
              ? () {
                  _loadLevels(
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