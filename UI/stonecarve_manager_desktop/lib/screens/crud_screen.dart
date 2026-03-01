import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/providers/role_provider.dart';
import 'package:stonecarve_manager_flutter/providers/blog_category_provider.dart';

class CrudScreen extends StatefulWidget {
  const CrudScreen({super.key});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'CRUD Management',
      currentRoute: '/crud',
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.shield), text: 'Roles'),
              Tab(icon: Icon(Icons.label), text: 'Blog Categories'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_RolesTab(), _BlogCategoriesTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// ROLES TAB
// ─────────────────────────────────────────
class _RolesTab extends StatefulWidget {
  const _RolesTab();

  @override
  State<_RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends State<_RolesTab> {
  final RoleProvider _provider = RoleProvider();
  List<RoleModel> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _provider.get();
      setState(() {
        _roles = result.items ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load roles: $e');
    }
  }

  Future<void> _showForm({RoleModel? role}) async {
    final nameCtrl = TextEditingController(text: role?.name ?? '');
    final descCtrl = TextEditingController(text: role?.description ?? '');
    bool isActive = role?.isActive ?? true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(role == null ? 'Add Role' : 'Edit Role'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (v) => setS(() => isActive = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: Text(role == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      if (role == null) {
        await _provider.createRole(
          name: nameCtrl.text.trim(),
          description: descCtrl.text.trim(),
          isActive: isActive,
        );
      } else {
        await _provider.updateRole(
          role.id!,
          name: nameCtrl.text.trim(),
          description: descCtrl.text.trim(),
          isActive: isActive,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(role == null ? 'Role created.' : 'Role updated.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _load();
    } catch (e) {
      _showError('Save failed: $e');
    }
  }

  Future<void> _delete(RoleModel role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Delete role "${role.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _provider.deleteRole(role.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role deleted.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _load();
    } catch (e) {
      _showError('Delete failed: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Roles (${_roles.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Role'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_roles.isEmpty)
            const Expanded(child: Center(child: Text('No roles found.')))
          else
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _roles.map((role) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            role.name ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                tooltip: 'Edit',
                                onPressed: () => _showForm(role: role),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                tooltip: 'Delete',
                                onPressed: () => _delete(role),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BLOG CATEGORIES TAB
// ─────────────────────────────────────────
class _BlogCategoriesTab extends StatefulWidget {
  const _BlogCategoriesTab();

  @override
  State<_BlogCategoriesTab> createState() => _BlogCategoriesTabState();
}

class _BlogCategoriesTabState extends State<_BlogCategoriesTab> {
  final BlogCategoryProvider _provider = BlogCategoryProvider();
  List<BlogCategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _provider.get();
      setState(() {
        _categories = result.items ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load blog categories: $e');
    }
  }

  Future<void> _showForm({BlogCategoryModel? cat}) async {
    final nameCtrl = TextEditingController(text: cat?.name ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(cat == null ? 'Add Blog Category' : 'Edit Blog Category'),
        content: SizedBox(
          width: 360,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Category Name *',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: Text(cat == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (cat == null) {
        await _provider.createBlogCategory(nameCtrl.text.trim());
      } else {
        await _provider.updateBlogCategory(cat.id!, nameCtrl.text.trim());
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cat == null ? 'Blog category created.' : 'Blog category updated.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      _load();
    } catch (e) {
      _showError('Save failed: $e');
    }
  }

  Future<void> _delete(BlogCategoryModel cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Blog Category'),
        content: Text('Delete category "${cat.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _provider.deleteBlogCategory(cat.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blog category deleted.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _load();
    } catch (e) {
      _showError('Delete failed: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Blog Categories (${_categories.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_categories.isEmpty)
            const Expanded(
              child: Center(child: Text('No blog categories found.')),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Posts')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Updated')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _categories.map((cat) {
                    return DataRow(
                      cells: [
                        DataCell(Text(cat.id?.toString() ?? '-')),
                        DataCell(
                          Text(
                            cat.name ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(cat.postCount?.toString() ?? '0')),
                        DataCell(
                          Text(
                            cat.createdAt != null
                                ? DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(cat.createdAt!)
                                : '-',
                          ),
                        ),
                        DataCell(
                          Text(
                            cat.updatedAt != null
                                ? DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(cat.updatedAt!)
                                : '-',
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                tooltip: 'Edit',
                                onPressed: () => _showForm(cat: cat),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                tooltip: 'Delete',
                                onPressed: () => _delete(cat),
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
        ],
      ),
    );
  }
}
