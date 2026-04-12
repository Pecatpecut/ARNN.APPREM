import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/order_service.dart';

class AdminOrderDetailPage extends StatefulWidget {
  const AdminOrderDetailPage({super.key});

  @override
  State<AdminOrderDetailPage> createState() =>
      _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState
    extends State<AdminOrderDetailPage> {

  final OrderService service = OrderService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final data =
        ModalRoute.of(context)?.settings.arguments as Map?;

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("No Data")),
      );
    }

    final status = data['status'] ?? 'pending';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Order Detail"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
        ),

        child: ListView(
          padding: const EdgeInsets.all(AppConstants.padding),
          children: [

            /// 🔥 CARD INFO
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _item("Product", data['product_name']),
                  _item("Variant", data['variant_type']),
                  _item("Price", "Rp ${data['price']}"),
                  _item("Duration",
                      "${data['duration_days']} hari"),

                  const SizedBox(height: 10),

                  _statusBadge(status),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 BUKTI PAYMENT
            if (data['payment_proof'] != null &&
                data['payment_proof'].toString().isNotEmpty)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bukti Pembayaran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['payment_proof'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text("Gagal load gambar"),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            /// 🔥 ACCOUNT INFO (JIKA SUDAH ADA)
            if (data['account_email'] != null)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _item("Email", data['account_email']),
                    _item("Password", data['account_password']),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            /// 🔥 ACTION BUTTON
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _approveDialog(context, data);
                      },
                      child: const Text("Approve"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await service.updateOrderStatus(
                            data['id'], 'rejected');

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      child: const Text("Reject"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🔥 APPROVE DIALOG
  void _approveDialog(BuildContext context, Map data) {
    print("STATUS: ${data['status']}"); // ← tambah ini
    print("DATA: $data");
    final emailController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Input Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passController,
              decoration:
                  const InputDecoration(labelText: "Password"),
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
              await service.approveOrderManual(
                orderId: data['id'],
                email: emailController.text,
                password: passController.text,
              );

              if (!mounted) return;

              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to list
            },
            child: const Text("Approve"),
          ),
        ],
      ),
    );
  }

  /// 🔥 CARD UI
  Widget _card({required Widget child}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius:
            BorderRadius.circular(AppConstants.radius),
      ),
      child: child,
    );
  }

  /// 🔥 ITEM TEXT
  Widget _item(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text("$title : ${value ?? '-'}"),
    );
  }

  /// 🔥 STATUS BADGE
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
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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