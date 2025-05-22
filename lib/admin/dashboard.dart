import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int totalDonors = 0;
  double totalAmount = 0;
  double thisMonthAmount = 0;
  double topDonation = 0;
  List<Map<String, dynamic>> monthlyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
    fetchMonthlyData();
    fetchTopDonation();
  }

  Future<void> fetchStats() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/stats'),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        totalDonors = data['totalDonors'] ?? 0;
        totalAmount = double.tryParse(data['totalAmount'].toString()) ?? 0.0;
        thisMonthAmount =
            double.tryParse(data['thisMonthAmount'].toString()) ?? 0.0;
      });
    }
  }

  Future<void> fetchTopDonation() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/top-donor'),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        topDonation =
            double.tryParse(data['topDonor']?['amount'].toString() ?? '') ??
            0.0;
      });
    }
  }

  Future<void> fetchMonthlyData() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://backend-owxp.onrender.com/api/admin/monthly-donation',
        ),
      );
      if (res.statusCode == 200) {
        final List decoded = json.decode(res.body);
        print("Monthly Donations API Response: $decoded");

        setState(() {
          monthlyData =
              decoded
                  .map(
                    (e) => {
                      'month': e['month'],
                      'amount': double.tryParse(e['amount'].toString()) ?? 0,
                    },
                  )
                  .toList();
        });
      } else {
        print('Failed to load monthly donations: ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching monthly donations: $e');
    }
  }

  double _getChartMaxY() {
    if (monthlyData.isEmpty) return 10000;
    double maxVal = monthlyData
        .map((e) => e['amount'] as double)
        .reduce((a, b) => a > b ? a : b);
    return ((maxVal / 2000).ceil() * 2000).toDouble();
  }

  Widget buildFixedSizeStatCard(
    String title,
    dynamic value,
    Color color,
    double width,
  ) {
    return SizedBox(
      width: width,
      height: 130,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "👋 Welcome Admin!",
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 20 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),

                  // Stat Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double width = constraints.maxWidth;
                      double cardWidth =
                          width < 600 ? (width - 16) / 2 : (width - 48) / 4;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          buildFixedSizeStatCard(
                            "Total Donors",
                            totalDonors,
                            Colors.blue,
                            cardWidth,
                          ),
                          buildFixedSizeStatCard(
                            "Total Amount",
                            "₹${totalAmount.toStringAsFixed(2)}",
                            Colors.green,
                            cardWidth,
                          ),
                          buildFixedSizeStatCard(
                            "This Month",
                            "₹${thisMonthAmount.toStringAsFixed(2)}",
                            Colors.orange,
                            cardWidth,
                          ),
                          buildFixedSizeStatCard(
                            "Top Donation",
                            "₹${topDonation.toStringAsFixed(2)}",
                            Colors.purple,
                            cardWidth,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Chart Title
                  const Text(
                    "Monthly Donations",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Chart
                  SizedBox(
                    width: double.infinity,
                    height: screenWidth < 600 ? 300 : 350,
                    child: monthlyData.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: Colors.red,))
                            : LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: _getChartMaxY(),
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        if (value.toInt() <
                                            monthlyData.length) {
                                          return Text(
                                            monthlyData[value.toInt()]['month']
                                                .substring(0, 3),
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: 2000,
                                      getTitlesWidget: (value, _) {
                                        return Text(
                                          '₹${value.toInt()}',
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    isCurved: true,
                                    color: Colors.red,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.withOpacity(0.3),
                                          Colors.red.withOpacity(0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    spots:
                                        monthlyData
                                            .asMap()
                                            .entries
                                            .map(
                                              (e) => FlSpot(
                                                e.key.toDouble(),
                                                e.value['amount'],
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    tooltipRoundedRadius: 8,
                                    tooltipPadding: const EdgeInsets.all(8),
                                    tooltipMargin: 8,
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((spot) {
                                        return LineTooltipItem(
                                          '₹${spot.y.toStringAsFixed(2)}',
                                          const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
