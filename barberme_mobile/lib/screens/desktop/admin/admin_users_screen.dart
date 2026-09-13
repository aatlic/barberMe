import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/paged_response.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';
import '../../../core/config/api_config.dart';
import 'add_user_dialog.dart';
import 'edit_user_dialog.dart';
import 'copy_employee_dialog.dart';
import '../../../services/auth_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() =>
      _AdminUsersScreenState();
}

class _AdminUsersScreenState
    extends State<AdminUsersScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  final TextEditingController _searchController =
      TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  List<User> _users = [];

  int _page = 1;
  final int _pageSize = 10;

  int _totalCount = 0;
  int _totalPages = 0;

  int? _selectedRoleId;

  int? _processingUserId;

  @override
  void initState() {
    super.initState();

    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadUsers({
    int? page,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _userService.getUsers(
        fts: _searchController.text.trim(),
        roleId: _selectedRoleId,
        page: page ?? _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _users = result.items;
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

  Future<void> _changeLockStatus(
    User user,
  ) async {
    final action =
        user.isLocked ? 'unlock' : 'lock';

    final confirmed =
        await _showConfirmationDialog(
      title:
          user.isLocked ? 'Unlock user' : 'Lock user',
      message: user.isLocked
          ? 'Are you sure you want to unlock ${user.firstName} ${user.lastName}?'
          : 'Are you sure you want to lock ${user.firstName} ${user.lastName}?',
      confirmText:
          user.isLocked ? 'Unlock' : 'Lock',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _processingUserId = user.id;
    });

    try {
      if (user.isLocked) {
        await _userService.unlockUser(
          user.id,
        );
      } else {
        await _userService.lockUser(
          user.id,
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        action == 'lock'
            ? 'User locked successfully.'
            : 'User unlocked successfully.',
      );

      await _loadUsers();
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
    } finally {
      if (mounted) {
        setState(() {
          _processingUserId = null;
        });
      }
    }
  }

  Future<void> _changeActiveStatus(
    User user,
  ) async {
    final confirmed =
        await _showConfirmationDialog(
      title: user.isActive
          ? 'Deactivate user'
          : 'Activate user',
      message: user.isActive
          ? 'Are you sure you want to deactivate ${user.firstName} ${user.lastName}?'
          : 'Are you sure you want to activate ${user.firstName} ${user.lastName}?',
      confirmText:
          user.isActive ? 'Deactivate' : 'Activate',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _processingUserId = user.id;
    });

    try {
      if (user.isActive) {
        await _userService.deactivateUser(
          user.id,
        );
      } else {
        await _userService.activateUser(
          user.id,
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        user.isActive
            ? 'User deactivated successfully.'
            : 'User activated successfully.',
      );

      await _loadUsers();
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
    } finally {
      if (mounted) {
        setState(() {
          _processingUserId = null;
        });
      }
    }
  }

  Future<void> _editUser(
    User user,
  ) async {
    final updated =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditUserDialog(
        user: user,
      ),
    );

    if (updated != true) {
      return;
    }

    await _loadUsers(
      page: _page,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      'User updated successfully.',
    );
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete user'),
          content: Text(
            'Are you sure you want to delete '
            '${user.firstName} ${user.lastName}?\n\n'
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

    setState(() {
      _processingUserId = user.id;
    });

    try {
      await _userService.deleteUser(user.id);

      if (!mounted) {
        return;
      }

      _showMessage(
        'User deleted successfully.',
      );

      await _loadUsers(
        page: _page,
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
    } finally {
      if (mounted) {
        setState(() {
          _processingUserId = null;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(
                confirmText,
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _openCopyEmployeeDialog() async {
    final copied = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CopyEmployeeDialog(),
    );

    if (copied != true) {
      return;
    }

    _page = 1;

    await _loadUsers(
      page: 1,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      'Employee copied successfully.',
    );
  }

  Future<void> _resetPassword(
    User user,
  ) async {
    final confirmed =
        await _showConfirmationDialog(
      title: 'Reset password',
      message:
          'A temporary password will be generated for '
          '${user.firstName} ${user.lastName} and sent to '
          '${user.email}.\n\n'
          'The user will be required to change it after signing in.',
      confirmText: 'Reset password',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _processingUserId = user.id;
    });

    try {
      final message =
          await _authService.forgotPassword(
        email: user.email,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        message.isNotEmpty
            ? message
            : 'Password reset successfully.',
      );

      await _loadUsers(
        page: _page,
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
    } finally {
      if (mounted) {
        setState(() {
          _processingUserId = null;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : null,
      ),
    );
  }

  void _search() {
    _page = 1;

    _loadUsers(
      page: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                'Users',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color:
                      AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage Barber Me users and account access.',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: _isLoading
              ? null
              : _openCopyEmployeeDialog,
          icon: const Icon(
            Icons.copy_outlined,
          ),
          label: const Text(
            'Copy employee',
          ),
        ),

        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _isLoading
        ? null
        : () async {
            final created =
                await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) =>
                  const AddUserDialog(),
            );

            if (created == true) {
              _page = 1;

              await _loadUsers(
                page: 1,
              );

              if (!mounted) {
                return;
              }

              _showMessage(
                'User created successfully.',
              );
            }
          },
          icon: const Icon(
            Icons.person_add_alt_1,
          ),
          label: const Text(
            'Add user',
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
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFFE5E1DC,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) {
                _search();
              },
              decoration:
                  const InputDecoration(
                hintText:
                    'Search name, username or email...',
                prefixIcon: Icon(
                  Icons.search,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<int?>(
              value: _selectedRoleId,
              decoration:
                  const InputDecoration(
                labelText: 'Role',
              ),
              items: const [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    'All roles',
                  ),
                ),
                DropdownMenuItem<int?>(
                  value: 1,
                  child: Text(
                    'Admin',
                  ),
                ),
                DropdownMenuItem<int?>(
                  value: 2,
                  child: Text(
                    'Barber',
                  ),
                ),
                DropdownMenuItem<int?>(
                  value: 3,
                  child: Text(
                    'Client',
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRoleId = value;
                });

                _page = 1;

                _loadUsers(
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
            onPressed:
                _isLoading ? null : _clearFilters,
            child: const Text(
              'Clear',
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _selectedRoleId = null;
      _page = 1;
    });

    _loadUsers(
      page: 1,
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
              onPressed: _loadUsers,
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
    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'No users found.',
          style: TextStyle(
            color:
                AppTheme.textSecondaryColor,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFFE5E1DC,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor:
                WidgetStateProperty.all(
              const Color(0xFFF2EFEA),
            ),
            columns: const [
              DataColumn(
                label: Text('User'),
              ),
              DataColumn(
                label: Text('Username'),
              ),
              DataColumn(
                label: Text('Email'),
              ),
              DataColumn(
                label: Text('Role'),
              ),
              DataColumn(
                label: Text('Status'),
              ),
              DataColumn(
                label: Text('Access'),
              ),
              DataColumn(
                label: Text('Actions'),
              ),
            ],
            rows: _users
                .map(
                  _buildUserRow,
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildUserRow(
    User user,
  ) {
    final isProcessing =
        _processingUserId == user.id;

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 165,
            child: Row(
              children: [
                _buildUserAvatar(user),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${user.firstName} ${user.lastName}'
                        .trim(),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Text(user.username),
        ),
        DataCell(
          Text(user.email),
        ),
        DataCell(
          _buildRoleBadge(
            user.role.name,
          ),
        ),
        DataCell(
          _buildStatusBadge(
            user.isActive,
          ),
        ),
        DataCell(
          _buildLockBadge(
            user.isLocked,
          ),
        ),
        DataCell(
          isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : PopupMenuButton<String>(
                  tooltip: 'User actions',
                  onSelected: (value) {
                    if (value == 'lock') {
                      _changeLockStatus(
                        user,
                      );
                    }

                    if (value ==
                        'active') {
                      _changeActiveStatus(
                        user,
                      );
                    }

                    if (value == 'edit') {
                      _editUser(user);
                    }

                    if (value == 'delete') {
                      _deleteUser(user);
                    }

                    if (value == 'resetPassword') {
                      _resetPassword(user);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'lock',
                      child: Row(
                        children: [
                          Icon(
                            user.isLocked
                                ? Icons
                                    .lock_open_outlined
                                : Icons
                                    .lock_outline,
                            size: 19,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            user.isLocked
                                ? 'Unlock'
                                : 'Lock',
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'active',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive
                                ? Icons
                                    .person_off_outlined
                                : Icons
                                    .person_outline,
                            size: 19,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            user.isActive
                                ? 'Deactivate'
                                : 'Activate',
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.edit_outlined,
                            size: 19,
                          ),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'resetPassword',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.password_outlined,
                            size: 19,
                          ),
                          SizedBox(width: 10),
                          Text('Reset password'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),

                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
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

  Widget _buildRoleBadge(
    String role,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentColor
            .withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: AppTheme.accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        isActive
            ? 'Active'
            : 'Inactive',
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

  Widget _buildLockBadge(
    bool isLocked,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isLocked
              ? Icons.lock_outline
              : Icons.lock_open_outlined,
          size: 17,
          color: isLocked
              ? Colors.red
              : const Color(0xFF28783A),
        ),
        const SizedBox(width: 6),
        Text(
          isLocked
              ? 'Locked'
              : 'Unlocked',
          style: TextStyle(
            color: isLocked
                ? Colors.red
                : const Color(
                    0xFF28783A,
                  ),
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
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
          'Showing $from-$to of $_totalCount users',
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
                  _loadUsers(
                    page: _page - 1,
                  );
                }
              : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(
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
          onPressed:
              _page < _totalPages
                  ? () {
                      _loadUsers(
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

  String? _getProfileImageUrl(
    User user,
  ) {
    final path = user.profileImagePath;

    if (path == null ||
        path.trim().isEmpty) {
      return null;
    }

    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    final normalizedPath = path
        .replaceAll('\\', '/')
        .replaceFirst(
          RegExp(r'^/+'),
          '',
        );

    return '${ApiConfig.baseUrl}/$normalizedPath';
  }

  String _initials(
    User user,
  ) {
    final first = user.firstName.isNotEmpty
        ? user.firstName[0]
        : '';

    final last = user.lastName.isNotEmpty
        ? user.lastName[0]
        : '';

    return '$first$last'.toUpperCase();
  }

  Widget _buildUserAvatar(
    User user,
  ) {
    final imageUrl =
        _getProfileImageUrl(user);

    if (imageUrl == null) {
      return _buildInitialsAvatar(user);
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _buildInitialsAvatar(
            user,
          );
        },
      ),
    );
  }

  Widget _buildInitialsAvatar(
    User user,
  ) {
    return CircleAvatar(
      radius: 21,
      backgroundColor:
          AppTheme.primaryColor,
      child: Text(
        _initials(user),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}