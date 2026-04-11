import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';

// widgets
import '../../widgets/shared/spacing.dart';
import '../../widgets/shared/status_badge.dart';
import '../../widgets/buttons/primary_button.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final supabase = Supabase.instance.client;

  Map? subscription;
  bool isLoadingSubs = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = ModalRoute.of(context)?.settings.arguments as Map?;
    if (data != null) fetchSubscription(data['id']);
  }

  Future<void> fetchSubscription(String orderId) async {
    try {
      final data = await supabase
          .from('subscriptions')
          .select()
          .eq('order_id', orderId)
          .maybeSingle();

      setState(() {
        subscription = data;
        isLoadingSubs = false;
      });
    } catch (e) {
      setState(() => isLoadingSubs = false);
    }
  }

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    final date = DateTime.tryParse(raw);
    if (date == null) return '-';
    return "${date.day}/${date.month}/${date.year}";
  }

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

    final productName = data["product_name"] ?? "-";
    final variant = data["variant_type"] ?? "-";
    final duration = data["duration_days"] ?? 0;
    final price = data["price"] ?? 0;
    final status = data["status"] ?? "pending";
    final date = data["created_at"] ?? "-";
    final email = data["account_email"] ?? "-";
    final password = data["account_password"] ?? "-";
    final imageUrl = data['products'] != null ? data['products']['image'] : null;

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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: ListView(
          padding: const EdgeInsets.all(AppConstants.padding),
          children: [

            /// 🔥 IMAGE
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.brightness == Brightness.dark
              ? Colors.black
              : theme.colorScheme.surface,
              ),
              clipBehavior: Clip.hardEdge,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        productName[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
            ),

  Container(
  padding: const EdgeInsets.all(18),
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
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              productName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          StatusBadge(status: status),
        ],
      ),

      Space.h10,

      Text(
        "Premium Subscription",
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),

      Space.h15,

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$variant ($duration Days)",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            "Rp $price",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      Space.h10,

      Text(
        "Order Date: $date",
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    ],
  ),
),

            Space.h20,

            if (status == 'approved' || status == 'active')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppConstants.radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Subscription Info",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Space.h10,
                    isLoadingSubs
                        ? const CircularProgressIndicator()
                        : subscription == null
                            ? const Text("Belum ada data subscription")
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Start: ${_formatDate(subscription!['start_date'])}"),
                                  Text("End: ${_formatDate(subscription!['end_date'])}"),
                                  Text("Status: ${subscription!['status'] ?? '-'}"),
                                ],
                              ),
                  ],
                ),
              ),

            Space.h20,

            /// 🔥 ACCOUNT INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface
                    .withValues(alpha: 0.7),
                borderRadius:
                    BorderRadius.circular(AppConstants.radius),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Information",
                    style: TextStyle(
                        fontWeight: FontWeight.bold),
                  ),

                  Space.h10,

                  Text("Email: $email"),
                  Text("Password: $password"),
                ],
              ),
            ),

            Space.h20,

            /// 🔥 CLAIM
            PrimaryButton(
              text: "Claim Warranty",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/garansi-form',
                  arguments: data,
                );
              },
            ),

            Space.h10,

            /// 🔥 WHATSAPP BUTTON
            PrimaryButton(
              text: "Contact Support",
              onTap: () async {
                final phone = "6285349661585";
                final message =
                    "Halo admin, saya butuh bantuan untuk order $productName";

                final url = Uri.parse(
                    "https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

                if (await canLaunchUrl(url)) {
                  await launchUrl(url,
                      mode: LaunchMode.externalApplication);
                }
              },
            ),

            Space.h20,
          ],
        ),
      ),
    );
  }
}