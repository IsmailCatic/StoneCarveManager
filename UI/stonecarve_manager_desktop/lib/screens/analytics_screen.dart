import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/utils/auth_client.dart';
import 'package:stonecarve_manager_flutter/widgets/app_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  int? userCount;
  double? totalIncome;
  double? dailyIncome;
  List<TopProduct> topProducts = [];
  List<DailyIncomeEntry> dailyIncomeEntries = [];
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    print('AnalyticsScreen: initState called');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    fetchAnalytics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchAnalytics() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final client = AuthClient(getToken: () async => AuthProvider.token);
      print('Fetching user count...');
      final userCountResp = await client.get(
        Uri.parse('http://localhost:5021/api/Analytics/user-count'),
      );
      print(
        'User count response: ${userCountResp.statusCode} ${userCountResp.body}',
      );
      final totalIncomeResp = await client.get(
        Uri.parse('http://localhost:5021/api/Analytics/total-income'),
      );
      print(
        'Total income response: ${totalIncomeResp.statusCode} ${totalIncomeResp.body}',
      );
      final dailyIncomeResp = await client.get(
        Uri.parse('http://localhost:5021/api/Analytics/daily-income'),
      );
      print(
        'Daily income response: ${dailyIncomeResp.statusCode} ${dailyIncomeResp.body}',
      );
      final topProductsResp = await client.get(
        Uri.parse('http://localhost:5021/api/Analytics/top-products?topN=5'),
      );
      print(
        'Top products response: ${topProductsResp.statusCode} ${topProductsResp.body}',
      );

      if (userCountResp.statusCode == 200) {
        userCount = int.tryParse(userCountResp.body);
      }
      if (totalIncomeResp.statusCode == 200) {
        totalIncome = double.tryParse(totalIncomeResp.body);
      }
      if (dailyIncomeResp.statusCode == 200) {
        // Handle daily income as a list
        final List<dynamic> dailyList = json.decode(dailyIncomeResp.body);
        dailyIncomeEntries = dailyList
            .map((e) => DailyIncomeEntry.fromJson(e))
            .toList();
        if (dailyIncomeEntries.isNotEmpty) {
          dailyIncome = dailyIncomeEntries.first.amount;
        }
      }
      if (topProductsResp.statusCode == 200) {
        final List<dynamic> data = json.decode(topProductsResp.body);
        topProducts = data.map((e) => TopProduct.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching analytics: $e');
      error = e.toString();
    }
    setState(() {
      isLoading = false;
    });
    if (error == null) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Statistics'),
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
      ),
      drawer: const AppDrawer(currentRoute: '/analytics'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchAnalytics,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header gradient section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade700,
                            Colors.purple.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Business Overview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Stats cards
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _EnhancedStatCard(
                                    title: 'Total Users',
                                    value: userCount?.toString() ?? '0',
                                    icon: Icons.people_outline,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade600,
                                      ],
                                    ),
                                    animation: _animationController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _EnhancedStatCard(
                                    title: 'Total Revenue',
                                    value: totalIncome != null
                                        ? '\$${NumberFormat('#,##0.00').format(totalIncome)}'
                                        : '\$0.00',
                                    icon: Icons.attach_money,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ],
                                    ),
                                    animation: _animationController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _EnhancedStatCard(
                                    title: 'Daily Average',
                                    value: dailyIncome != null
                                        ? '\$${NumberFormat('#,##0.00').format(dailyIncome)}'
                                        : '\$0.00',
                                    icon: Icons.trending_up,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade400,
                                        Colors.orange.shade600,
                                      ],
                                    ),
                                    animation: _animationController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    // Content section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Revenue trend chart
                          if (dailyIncomeEntries.isNotEmpty)
                            _EnhancedRevenueChart(
                              entries: dailyIncomeEntries,
                              animation: _animationController,
                            ),

                          const SizedBox(height: 24),

                          // Top products section
                          if (topProducts.isNotEmpty)
                            _EnhancedTopProductsSection(
                              products: topProducts,
                              animation: _animationController,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Enhanced Stat Card with animation
class _EnhancedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final AnimationController animation;

  const _EnhancedStatCard({
    required this.title,
    required this.value,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(icon, size: 40, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Enhanced Revenue Chart
class _EnhancedRevenueChart extends StatelessWidget {
  final List<DailyIncomeEntry> entries;
  final AnimationController animation;

  const _EnhancedRevenueChart({required this.entries, required this.animation});

  List<DateTime> getFullDateRange(List<DailyIncomeEntry> entries) {
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

  List<double> getAmountsForFullRange(
    List<DateTime> fullRange,
    List<DailyIncomeEntry> entries,
  ) {
    final map = {for (var e in entries) e.date: e.amount};
    return fullRange.map((d) => map[d] ?? 0.0).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fullRange = getFullDateRange(entries);
    final amounts = getAmountsForFullRange(fullRange, entries);

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
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: (amounts.isNotEmpty
                            ? amounts.reduce((a, b) => a > b ? a : b) * 1.2
                            : 100),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: amounts.isNotEmpty
                              ? amounts.reduce((a, b) => a > b ? a : b) / 5
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
                              interval: (fullRange.length / 6).ceilToDouble(),
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= fullRange.length) {
                                  return Container();
                                }
                                final date = fullRange[idx];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('MMM d').format(date),
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
                            getTooltipItems: (spots) => spots.map((spot) {
                              final idx = spot.x.toInt();
                              final date = fullRange[idx];
                              final amt = amounts[idx];
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
                                        '\$${NumberFormat('#,##0.00').format(amt)}',
                                    style: TextStyle(
                                      color: Colors.greenAccent.shade200,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          handleBuiltInTouches: true,
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (int i = 0; i < fullRange.length; i++)
                                FlSpot(
                                  i.toDouble(),
                                  amounts[i] * animation.value,
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
                              getDotPainter: (spot, percent, barData, index) {
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

// Enhanced Top Products Section
class _EnhancedTopProductsSection extends StatelessWidget {
  final List<TopProduct> products;
  final AnimationController animation;

  const _EnhancedTopProductsSection({
    required this.products,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final maxIncome = products
        .map((e) => e.totalIncome)
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
                  ...products.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    final percentage = (product.totalIncome / maxIncome);

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
                                          '${product.soldQuantity} sold',
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
                                          ).format(product.totalIncome),
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
}

// Models
class TopProduct {
  final int productId;
  final String productName;
  final int soldQuantity;
  final double totalIncome;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.soldQuantity,
    required this.totalIncome,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'],
      productName: json['productName'],
      soldQuantity: json['soldQuantity'],
      totalIncome: (json['totalIncome'] as num).toDouble(),
    );
  }
}

class DailyIncomeEntry {
  final DateTime date;
  final double amount;
  DailyIncomeEntry({required this.date, required this.amount});
  factory DailyIncomeEntry.fromJson(Map<String, dynamic> json) {
    return DailyIncomeEntry(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
