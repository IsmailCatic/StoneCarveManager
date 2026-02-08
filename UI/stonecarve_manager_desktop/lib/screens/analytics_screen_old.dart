import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/utils/auth_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
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
        'User count response: \\${userCountResp.statusCode} \\${userCountResp.body}',
      );
      final totalIncomeResp = await client.get(
        Uri.parse('http://localhost:5021/api/Analytics/total-income'),
      );
      print(
        'Total income response: \\${totalIncomeResp.statusCode} \\${totalIncomeResp.body}',
      );
      final dailyIncomeResp = await client.get(
        Uri.parse('http://localhost:5021/api/Analytics/daily-income'),
      );
      print(
        'Daily income response: \\${dailyIncomeResp.statusCode} \\${dailyIncomeResp.body}',
      );
      final topProductsResp = await client.get(
        Uri.parse('http://localhost:5021/api/Analytics/top-products?topN=5'),
      );
      print(
        'Top products response: \\${topProductsResp.statusCode} \\${topProductsResp.body}',
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
    return Scaffold(
      appBar: AppBar(title: const Text('Analitika i Statistika')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Greška: $error'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCard(
                        title: 'Broj korisnika',
                        value: userCount?.toString() ?? '-',
                        icon: Icons.people,
                      ),
                      _StatCard(
                        title: 'Ukupni prihodi',
                        value: totalIncome != null
                            ? '${totalIncome!.toStringAsFixed(2)}'
                            : '-',
                        icon: Icons.attach_money,
                      ),
                      _StatCard(
                        title: 'Dnevni prosjek',
                        value: dailyIncome != null
                            ? '${dailyIncome!.toStringAsFixed(2)}'
                            : '-',
                        icon: Icons.bar_chart,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Najprodavaniji proizvodi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (topProducts.isNotEmpty)
                    TopProductsBarChart(products: topProducts),
                  const SizedBox(height: 24),
                  if (dailyIncomeEntries.isNotEmpty)
                    Builder(
                      builder: (context) {
                        final fullRange = getFullDateRange(dailyIncomeEntries);
                        final amounts = getAmountsForFullRange(
                          fullRange,
                          dailyIncomeEntries,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prihodi po danima',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 260,
                              child: LineChart(
                                LineChartData(
                                  minY: 0,
                                  maxY: (amounts.isNotEmpty
                                      ? amounts.reduce(
                                              (a, b) => a > b ? a : b,
                                            ) *
                                            1.1
                                      : 10),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 10,
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: (fullRange.length / 7)
                                            .ceilToDouble(),
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx < 0 ||
                                              idx >= fullRange.length)
                                            return Container();
                                          final date = fullRange[idx];
                                          return Text(
                                            DateFormat('E\nd/M').format(date),
                                            style: TextStyle(fontSize: 10),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      tooltipBgColor: Colors.white,
                                      getTooltipItems: (spots) => spots.map((
                                        spot,
                                      ) {
                                        final idx = spot.x.toInt();
                                        final date = fullRange[idx];
                                        final amt = amounts[idx];
                                        return LineTooltipItem(
                                          '${DateFormat('MMM d').format(date)}\n${amt.toStringAsFixed(2)} KM',
                                          TextStyle(color: Colors.black),
                                        );
                                      }).toList(),
                                    ),
                                    handleBuiltInTouches: true,
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: [
                                        for (
                                          int i = 0;
                                          i < fullRange.length;
                                          i++
                                        )
                                          FlSpot(i.toDouble(), amounts[i]),
                                      ],
                                      isCurved: true,
                                      color: Colors.deepPurple,
                                      barWidth: 3,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.deepPurple.withOpacity(0.3),
                                            Colors.deepPurple.withOpacity(0.01),
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
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
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

class TopProductsBarChart extends StatelessWidget {
  final List<TopProduct> products;
  const TopProductsBarChart({required this.products, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: products.length * 48.0,
          width: double.infinity,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  (products
                      .map((e) => e.soldQuantity)
                      .reduce((a, b) => a > b ? a : b) *
                  1.1.ceilToDouble()),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: theme.cardColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final p = products[group.x.toInt()];
                    return BarTooltipItem(
                      '${p.productName}\nSold: ${p.soldQuantity}',
                      theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= products.length) return Container();
                      return Text(
                        products[idx].productName,
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (int i = 0; i < products.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: products[i].soldQuantity.toDouble(),
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
