import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/order_service.dart';

class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({super.key});

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage>
    with SingleTickerProviderStateMixin {

  final OrderService _service = OrderService();

  List orders = [];
  bool isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetch();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> fetch() async {
    final data = await _service.getAllOrders();

    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  /// 🔥 FILTER BY STATUS
  List getOrdersByStatus(String status) {
    return orders.where((o) => o['status'] == status).toList();
  }

  /// 🔥 APPROVE DIALOG
  void approveDialog(Map o) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Input Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _service.approveOrderManual(
                orderId: o['id'],
                email: emailController.text,
                password: passwordController.text,
              );

              Navigator.pop(context);
              fetch();
            },
            child: const Text("Approve"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Order Management"),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(getOrdersByStatus('pending')),
                _buildList(getOrdersByStatus('approved')),
                _buildList(getOrdersByStatus('rejected')),
              ],
            ),
    );
  }

  /// 🔥 LIST BUILDER
  Widget _buildList(List data) {
    if (data.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.padding),
      children: data.map((o) => _orderCard(o)).toList(),
    );
  }

  /// 🔥 CARD
  Widget _orderCard(Map o) {
    final theme = Theme.of(context);
    final status = o['status'];

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/admin-order-detail',
          arguments: o,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppConstants.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  o['product_name'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _statusBadge(status),
              ],
            ),

            const SizedBox(height: 8),

            Text("Variant: ${o['variant_type']}"),
            Text("Price: Rp ${o['price']}"),

            const SizedBox(height: 10),

            if (o['account_email'] != null)
              Text("Email: ${o['account_email']}"),

            if (o['account_password'] != null)
              Text("Password: ${o['account_password']}"),

            const SizedBox(height: 10),

            if (status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => approveDialog(o),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      await _service.updateOrderStatus(o['id'], 'rejected');
                      fetch();
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// 🔥 BADGE
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(color: color),
      ),
    );
  }
}