import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stonecarve_manager_flutter/models/analytics.dart';
import 'package:stonecarve_manager_flutter/providers/analytics_provider.dart';
import 'package:stonecarve_manager_flutter/widgets/app_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  final AnalyticsProvider _analyticsProvider = AnalyticsProvider();

  DashboardStatistics? _dashboardStats;
  List<RevenueByMethod> _revenueByMethod = [];
  List<TopProduct> _topProducts = [];
  List<TopCustomer> _topCustomers = [];
  List<CategoryPerformance> _categories = [];
  List<RevenueTrend> _revenueTrend = [];
  CustomerStatistics? _customerStats;
  ReviewStatistics? _reviewStats;
  List<EmployeePerformance> _employeePerformance = [];

  bool _isLoading = true;
  String? _error;
  bool _isAllTime =
      false; // Track if we're in "All Time" mode (no date filters)
  DateTime _startDate = DateTime(
    DateTime.now().year,
    1,
    1,
  ); // Start from January 1st of current year
  late DateTime _endDate;

  late AnimationController _animationController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize endDate to end of today
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    print('[Analytics] ===============================================');
    print('[Analytics] 🚀 INIT: Default date range set to:');
    print('[Analytics]    Start: $_startDate');
    print('[Analytics]    End: $_endDate');
    print('[Analytics] ===============================================');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('[Analytics] ===============================================');
      print('[Analytics] 📊 LOADING DATA WITH DATE RANGE:');
      print('[Analytics]    Start: ${_startDate.toIso8601String()}');
      print('[Analytics]    End: ${_endDate.toIso8601String()}');
      print(
        '[Analytics]    Duration: ${_endDate.difference(_startDate).inDays} days',
      );
      print('[Analytics] ===============================================');

      // Load ALL analytics data in parallel
      final results = await Future.wait([
        _analyticsProvider
            .getDashboardStatistics(startDate: _startDate, endDate: _endDate)
            .then((data) {
              print('[Analytics] ✅ Dashboard stats loaded: $data');
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Dashboard stats failed: $e');
              throw e;
            }),
        _analyticsProvider
            .getRevenueByPaymentMethod(startDate: _startDate, endDate: _endDate)
            .then((data) {
              print(
                '[Analytics] ✅ Revenue by method loaded: ${data.length} items',
              );
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Revenue by method failed: $e');
              throw e;
            }),
        _analyticsProvider
            .getTopProducts(startDate: _startDate, endDate: _endDate, limit: 10)
            .then((data) {
              print('[Analytics] ✅ Top products loaded: ${data.length} items');
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Top products failed: $e');
              throw e;
            }),
        _analyticsProvider
            .getTopCustomers(limit: 10)
            .then((data) {
              print('[Analytics] ✅ Top customers loaded: ${data.length} items');
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Top customers failed: $e');
              throw e;
            }),
        _analyticsProvider
            .getCategoryPerformance(startDate: _startDate, endDate: _endDate)
            .then((data) {
              print(
                '[Analytics] ✅ Category performance loaded: ${data.length} items',
              );
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Category performance failed: $e');
              throw e;
            }),
        _analyticsProvider
            .getRevenueTrend(
              startDate: _startDate,
              endDate: _endDate,
              groupBy: 'day',
              skipDateFilter: _isAllTime, // Skip date filter in "All Time" mode
            )
            .then((data) {
              print('[Analytics] ✅ Revenue trend loaded: ${data.length} items');
              if (data.isNotEmpty) {
                print(
                  '[Analytics] First trend entry: ${data.first.date} = \$${data.first.revenue}',
                );
                print(
                  '[Analytics] Last trend entry: ${data.last.date} = \$${data.last.revenue}',
                );
              } else {
                print('[Analytics] ⚠️ Revenue trend is EMPTY!');
                print(
                  '[Analytics] Date range requested: $_startDate to $_endDate',
                );
              }
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Revenue trend failed: $e');
              throw e;
            }),
        _analyticsProvider
            .getCustomerStatistics(startDate: _startDate, endDate: _endDate)
            .then((data) {
              print('[Analytics] ✅ Customer stats loaded: $data');
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Customer stats failed: $e');
              throw e;
            }),
        _analyticsProvider
            .getReviewStatistics()
            .then((data) {
              print('[Analytics] ✅ Review stats loaded: $data');
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Review stats failed: $e');
              throw e;
            }),
        _analyticsProvider
            .getEmployeePerformance(startDate: _startDate, endDate: _endDate)
            .then((data) {
              print(
                '[Analytics] ✅ Employee performance loaded: ${data.length} items',
              );
              return data;
            })
            .catchError((e) {
              print('[Analytics] ❌ Employee performance failed: $e');
              throw e;
            }),
      ]);

      setState(() {
        _dashboardStats = results[0] as DashboardStatistics;
        _revenueByMethod = results[1] as List<RevenueByMethod>;
        _topProducts = results[2] as List<TopProduct>;
        _topCustomers = results[3] as List<TopCustomer>;
        _categories = results[4] as List<CategoryPerformance>;
        _revenueTrend = results[5] as List<RevenueTrend>;
        _customerStats = results[6] as CustomerStatistics;
        _reviewStats = results[7] as ReviewStatistics;
        _employeePerformance = results[8] as List<EmployeePerformance>;
        _isLoading = false;
      });

      print('[Analytics] ✅ All data loaded successfully!');
      print('[Analytics] ═══════════════════════════════════════════════');
      print('[Analytics] 📊 OLD SCREEN DATA VERIFICATION:');
      print(
        '[Analytics]   • Total Users/Customers: ${_dashboardStats!.totalCustomers}',
      );
      print(
        '[Analytics]   • Total Revenue: \$${_dashboardStats!.totalRevenue.toStringAsFixed(2)}',
      );
      print('[Analytics]   • Revenue Trend Entries: ${_revenueTrend.length}');
      if (_revenueTrend.isNotEmpty) {
        final dailyAvg =
            _revenueTrend.fold<double>(0, (sum, e) => sum + e.revenue) /
            _revenueTrend.length;
        print(
          '[Analytics]   • Daily Average Revenue: \$${dailyAvg.toStringAsFixed(2)}',
        );
      }
      print('[Analytics]   • Top Products: ${_topProducts.length} items');
      print('[Analytics] ═══════════════════════════════════════════════');
      print('[Analytics] 🆕 NEW SCREEN DATA VERIFICATION:');
      print('[Analytics]   • Total Orders: ${_dashboardStats!.totalOrders}');
      print(
        '[Analytics]   • Avg Order Value: \$${_dashboardStats!.averageOrderValue.toStringAsFixed(2)}',
      );
      print(
        '[Analytics]   • Pending Orders: ${_dashboardStats!.pendingOrders}',
      );
      print(
        '[Analytics]   • Completed Orders: ${_dashboardStats!.completedOrders}',
      );
      print(
        '[Analytics]   • Avg Rating: ${_dashboardStats!.averageRating.toStringAsFixed(1)}',
      );
      print(
        '[Analytics]   • Revenue by Method: ${_revenueByMethod.length} methods',
      );
      print('[Analytics]   • Top Customers: ${_topCustomers.length} customers');
      print('[Analytics]   • Categories: ${_categories.length} categories');
      print(
        '[Analytics]   • Employee Performance: ${_employeePerformance.length} employees',
      );
      print('[Analytics] ═══════════════════════════════════════════════');
      _animationController.forward();
    } catch (e) {
      print('[Analytics] ❌ FATAL ERROR loading data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _isAllTime =
            false; // Disable all-time mode when custom range is selected
        _startDate = picked.start;
        // Set end date to end of day (23:59:59) to include entire day
        _endDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
      });
      // Show snackbar to indicate data is reloading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Loading data for ${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}...',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue.shade700,
          ),
        );
      }
      _loadData();
    }
  }

  void _setAllTime() {
    print('[Analytics] ⏰ ALL TIME selected - Setting dates to 2020-01-01');
    final now = DateTime.now();
    setState(() {
      _isAllTime = true; // Enable all-time mode (no date filters)
      _startDate = DateTime(2020, 1, 1);
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
    print('[Analytics]    Start: ${_startDate.toIso8601String()}');
    print('[Analytics]    End: ${_endDate.toIso8601String()}');
    print('[Analytics]    🌍 ALL TIME MODE - Will skip date filters');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Loading all historical data...'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Comprehensive Analytics Dashboard'),
            Text(
              '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Current Tab',
            onPressed: () => _exportCurrentTab(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Date Range',
            onSelected: (value) {
              if (value == 'all_time') {
                _setAllTime();
              } else if (value == 'this_year') {
                final now = DateTime.now();
                setState(() {
                  _isAllTime = false; // Disable all-time mode
                  _startDate = DateTime(now.year, 1, 1);
                  _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                });
                _loadData();
              } else if (value == 'last_30') {
                final now = DateTime.now();
                setState(() {
                  _isAllTime = false; // Disable all-time mode
                  _startDate = now.subtract(const Duration(days: 30));
                  _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                });
                _loadData();
              } else if (value == 'last_90') {
                final now = DateTime.now();
                setState(() {
                  _isAllTime = false; // Disable all-time mode
                  _startDate = now.subtract(const Duration(days: 90));
                  _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                });
                _loadData();
              } else if (value == 'custom') {
                _selectDateRange();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all_time',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 8),
                    Text('All Time'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'this_year',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20),
                    SizedBox(width: 8),
                    Text('This Year'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'last_30',
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 20),
                    SizedBox(width: 8),
                    Text('Last 30 Days'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'last_90',
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 20),
                    SizedBox(width: 8),
                    Text('Last 90 Days'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'custom',
                child: Row(
                  children: [
                    Icon(Icons.edit_calendar, size: 20),
                    SizedBox(width: 8),
                    Text('Custom Range...'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.monetization_on), text: 'Revenue'),
            Tab(icon: Icon(Icons.inventory), text: 'Products'),
            Tab(icon: Icon(Icons.people), text: 'Customers'),
            Tab(icon: Icon(Icons.star), text: 'Reviews'),
            Tab(icon: Icon(Icons.person), text: 'Employees'),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/analytics'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Overview
                _buildOverviewTab(),
                // Tab 2: Revenue
                _buildRevenueTab(),
                // Tab 3: Products
                _buildProductsTab(),
                // Tab 4: Customers
                _buildCustomersTab(),
                // Tab 5: Reviews
                _buildReviewsTab(),
                // Tab 6: Employees
                _buildEmployeesTab(),
              ],
            ),
    );
  }

  // Export current tab to PDF
  Future<void> _exportCurrentTab() async {
    final tabNames = [
      'Overview',
      'Revenue',
      'Products',
      'Customers',
      'Reviews',
      'Employees',
    ];
    final currentTabName = tabNames[_tabController.index];

    try {
      final pdf = pw.Document();

      // Generate PDF based on current tab
      switch (_tabController.index) {
        case 0:
          await _generateOverviewPDF(pdf);
          break;
        case 1:
          await _generateRevenuePDF(pdf);
          break;
        case 2:
          await _generateProductsPDF(pdf);
          break;
        case 3:
          await _generateCustomersPDF(pdf);
          break;
        case 4:
          await _generateReviewsPDF(pdf);
          break;
        case 5:
          await _generateEmployeesPDF(pdf);
          break;
      }

      // Show print/save dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            '${currentTabName}_Analytics_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$currentTabName analytics exported successfully!'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _generateOverviewPDF(pw.Document pdf) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Analytics Overview',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            // Key Metrics
            pw.Text(
              'Key Metrics',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            if (_dashboardStats != null) ...[
              _buildPdfStatRow(
                'Total Revenue',
                '\$${NumberFormat('#,##0.00').format(_dashboardStats!.totalRevenue)}',
              ),
              _buildPdfStatRow(
                'Total Orders',
                _dashboardStats!.totalOrders.toString(),
              ),
              _buildPdfStatRow(
                'Average Order Value',
                '\$${_dashboardStats!.averageOrderValue.toStringAsFixed(2)}',
              ),
              _buildPdfStatRow(
                'Total Customers',
                _dashboardStats!.totalCustomers.toString(),
              ),
              _buildPdfStatRow(
                'New Customers',
                _dashboardStats!.newCustomers.toString(),
              ),
              pw.SizedBox(height: 20),

              // Order Status Breakdown
              pw.Text(
                'Order Status',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfStatRow(
                'Pending',
                _dashboardStats!.pendingOrders.toString(),
              ),
              _buildPdfStatRow(
                'Completed',
                _dashboardStats!.completedOrders.toString(),
              ),
              _buildPdfStatRow(
                'Cancelled',
                _dashboardStats!.cancelledOrders.toString(),
              ),
            ],
          ];
        },
      ),
    );
  }

  Future<void> _generateRevenuePDF(pw.Document pdf) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Revenue Analytics',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            // Revenue Summary
            if (_dashboardStats != null) ...[
              pw.Text(
                'Revenue Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfStatRow(
                'Total Revenue',
                '\$${NumberFormat('#,##0.00').format(_dashboardStats!.totalRevenue)}',
              ),
              _buildPdfStatRow(
                'Revenue Change',
                '${_dashboardStats!.revenueChange >= 0 ? '+' : ''}${_dashboardStats!.revenueChange.toStringAsFixed(1)}%',
              ),
              if (_revenueTrend.isNotEmpty) ...[
                _buildPdfStatRow(
                  'Daily Average',
                  '\$${NumberFormat('#,##0.00').format(_revenueTrend.fold<double>(0, (sum, e) => sum + e.revenue) / _revenueTrend.length)}',
                ),
              ],
              pw.SizedBox(height: 20),
            ],

            // Revenue by Payment Method
            if (_revenueByMethod.isNotEmpty) ...[
              pw.Text(
                'Revenue by Payment Method',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ..._revenueByMethod.map(
                (method) => _buildPdfStatRow(
                  method.paymentMethod,
                  '\$${NumberFormat('#,##0.00').format(method.totalRevenue)}',
                ),
              ),
            ],
          ];
        },
      ),
    );
  }

  Future<void> _generateProductsPDF(pw.Document pdf) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Product Performance Analytics',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            // Top Products
            if (_topProducts.isNotEmpty) ...[
              pw.Text(
                'Top Products',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Rank', 'Product', 'Sold', 'Revenue'],
                data: _topProducts
                    .asMap()
                    .entries
                    .map(
                      (entry) => [
                        '#${entry.key + 1}',
                        entry.value.productName,
                        entry.value.quantitySold.toString(),
                        '\$${NumberFormat('#,##0.00').format(entry.value.totalRevenue)}',
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
            ],

            // Category Performance
            if (_categories.isNotEmpty) ...[
              pw.Text(
                'Category Performance',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Category', 'Revenue', 'Orders', 'Products'],
                data: _categories
                    .map(
                      (cat) => [
                        cat.categoryName,
                        '\$${NumberFormat('#,##0.00').format(cat.totalRevenue)}',
                        cat.orderCount.toString(),
                        cat.productCount.toString(),
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          ];
        },
      ),
    );
  }

  Future<void> _generateCustomersPDF(pw.Document pdf) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Customer Analytics',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            // Customer Statistics
            if (_customerStats != null) ...[
              pw.Text(
                'Customer Statistics',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfStatRow(
                'Total Customers',
                _customerStats!.totalCustomers.toString(),
              ),
              _buildPdfStatRow(
                'New Customers',
                _customerStats!.newCustomers.toString(),
              ),
              _buildPdfStatRow(
                'Returning Customers',
                _customerStats!.returningCustomers.toString(),
              ),
              _buildPdfStatRow(
                'Avg Lifetime Value',
                '\$${NumberFormat('#,##0.00').format(_customerStats!.averageLifetimeValue)}',
              ),
              _buildPdfStatRow(
                'Avg Orders per Customer',
                _customerStats!.averageOrdersPerCustomer.toStringAsFixed(1),
              ),
              pw.SizedBox(height: 20),
            ],

            // Top Customers
            if (_topCustomers.isNotEmpty) ...[
              pw.Text(
                'Top Customers',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Rank', 'Customer', 'Orders', 'Total Spent'],
                data: _topCustomers
                    .asMap()
                    .entries
                    .map(
                      (entry) => [
                        '#${entry.key + 1}',
                        entry.value.customerName,
                        entry.value.totalOrders.toString(),
                        '\$${NumberFormat('#,##0.00').format(entry.value.totalSpent)}',
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          ];
        },
      ),
    );
  }

  Future<void> _generateReviewsPDF(pw.Document pdf) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Review Analytics',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'All Time Statistics',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            if (_reviewStats != null) ...[
              pw.Text(
                'Review Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfStatRow(
                'Total Reviews',
                _reviewStats!.totalReviews.toString(),
              ),
              _buildPdfStatRow(
                'Average Rating',
                _reviewStats!.averageRating.toStringAsFixed(2),
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'Rating Distribution',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfStatRow(
                '5 Stars',
                (_reviewStats!.ratingDistribution[5] ?? 0).toString(),
              ),
              _buildPdfStatRow(
                '4 Stars',
                (_reviewStats!.ratingDistribution[4] ?? 0).toString(),
              ),
              _buildPdfStatRow(
                '3 Stars',
                (_reviewStats!.ratingDistribution[3] ?? 0).toString(),
              ),
              _buildPdfStatRow(
                '2 Stars',
                (_reviewStats!.ratingDistribution[2] ?? 0).toString(),
              ),
              _buildPdfStatRow(
                '1 Star',
                (_reviewStats!.ratingDistribution[1] ?? 0).toString(),
              ),
            ],
          ];
        },
      ),
    );
  }

  Future<void> _generateEmployeesPDF(pw.Document pdf) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Employee Performance Analytics',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            if (_employeePerformance.isNotEmpty) ...[
              pw.Text(
                'Employee Rankings',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  'Rank',
                  'Employee',
                  'Assigned',
                  'Completed',
                  'Revenue',
                ],
                data: _employeePerformance
                    .asMap()
                    .entries
                    .map(
                      (entry) => [
                        '#${entry.key + 1}',
                        entry.value.employeeName,
                        entry.value.assignedOrders.toString(),
                        entry.value.completedOrders.toString(),
                        '\$${NumberFormat('#,##0.00').format(entry.value.totalRevenue)}',
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          ];
        },
      ),
    );
  }

  pw.Widget _buildPdfStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Tab 1: Overview - Dashboard stats and order breakdown
  Widget _buildOverviewTab() {
    if (_dashboardStats == null) {
      return _buildEmptyState(
        icon: Icons.dashboard_outlined,
        title: 'No Overview Data',
        message:
            'Dashboard statistics are not available for the selected date range.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            if (_dashboardStats != null)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _EnhancedStatCard(
                    title: 'Total Revenue',
                    value:
                        '\$${NumberFormat('#,##0.00').format(_dashboardStats!.totalRevenue)}',
                    subtitle:
                        '${_dashboardStats!.revenueChange >= 0 ? '+' : ''}${_dashboardStats!.revenueChange.toStringAsFixed(1)}%',
                    icon: Icons.attach_money,
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    animation: _animationController,
                  ),
                  _EnhancedStatCard(
                    title: 'Total Orders',
                    value: _dashboardStats!.totalOrders.toString(),
                    subtitle:
                        '${_dashboardStats!.ordersChange >= 0 ? '+' : ''}${_dashboardStats!.ordersChange}',
                    icon: Icons.shopping_cart,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    animation: _animationController,
                  ),
                  _EnhancedStatCard(
                    title: 'Avg Order Value',
                    value:
                        '\$${_dashboardStats!.averageOrderValue.toStringAsFixed(2)}',
                    icon: Icons.analytics,
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    animation: _animationController,
                  ),
                  _EnhancedStatCard(
                    title: 'Total Customers',
                    value: _dashboardStats!.totalCustomers.toString(),
                    subtitle: '${_dashboardStats!.newCustomers} new',
                    icon: Icons.people,
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    ),
                    animation: _animationController,
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Order Status Breakdown
            if (_dashboardStats != null)
              _OrderStatusBreakdownChart(
                dashboardStats: _dashboardStats!,
                animation: _animationController,
              ),
          ],
        ),
      ),
    );
  }

  // Tab 2: Revenue - Revenue trend and payment methods
  Widget _buildRevenueTab() {
    if (_revenueTrend.isEmpty && _revenueByMethod.isEmpty) {
      return _buildEmptyState(
        icon: Icons.monetization_on_outlined,
        title: 'No Revenue Data',
        message:
            'No revenue information is available for the selected date range.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue trend chart
            _EnhancedRevenueChartStyled(
              entries: _revenueTrend,
              animation: _animationController,
            ),
            const SizedBox(height: 24),

            // Revenue by payment method
            if (_revenueByMethod.isNotEmpty)
              _RevenueByMethodChart(
                methods: _revenueByMethod,
                animation: _animationController,
              ),
          ],
        ),
      ),
    );
  }

  // Tab 3: Products - Top products and categories
  Widget _buildProductsTab() {
    if (_topProducts.isEmpty && _categories.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No Product Data',
        message:
            'No product sales information is available for the selected date range.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Products
            if (_topProducts.isNotEmpty)
              _EnhancedTopProductsSection(
                products: _topProducts,
                animation: _animationController,
              ),
            const SizedBox(height: 24),

            // Category Performance
            if (_categories.isNotEmpty)
              _CategoryPerformanceSection(
                categories: _categories,
                animation: _animationController,
              ),
          ],
        ),
      ),
    );
  }

  // Tab 4: Customers - Top customers and customer statistics
  Widget _buildCustomersTab() {
    if (_topCustomers.isEmpty && _customerStats == null) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No Customer Data',
        message:
            'No customer information is available for the selected date range.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Customers
            if (_topCustomers.isNotEmpty)
              _TopCustomersSection(
                customers: _topCustomers,
                animation: _animationController,
              ),
            const SizedBox(height: 24),

            // Customer Statistics
            if (_customerStats != null)
              _CustomerStatisticsCard(
                stats: _customerStats!,
                animation: _animationController,
              ),
          ],
        ),
      ),
    );
  }

  // Tab 5: Reviews - Review statistics
  Widget _buildReviewsTab() {
    if (_reviewStats == null || _reviewStats!.totalReviews == 0) {
      return _buildEmptyState(
        icon: Icons.star_outline,
        title: 'No Review Data',
        message: 'No customer reviews are available yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review Statistics
            if (_reviewStats != null)
              _ReviewStatisticsCard(
                stats: _reviewStats!,
                animation: _animationController,
              ),
          ],
        ),
      ),
    );
  }

  // Tab 6: Employees - Employee performance
  Widget _buildEmployeesTab() {
    if (_employeePerformance.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_outline,
        title: 'No Employee Data',
        message:
            'No employee performance data is available for the selected date range.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Performance
            if (_employeePerformance.isNotEmpty)
              _EmployeePerformanceSection(
                employees: _employeePerformance,
                animation: _animationController,
              ),
          ],
        ),
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 120, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Stat Card (same as before)
class _EnhancedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Gradient gradient;
  final AnimationController animation;

  const _EnhancedStatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.gradient,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (animation.value * 0.2),
          child: Opacity(
            opacity: animation.value,
            child: SizedBox(
              width: 180,
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 32, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Revenue Chart WITH Gap Filling & Enhanced Styling (from analytics_screen.dart)
class _EnhancedRevenueChartStyled extends StatelessWidget {
  final List<RevenueTrend> entries;
  final AnimationController animation;

  const _EnhancedRevenueChartStyled({
    required this.entries,
    required this.animation,
  });

  // Generate full date range
  List<DateTime> _getFullDateRange() {
    if (entries.isEmpty) return [];
    final start = entries
        .map((e) => e.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final end = entries
        .map((e) => e.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (i) => start.add(Duration(days: i)));
  }

  // Get revenues for full range (filling gaps with 0)
  List<double> _getRevenuesForFullRange(List<DateTime> fullRange) {
    final map = {for (var e in entries) e.date: e.revenue};
    return fullRange.map((d) => map[d] ?? 0.0).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fullRange = _getFullDateRange();
    final revenues = _getRevenuesForFullRange(fullRange);
    final maxRevenue = revenues.isNotEmpty
        ? revenues.reduce((a, b) => a > b ? a : b)
        : 100.0;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.blue.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.show_chart,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Revenue Trend',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: revenues.isEmpty || maxRevenue == 0
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No revenue data available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: maxRevenue * 1.2,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: maxRevenue > 0
                                    ? maxRevenue / 5
                                    : 20,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '\$${NumberFormat.compact().format(value)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: (fullRange.length / 6)
                                        .ceilToDouble(),
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= fullRange.length) {
                                        return Container();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          DateFormat(
                                            'MMM d',
                                          ).format(fullRange[idx]),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.blueGrey.shade800,
                                  tooltipRoundedRadius: 8,
                                  tooltipPadding: const EdgeInsets.all(12),
                                  getTooltipItems: (spots) {
                                    return spots.map((spot) {
                                      final idx = spot.x.toInt();
                                      final date = fullRange[idx];
                                      final revenue = revenues[idx];
                                      return LineTooltipItem(
                                        '${DateFormat('MMM d, yyyy').format(date)}\n',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                '\$${NumberFormat('#,##0.00').format(revenue)}',
                                            style: TextStyle(
                                              color:
                                                  Colors.greenAccent.shade200,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                ),
                                handleBuiltInTouches: true,
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (int i = 0; i < fullRange.length; i++)
                                      FlSpot(
                                        i.toDouble(),
                                        revenues[i] * animation.value,
                                      ),
                                  ],
                                  isCurved: true,
                                  curveSmoothness: 0.35,
                                  preventCurveOverShooting: true,
                                  color: Colors.purple.shade600,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: Colors.white,
                                            strokeWidth: 2,
                                            strokeColor: Colors.purple.shade600,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade400.withOpacity(0.4),
                                        Colors.blue.shade400.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderStatusBreakdownChart extends StatelessWidget {
  final DashboardStatistics dashboardStats;
  final AnimationController animation;

  const _OrderStatusBreakdownChart({
    required this.dashboardStats,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final total = dashboardStats.totalOrders.toDouble();
    final statuses = [
      {
        'label': 'Pending',
        'value': dashboardStats.pendingOrders.toDouble(),
        'color': Colors.amber.shade600,
      },
      {
        'label': 'Processing',
        'value': dashboardStats.processingOrders.toDouble(),
        'color': Colors.blue.shade600,
      },
      {
        'label': 'Completed',
        'value': dashboardStats.completedOrders.toDouble(),
        'color': Colors.green.shade600,
      },
      {
        'label': 'Cancelled',
        'value': dashboardStats.cancelledOrders.toDouble(),
        'color': Colors.red.shade600,
      },
    ];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.pie_chart,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Order Status Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: statuses.map((status) {
                                final value = status['value'] as double;
                                final percentage = total > 0
                                    ? (value / total * 100)
                                    : 0;
                                return PieChartSectionData(
                                  value: value,
                                  title: '${percentage.toStringAsFixed(0)}%',
                                  color: status['color'] as Color,
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: statuses.map((status) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: status['color'] as Color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            status['label'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${(status['value'] as double).toInt()} orders',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Revenue by Payment Method Chart
class _RevenueByMethodChart extends StatelessWidget {
  final List<RevenueByMethod> methods;
  final AnimationController animation;

  const _RevenueByMethodChart({required this.methods, required this.animation});

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return Colors.blue.shade600;
      case 'cash':
        return Colors.green.shade600;
      case 'bank_transfer':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return 'Credit Card';
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.teal.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Revenue by Payment Method',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: methods.map((method) {
                                return PieChartSectionData(
                                  value: method.totalRevenue,
                                  title:
                                      '${method.percentage.toStringAsFixed(0)}%',
                                  color: _getMethodColor(method.paymentMethod),
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: methods.map((method) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: _getMethodColor(
                                          method.paymentMethod,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getMethodLabel(
                                              method.paymentMethod,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '\$${NumberFormat('#,##0.00').format(method.totalRevenue)} (${method.orderCount})',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Top Products Section (with progress bars from old screen)
class _EnhancedTopProductsSection extends StatelessWidget {
  final List<TopProduct> products;
  final AnimationController animation;

  const _EnhancedTopProductsSection({
    required this.products,
    required this.animation,
  });

  List<Color> _getGradientColors(int index) {
    final gradients = [
      [Colors.amber.shade600, Colors.orange.shade600],
      [Colors.blue.shade600, Colors.cyan.shade600],
      [Colors.purple.shade600, Colors.pink.shade600],
      [Colors.green.shade600, Colors.teal.shade600],
      [Colors.red.shade600, Colors.deepOrange.shade600],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final maxRevenue = products
        .map((e) => e.totalRevenue)
        .reduce((a, b) => a > b ? a : b);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.red.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Top Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...products.take(5).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    final percentage = product.totalRevenue / maxRevenue;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _getGradientColors(index),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${product.quantitySold} sold',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.attach_money,
                                          size: 14,
                                          color: Colors.green.shade600,
                                        ),
                                        Text(
                                          NumberFormat(
                                            '#,##0.00',
                                          ).format(product.totalRevenue),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage * animation.value,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getGradientColors(index)[0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Top Customers Section
class _TopCustomersSection extends StatelessWidget {
  final List<TopCustomer> customers;
  final AnimationController animation;

  const _TopCustomersSection({
    required this.customers,
    required this.animation,
  });

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber.shade600;
      case 1:
        return Colors.grey.shade500;
      case 2:
        return Colors.brown.shade500;
      default:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink.shade400,
                              Colors.purple.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Top Customers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...customers.take(5).map((customer) {
                    final index = customers.indexOf(customer);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _getRankColor(index),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${customer.totalOrders} orders • \$${NumberFormat('#,##0.00').format(customer.totalSpent)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Category Performance Section
class _CategoryPerformanceSection extends StatelessWidget {
  final List<CategoryPerformance> categories;
  final AnimationController animation;

  const _CategoryPerformanceSection({
    required this.categories,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.lime.shade400,
                              Colors.green.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Category Performance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${NumberFormat('#,##0.00').format(category.totalRevenue)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${category.orderCount} orders • ${category.productCount} products',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: category.percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Customer Statistics Card (NEW!)
class _CustomerStatisticsCard extends StatelessWidget {
  final CustomerStatistics stats;
  final AnimationController animation;

  const _CustomerStatisticsCard({required this.stats, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.shade400,
                              Colors.indigo.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.groups,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Customer Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          'Total',
                          stats.totalCustomers.toString(),
                          Icons.people,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          'New',
                          stats.newCustomers.toString(),
                          Icons.person_add,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          'Returning',
                          stats.returningCustomers.toString(),
                          Icons.repeat,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          'Avg Orders',
                          stats.averageOrdersPerCustomer.toStringAsFixed(1),
                          Icons.shopping_bag,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          'Avg LTV',
                          '\$${stats.averageLifetimeValue.toStringAsFixed(2)}',
                          Icons.attach_money,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          'Return Rate',
                          '${stats.totalCustomers > 0 ? (stats.returningCustomers / stats.totalCustomers * 100).toStringAsFixed(1) : '0'}%',
                          Icons.loyalty,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue.shade600),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// Review Statistics Card (NEW!)
class _ReviewStatisticsCard extends StatelessWidget {
  final ReviewStatistics stats;
  final AnimationController animation;

  const _ReviewStatisticsCard({required this.stats, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.rate_review,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Review Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          'Total',
                          stats.totalReviews.toString(),
                          Icons.reviews,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          'Avg Rating',
                          stats.averageRating.toStringAsFixed(1),
                          Icons.star,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          'Pending',
                          stats.pendingReviews.toString(),
                          Icons.pending,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          'Approved',
                          stats.approvedReviews.toString(),
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rating Distribution:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(5, (index) {
                    final rating = 5 - index;
                    final count = stats.ratingDistribution[rating] ?? 0;
                    final percentage = stats.totalReviews > 0
                        ? (count / stats.totalReviews)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Row(
                              children: [
                                Text(
                                  '$rating',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.amber.shade600,
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Employee Performance Section (NEW!)
class _EmployeePerformanceSection extends StatelessWidget {
  final List<EmployeePerformance> employees;
  final AnimationController animation;

  const _EmployeePerformanceSection({
    required this.employees,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade400,
                              Colors.indigo.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.badge,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Employee Performance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...employees.take(5).map((employee) {
                    final index = employees.indexOf(employee);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade400,
                                  Colors.indigo.shade600,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee.employeeName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${employee.completedOrders}/${employee.assignedOrders}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.attach_money,
                                      size: 14,
                                      color: Colors.green.shade600,
                                    ),
                                    Text(
                                      '\$${NumberFormat('#,##0.00').format(employee.totalRevenue)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Colors.teal.shade600,
                                    ),
                                    Text(
                                      '${employee.completionRate.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
