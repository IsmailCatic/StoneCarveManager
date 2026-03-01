import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/faq.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/providers/faq_provider.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final FaqProvider _provider = FaqProvider();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Faq> _faqs = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;

  // Track which ids have been view-tracked this session
  final Set<int> _trackedIds = {};

  bool get _canManage => AuthProvider.isAdmin || AuthProvider.isEmployee;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFaqs();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadFaqs);
  }

  Future<void> _loadFaqs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Category and full-text search are both delegated to the backend.
      // The backend treats ?category=General as matching NULL-category rows.
      final faqs = await _provider.fetchFaqs(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        fts: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      if (!mounted) return;

      // Rebuild category chips only on the unfiltered load so they stay
      // visible while the user browses a specific category.
      if (_selectedCategory == 'All' && _searchController.text.trim().isEmpty) {
        final cats =
            faqs
                .map(
                  (f) =>
                      f.category?.isNotEmpty == true ? f.category! : 'General',
                )
                .toSet()
                .toList()
              ..sort();
        _categories = ['All', ...cats];
      }

      setState(() {
        _faqs = faqs;
        _isLoading = false;
      });
    } catch (e, st) {
      print('[FaqScreen] ERROR: $e');
      print('[FaqScreen] StackTrace: $st');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onExpansionChanged(Faq faq, bool expanded) {
    if (expanded && !_trackedIds.contains(faq.id)) {
      _trackedIds.add(faq.id);
      _provider.trackView(faq.id);
    }
  }

  // ─── CRUD ───────────────────────────────────────────────────────────────────

  /// Returns the known categories (excluding the synthetic "All" entry).
  List<String> get _knownCategories =>
      _categories.where((c) => c != 'All').toList();

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FaqFormDialog(
        provider: _provider,
        knownCategories: _knownCategories,
      ),
    );
    if (result == true) _loadFaqs();
  }

  Future<void> _showEditDialog(Faq faq) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FaqFormDialog(
        provider: _provider,
        existing: faq,
        knownCategories: _knownCategories,
      ),
    );
    if (result == true) _loadFaqs();
  }

  Future<void> _confirmDelete(Faq faq) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete FAQ'),
        content: Text(
          'Are you sure you want to delete:\n"${faq.question}"?\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _provider.deleteFaq(faq.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FAQ deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadFaqs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'FAQ Management',
      currentRoute: '/faq',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolbar(),
          _buildCategoryFilter(),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search questions or answers…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadFaqs();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          if (_canManage) ...[
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add FAQ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) {
              if (_selectedCategory == cat) return;
              setState(() => _selectedCategory = cat);
              _loadFaqs();
            },
            selectedColor: Colors.blue,
            labelStyle: TextStyle(
              color: selected ? Colors.white : null,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFaqs,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_faqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No FAQs found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (_canManage) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create first FAQ'),
              ),
            ],
          ],
        ),
      );
    }

    // Group by category
    final grouped = <String, List<Faq>>{};
    for (final faq in _faqs) {
      final cat = faq.category?.isNotEmpty == true ? faq.category! : 'General';
      grouped.putIfAbsent(cat, () => []).add(faq);
    }
    final groupKeys = grouped.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: _loadFaqs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: groupKeys.length,
        itemBuilder: (context, gi) {
          final cat = groupKeys[gi];
          final items = grouped[cat]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${items.length}'),
                      padding: EdgeInsets.zero,
                      labelStyle: const TextStyle(fontSize: 11),
                      backgroundColor: Colors.blue.shade50,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              ...items.map((faq) => _buildFaqTile(faq)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFaqTile(Faq faq) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue.shade50,
          child: Text(
            'Q',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                faq.question,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (!faq.isActive)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${faq.viewCount} views',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        trailing: _canManage
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.blue.shade600,
                    ),
                    tooltip: 'Edit',
                    onPressed: () => _showEditDialog(faq),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(faq),
                  ),
                ],
              )
            : null,
        onExpansionChanged: (expanded) => _onExpansionChanged(faq, expanded),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(faq.answer, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Create / Edit Dialog ────────────────────────────────────────────────────

class _FaqFormDialog extends StatefulWidget {
  final FaqProvider provider;
  final Faq? existing;
  final List<String> knownCategories;

  const _FaqFormDialog({
    required this.provider,
    required this.knownCategories,
    this.existing,
  });

  @override
  State<_FaqFormDialog> createState() => _FaqFormDialogState();
}

const String _kNewCategory = '＋ New category…';

class _FaqFormDialogState extends State<_FaqFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionCtrl;
  late final TextEditingController _newCategoryCtrl;
  late final TextEditingController _answerCtrl;
  late bool _isActive;
  bool _isSaving = false;

  // Dropdown selection — null means nothing chosen yet
  String? _selectedCategory;
  // Whether the user chose "new category" mode
  bool _isNewCategory = false;

  bool get _isEditing => widget.existing != null;

  /// The final category string to send to the backend.
  String? get _resolvedCategory {
    if (_isNewCategory) {
      final v = _newCategoryCtrl.text.trim();
      return v.isEmpty ? null : v;
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) return null;
    return _selectedCategory;
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _questionCtrl = TextEditingController(text: e?.question ?? '');
    _answerCtrl = TextEditingController(text: e?.answer ?? '');
    _newCategoryCtrl = TextEditingController();
    _isActive = e?.isActive ?? true;

    // Pre-select the existing category in the dropdown when editing.
    final existingCat = e?.category;
    if (existingCat != null &&
        existingCat.isNotEmpty &&
        widget.knownCategories.contains(existingCat)) {
      _selectedCategory = existingCat;
    } else if (existingCat != null && existingCat.isNotEmpty) {
      // Existing category not in list → drop straight into "new" mode
      _isNewCategory = true;
      _newCategoryCtrl.text = existingCat;
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final category = _resolvedCategory;

    try {
      if (_isEditing) {
        await widget.provider.updateFaq(
          widget.existing!.id,
          FaqUpdateRequest(
            question: _questionCtrl.text.trim(),
            answer: _answerCtrl.text.trim(),
            category: category,
            displayOrder: 0,
            isActive: _isActive,
          ),
        );
      } else {
        await widget.provider.createFaq(
          FaqInsertRequest(
            question: _questionCtrl.text.trim(),
            answer: _answerCtrl.text.trim(),
            category: category,
            displayOrder: 0,
            isActive: _isActive,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit FAQ' : 'New FAQ'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _questionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Question *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Question is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _answerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Answer *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Answer is required'
                      : null,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Category dropdown ──────────────────────────────
                    DropdownButtonFormField<String>(
                      value: _isNewCategory ? _kNewCategory : _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select or create…'),
                      items: [
                        ...widget.knownCategories.map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        ),
                        const DropdownMenuItem(
                          value: _kNewCategory,
                          child: Text(
                            _kNewCategory,
                            style: TextStyle(
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == _kNewCategory) {
                            _isNewCategory = true;
                            _selectedCategory = null;
                            _newCategoryCtrl.clear();
                          } else {
                            _isNewCategory = false;
                            _selectedCategory = value;
                          }
                        });
                      },
                    ),
                    // ── New category text input ────────────────────────
                    if (_isNewCategory) ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _newCategoryCtrl,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'New category name',
                          hintText: 'e.g. Shipping',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Cancel new category',
                            onPressed: () => setState(() {
                              _isNewCategory = false;
                              _newCategoryCtrl.clear();
                            }),
                          ),
                        ),
                        validator: (v) {
                          if (_isNewCategory &&
                              (v == null || v.trim().isEmpty)) {
                            return 'Enter a category name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text('Only active FAQs are shown publicly'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isEditing ? 'Save Changes' : 'Create',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
