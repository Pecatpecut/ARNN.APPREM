import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

// widgets
import '../../widgets/shared/spacing.dart';
import '../../widgets/buttons/primary_button.dart';

// service
import '../../services/order_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Duration timeLeft = const Duration(hours: 23, minutes: 59, seconds: 59);
  Timer? timer;

  XFile? pickedFile;
  Uint8List? imageBytes;

  final orderService = OrderService();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft.inSeconds > 0) {
        setState(() {
          timeLeft -= const Duration(seconds: 1);
        });
      }
    });
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        pickedFile = picked;
        imageBytes = bytes;
      });
    }
  }

  Future<String?> uploadPaymentProof(String userId) async {
    if (pickedFile == null || imageBytes == null) return null;

    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('payment-proofs')
        .uploadBinary(fileName, imageBytes!);

    return supabase.storage
        .from('payment-proofs')
        .getPublicUrl(fileName);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text("No Data")),
      );
    }

    /// 🔥 DATA DARI CHECKOUT
    final product = args["product"];
    final variant = args["variant"];
    final email = args["email"];

    final title = product["name"];
    final price = variant["price"];
    final priceText = "Rp $price";

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: theme.colorScheme.surface,
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

        child: Padding(
          padding: const EdgeInsets.all(AppConstants.padding),
          
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _StepItem("1", "Product", true),
                  _StepItem("2", "Payment", true), // 🔥 aktif sekarang
                  _StepItem("3", "Confirm", false),
                ],
              ),
              Space.h20,
              /// 🔥 TIMER
              Column(
                children: [
                  Icon(Icons.access_time,
                      size: 50, color: theme.colorScheme.primary),
                  Space.h10,
                  Text(
                    "Waiting for Payment",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Space.h10,
                  Text(
                    "Expires in ${formatTime(timeLeft)}",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Space.h20,

              /// 🔥 QRIS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.6),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radius),
                ),
                child: Column(
                  children: [
                    const Text("QRIS Payment",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    Space.h15,

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/qris.png',
                        height: 150,
                      ),
                    ),

                    Space.h15,

                    Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              Space.h20,

              /// 🔥 SUMMARY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radius),
                ),
                child: Column(
                  children: [
                    _row("Product", title),
                    _row("Subtotal", priceText),
                    _row("Service Fee", "Rp 0"),
                    const Divider(),
                    _row("Total", priceText, bold: true),
                  ],
                ),
              ),

              Space.h20,

              /// 🔥 UPLOAD
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radius),
                    border: Border.all(color: Colors.grey),
                  ),
                    child: imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radius),
                          child: Image.memory(imageBytes!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : const Center(child: Text("Upload Proof of Payment")
                      ),
                ),
              ),

              Space.h30,

              /// 🔥 BUTTON (INI YANG PENTING)
              PrimaryButton(
                text: "Confirm Payment",
                onTap: () async {
                  final user = Supabase.instance.client.auth.currentUser;

                  if (user == null) return;

                  final ctx = context;

                  try {
                    // Upload bukti bayar dulu
                    final paymentProofUrl = await uploadPaymentProof(user.id);

                    await orderService.createOrder(
                      userId: user.id,
                      product: product,
                      variant: variant,
                      email: email,
                      paymentProof: paymentProofUrl,
                    );

                    if (!mounted) return; // 🔥 WAJIB

                    showDialog(
                      context: ctx,
                      builder: (_) => AlertDialog(
                        title: const Text("Success"),
                        content: const Text("Pesanan berhasil dibuat"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pushNamed(ctx, '/orders');
                            },
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );

                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text("Gagal: $e")),
                    );
                  }
                },
              ),  

              Space.h20,
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}  

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final bool isActive;

  const _StepItem(this.number, this.title, this.isActive);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.primary,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}