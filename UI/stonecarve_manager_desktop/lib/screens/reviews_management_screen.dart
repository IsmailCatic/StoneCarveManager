import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/review.dart';
import 'package:stonecarve_manager_flutter/providers/review_provider.dart';
import 'package:intl/intl.dart';

class ReviewsManagementScreen extends StatefulWidget {
  const ReviewsManagementScreen({super.key});

  @override
  State<ReviewsManagementScreen> createState() =>
      _ReviewsManagementScreenState();
}

class _ReviewsManagementScreenState extends State<ReviewsManagementScreen>
    with SingleTickerProviderStateMixin {
  final ReviewProvider _reviewProvider = ReviewProvider();

  late TabController _tabController;

  List<ProductReview> _pendingReviews = [];
  List<ProductReview> _approvedReviews = [];

  bool _isLoadingPending = true;
  bool _isLoadingApproved = true;

  int? _selectedRatingFilter;
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _searchQuery = '';
          _selectedRatingFilter = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadPendingReviews(), _loadApprovedReviews()]);
  }

  Future<void> _loadPendingReviews() async {
    try {
      setState(() => _isLoadingPending = true);

      final result = await _reviewProvider.getPendingReviews(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        rating: _selectedRatingFilter,
      );

      setState(() {
        _pendingReviews = result.items ?? [];
        _isLoadingPending = false;
      });
    } catch (e) {
      setState(() => _isLoadingPending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pending reviews: $e')),
        );
      }
    }
  }

  Future<void> _loadApprovedReviews() async {
    try {
      setState(() => _isLoadingApproved = true);

      final result = await _reviewProvider.getApprovedReviews(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        rating: _selectedRatingFilter,
      );

      setState(() {
        _approvedReviews = result.items ?? [];
        _isLoadingApproved = false;
      });
    } catch (e) {
      setState(() => _isLoadingApproved = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading approved reviews: $e')),
        );
      }
    }
  }

  Future<void> _approveReview(ProductReview review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Review'),
        content: Text(
          'Are you sure you want to approve this review from ${review.userName ?? 'Unknown User'}?\n\nThis will make it visible to the public.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _reviewProvider.approveReview(review.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error approving review: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectReview(ProductReview review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Review'),
        content: Text(
          'Are you sure you want to ${review.isApproved ? 'unapprove' : 'reject'} this review from ${review.userName ?? 'Unknown User'}?\n\nThis will hide it from public view.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(review.isApproved ? 'Unapprove' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _reviewProvider.rejectReview(review.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                review.isApproved ? 'Review unapproved' : 'Review rejected',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteReview(ProductReview review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to permanently delete this review?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _reviewProvider.deleteReview(review.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review deleted permanently'),
              backgroundColor: Colors.red,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting review: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Filtering now done on backend

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reviews Management',
      currentRoute: '/reviews',
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Reviews & Ratings',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage and moderate customer feedback on completed orders',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    // Stats cards
                    _buildStatCard(
                      'Pending',
                      _pendingReviews.length.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Approved',
                      _approvedReviews.length.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Average',
                      _calculateAverageRating(),
                      Icons.star,
                      Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search and filters
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by customer, order, or product...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          // Debounce search
                          _searchDebounce?.cancel();
                          _searchDebounce = Timer(
                            const Duration(milliseconds: 500),
                            () => _loadData(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Rating filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int?>(
                        value: _selectedRatingFilter,
                        hint: const Text('Filter by rating'),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Ratings'),
                          ),
                          ...List.generate(5, (index) {
                            final rating = 5 - index;
                            return DropdownMenuItem(
                              value: rating,
                              child: Row(
                                children: [
                                  ...List.generate(
                                    rating,
                                    (_) => const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Text(
                                    ' $rating ${rating == 1 ? 'Star' : 'Stars'}',
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRatingFilter = value);
                          _loadData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: _loadData,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions),
                      const SizedBox(width: 8),
                      Text('Pending (${_pendingReviews.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle),
                      const SizedBox(width: 8),
                      Text('Approved (${_approvedReviews.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewsList(
                  reviews: _pendingReviews,
                  isLoading: _isLoadingPending,
                  isPending: true,
                  emptyMessage: 'No pending reviews',
                  emptyIcon: Icons.pending_actions,
                ),
                _buildReviewsList(
                  reviews: _approvedReviews,
                  isLoading: _isLoadingApproved,
                  isPending: false,
                  emptyMessage: 'No approved reviews yet',
                  emptyIcon: Icons.rate_review,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color.shade700, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color.shade700,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: color.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAverageRating() {
    final allReviews = [..._pendingReviews, ..._approvedReviews];
    if (allReviews.isEmpty) return '0.0';

    final sum = allReviews.fold<int>(0, (sum, review) => sum + review.rating);
    return (sum / allReviews.length).toStringAsFixed(1);
  }

  Widget _buildReviewsList({
    required List<ProductReview> reviews,
    required bool isLoading,
    required bool isPending,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _buildReviewCard(review, isPending);
        },
      ),
    );
  }

  Widget _buildReviewCard(ProductReview review, bool isPending) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User info and rating
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    review.userName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    if (isPending) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        tooltip: 'Approve',
                        onPressed: () => _approveReview(review),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.orange),
                        tooltip: 'Reject',
                        onPressed: () => _rejectReview(review),
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(
                          Icons.unpublished,
                          color: Colors.orange,
                        ),
                        tooltip: 'Unapprove',
                        onPressed: () => _rejectReview(review),
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: () => _deleteReview(review),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Order info (primary focus)
            if (review.orderNumber != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order #${review.orderNumber}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Product name if available (optional, de-emphasized)
                    if (review.productName != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.blue.shade400),
                      ),
                      Flexible(
                        child: Text(
                          review.productName!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Comment
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
