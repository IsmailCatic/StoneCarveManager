import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/user.dart';
import 'package:stonecarve_manager_flutter/providers/user_provider.dart';
import '../utils/validators.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserProvider _userProvider = UserProvider();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<String> _availableRoles = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      print('Fetching roles from backend...');
      final roles = await _userProvider.getRoles();
      print('Roles fetched: $roles');
      setState(() {
        _availableRoles = roles;
      });
    } catch (e) {
      print('Error fetching roles: $e');
      setState(() {
        _availableRoles = ['User']; // fallback
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _userProvider.get();
      setState(() {
        _users = result.items ?? [];
        _filteredUsers = _users;
      });
    } catch (e) {
      // handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Users',
      currentRoute: '/users',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New User'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filteredUsers = _users.where((user) {
                    final query = value.toLowerCase();
                    return user.displayName.toLowerCase().contains(query) ||
                        (user.email?.toLowerCase().contains(query) ?? false) ||
                        user.roles.any(
                          (role) => role.toLowerCase().contains(query),
                        );
                  }).toList();
                });
              },
            ),
            const SizedBox(height: 16),
            // User Statistics
            Row(
              children: [
                _buildStatCard(
                  'Total Users',
                  _users.length.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Active',
                  _users
                      .where((u) => u.isActive == true && u.isBlocked != true)
                      .length
                      .toString(),
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Blocked',
                  _users.where((u) => u.isBlocked == true).length.toString(),
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getUserStatusColor(user),
                              child: Text(
                                user.displayName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${user.email ?? 'N/A'}'),
                                Text(
                                  'Role: ${user.roles.isNotEmpty ? user.roles.join(', ') : 'User'}',
                                ),
                                Text('Status: ${_getUserStatusText(user)}'),
                                if (user.lastLoginAt != null)
                                  Text(
                                    'Last Login: ${_formatDate(user.lastLoginAt!)}',
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () => _showUserDetailsDialog(user),
                                  tooltip: 'View/Edit User',
                                ),
                                IconButton(
                                  icon: Icon(
                                    user.isBlocked == true
                                        ? Icons.lock_open
                                        : Icons.lock,
                                    color: user.isBlocked == true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmToggleUserBlock(user),
                                  tooltip: user.isBlocked == true
                                      ? 'Unblock User'
                                      : 'Block User',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUserStatusColor(User user) {
    if (user.isBlocked == true) return Colors.red;
    if (user.isActive == true) return Colors.green;
    return Colors.grey;
  }

  String _getUserStatusText(User user) {
    if (user.isBlocked == true) return 'Blocked';
    if (user.isActive == true) return 'Active';
    return 'Inactive';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddUserDialog() {
    if (_availableRoles.isNotEmpty) {
      _showUserDialog(null);
    } else {
      // Optionally show a loading indicator or disable the button in the UI
      _loadRoles().then((_) {
        if (_availableRoles.isNotEmpty) {
          _showUserDialog(null);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Roles are not loaded. Please try again.'),
            ),
          );
        }
      });
    }
  }

  void _showUserDetailsDialog(User user) {
    _showUserDialog(user);
  }

  void _showUserDialog(User? user) {
    final _formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(
      text: user?.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: user?.lastName ?? '',
    );
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    // final usernameController = TextEditingController(
    //   text: user?.username ?? '',
    // );
    final phoneController = TextEditingController(
      text: user?.phoneNumber ?? '',
    );

    // List of all possible roles
    final List<String> availableRoles = _availableRoles;

    // Use a single role string for creation
    String selectedRole = (user?.roles != null && user!.roles.isNotEmpty)
        ? user.roles.first
        : (_availableRoles.isNotEmpty ? availableRoles.first : 'User');
    bool isActive = user?.isActive ?? true;
    bool isBlocked = user?.isBlocked ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(user == null ? 'Add New User' : 'Edit User Details'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name *',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name *',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (user == null) ...[
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password *',
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 8),
                        ],
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 8),
                        // TextField(
                        //   controller: usernameController,
                        //   decoration: const InputDecoration(
                        //     labelText: 'Username *',
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 8),

                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: const InputDecoration(labelText: 'Role'),
                          items: _availableRoles
                              .map(
                                (role) => DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: const Text('Is Active'),
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Is Blocked'),
                          value: isBlocked,
                          onChanged: (value) {
                            setState(() {
                              isBlocked = value!;
                            });
                          },
                        ),
                      ],
                    ),
                ),
              ),
            ),
            actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validate form
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final newUser = User(
                    id: user?.id,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: emailController.text,
                    password: user == null ? passwordController.text : null,
                    phoneNumber: phoneController.text.isEmpty
                        ? null
                        : phoneController.text,
                    isActive: isActive,
                    isBlocked: isBlocked,
                    roles: user?.roles ?? [],
                    role: selectedRole,
                  );

                  try {
                    if (user == null) {
                      await _userProvider.createUser(newUser);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User added successfully'),
                          ),
                        );
                      }
                    } else {
                      await _userProvider.updateUser(user.id!, newUser);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User updated successfully'),
                          ),
                        );
                      }
                    }
                    Navigator.of(context).pop();
                    _loadUsers();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: Text(user == null ? 'Add' : 'Update'),
              ),
            ],
            );
          },
        );
      },
    );
  }

  void _confirmToggleUserBlock(User user) {
    final isBlocking = user.isBlocked != true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isBlocking ? 'Block User' : 'Unblock User'),
          content: Text(
            isBlocking
                ? 'Are you sure you want to block "${user.displayName}"? They will not be able to access the application.'
                : 'Are you sure you want to unblock "${user.displayName}"? They will regain access to the application.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _userProvider.blockUser(user.id!, isBlocking);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'User ${isBlocking ? 'blocked' : 'unblocked'} successfully',
                      ),
                    ),
                  );
                  _loadUsers();
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocking ? Colors.red : Colors.green,
              ),
              child: Text(
                isBlocking ? 'Block' : 'Unblock',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
