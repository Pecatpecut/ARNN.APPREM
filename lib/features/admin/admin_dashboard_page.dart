import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState
    extends State<AdminDashboardPage> {

String formatRupiah(int value) {
  final format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return format.format(value);
}
      
  final adminService = AdminService();

  int totalOrders = 0;
  int totalUsers = 0;
  int totalIncome = 0;
  List<int> monthlyIncome = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final orders = await adminService.getTotalOrders();
    final users = await adminService.getTotalUsers();
    final income = await adminService.getTotalIncome();
    final monthly = await adminService.getMonthlyIncome();

    setState(() {
      totalOrders = orders;
      totalUsers = users;
      totalIncome = income;
      monthlyIncome = monthly;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      /// ❌ FAB DIHAPUS

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  children: [

 /// 🔥 TOP NAVBAR (UPGRADE)
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// 🔥 NAVBAR
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
              child: Icon(Icons.grid_view,
                  color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),

            /// 🔥 BRAND (DIBESARIN)
            Text(
              "Arini Store",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20, // 🔥 lebih besar
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        const CircleAvatar(
          radius: 20,
          child: Icon(Icons.person),
        )
      ],
    ),

    const SizedBox(height: 25),

    /// 🔥 TITLE + BUTTONS
    Text(
      "SYSTEM OVERVIEW",
      style: TextStyle(
        fontSize: 12,
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(height: 6),

    Text(
      "Admin Dashboard",
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(height: 20),

    /// 🔥 BUTTONS (INI YANG KAMU MAU)
    Row(
      children: [

        /// EXPORT
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.surface.withValues(alpha: 0.6),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download, size: 18),
                SizedBox(width: 8),
                Text("Export Report"),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        /// ADD PRODUCT
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/admin-add-product');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Add Product",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ],
),

  /// 🔥 SINGLE STAT CARD (INI YANG KAMU MAU)
  _bigCard(
    title: "Total Transactions",
    value: "$totalOrders",
    icon: Icons.receipt_long,
    growth: "+14%",
  ),

  const SizedBox(height: 15),

  _bigCard(
    title: "Total Income",
    value: formatRupiah(totalIncome),
    icon: Icons.attach_money,
    growth: "+8%",
  ),

  const SizedBox(height: 15),

  _bigCard(
    title: "Active Users",
    value: "$totalUsers",
    icon: Icons.people,
    growth: "-2%",
    isNegative: true,
  ),

  const SizedBox(height: 25),

  /// 🔥 CHART
  Text(
    "Monthly Income",
    style: theme.textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.bold),
  ),

  const SizedBox(height: 15),

  _chart(monthlyIncome),

  const SizedBox(height: 30),
],
                ),
        ),
      ),
    );
  }


Widget _bigCard({
  required String title,
  required String value,
  required IconData icon,
  required String growth,
  bool isNegative = false,
}) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),

      gradient: LinearGradient(
        colors: theme.brightness == Brightness.dark
            ? [
                const Color(0xFF1B1B2F),
                const Color(0xFF1F1F3A),
              ]
            : [
                theme.colorScheme.primary.withValues(alpha: 0.08),
                theme.colorScheme.surface,
              ],
      ),

      border: Border.all(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
    ),
    child: Row(
      children: [

        /// ICON
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),

        const SizedBox(width: 15),

        /// TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    growth,
                    style: TextStyle(
                      color: isNegative ? Colors.red : Colors.green,
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
  );
}

Widget _chart(List<int> data) {
  final theme = Theme.of(context);

  final months = [
    "Jan", "Feb", "Mar", "Apr",
    "Mei", "Jun", "Jul", "Agu",
    "Sep", "Okt", "Nov", "Des"
  ];

  return Container(
    height: 260,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.surface.withValues(alpha: 0.6),
      border: Border.all(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
    ),
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b)) * 1.2,

        /// 🔥 TOOLTIP (INI YANG INTERAKTIF)
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 10,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = data[groupIndex];
              return BarTooltipItem(
                "Rp ${value.toString()}",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),

        /// 🔥 AXIS BAWAH (BULAN)
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= data.length) return const SizedBox();

                return Text(
                  months[index % 12],
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),

        /// 🔥 GRID
        gridData: FlGridData(
          show: true,
          horizontalInterval: 20000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              strokeWidth: 1,
            );
          },
        ),

        /// 🔥 BAR DATA
        barGroups: List.generate(data.length, (index) {
          final value = data[index];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value.toDouble(),
                width: 14,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    ),
  );
}
    }