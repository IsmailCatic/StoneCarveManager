import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/models/faq.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/faq_provider.dart';
import 'package:stonecarve_manager_mobile/widgets/mobile/app_drawer_mobile.dart';

class FaqMobileScreen extends StatefulWidget {
  const FaqMobileScreen({Key? key}) : super(key: key);

  @override
  State<FaqMobileScreen> createState() => _FaqMobileScreenState();
}

class _FaqMobileScreenState extends State<FaqMobileScreen> {
  final FaqProvider _provider = FaqProvider();
  final TextEditingController _searchController = TextEditingController();

  List<Faq> _faqs = [];

  /// Category chips — populated once from the initial unfiltered load and kept
  /// stable so chips don't disappear while browsing individual categories.
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _debounce;

  // Track which item is expanded (to call trackView once)
  final Set<int> _trackedIds = {};

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
      // Category and search are both sent to the backend.
      // The backend treats ?category=General as matching NULL-category rows.
      final faqs = await _provider.fetchFaqs(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        isActive: true,
        fts: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      if (!mounted) return;

      // Rebuild the category chip list only on the unfiltered initial/refresh
      // load so chips remain visible while a specific category is selected.
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load FAQs: $e';
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    // New request to backend with the selected category.
    _loadFaqs();
  }

  void _onExpansionChanged(Faq faq, bool expanded) {
    if (expanded && !_trackedIds.contains(faq.id)) {
      _trackedIds.add(faq.id);
      _provider.trackView(faq.id);
    }
  }

  /// Group FAQs by category so they render in sections.
  Map<String, List<Faq>> get _grouped {
    final map = <String, List<Faq>>{};
    for (final faq in _faqs) {
      final cat = faq.category?.isNotEmpty == true ? faq.category! : 'General';
      map.putIfAbsent(cat, () => []).add(faq);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ'), centerTitle: true),
      drawer: const AppDrawerMobile(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search FAQs…',
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final selected = _selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => _onCategorySelected(cat),
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
            Text(_errorMessage!, textAlign: TextAlign.center),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No FAQs found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final grouped = _grouped;
    final groupKeys = grouped.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: _loadFaqs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        itemCount: groupKeys.length,
        itemBuilder: (context, gi) {
          final cat = groupKeys[gi];
          final items = grouped[cat]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header — only show when viewing all categories
              if (_selectedCategory == 'All' || grouped.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
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
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        onExpansionChanged: (expanded) => _onExpansionChanged(faq, expanded),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(faq.answer, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              Icon(
                Icons.visibility_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                '${faq.viewCount} views',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
