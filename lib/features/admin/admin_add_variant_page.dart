import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/product_service.dart';

class AdminAddVariantPage extends StatefulWidget {
  const AdminAddVariantPage({super.key});

  @override
  State<AdminAddVariantPage> createState() =>
      _AdminAddVariantPageState();
}

class _AdminAddVariantPageState
    extends State<AdminAddVariantPage> {
  final service = ProductService();

  final typeController = TextEditingController();
  final priceController = TextEditingController();
  final modalPriceController = TextEditingController();
  final durationController = TextEditingController();

  Map? variant;
  late Map product;

  String durationUnit = "Days";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map;

    product = args;
    variant = args['variant'];

    if (variant != null) {
      typeController.text = variant!['type'];
      priceController.text = variant!['price'].toString();
      durationController.text =
          variant!['duration_days'].toString();
      modalPriceController.text =
          (variant!['modal_price'] ?? '').toString();
    }
  }

  Future<void> submit() async {
    final price = int.parse(priceController.text);
    final modal = modalPriceController.text.isEmpty
        ? null
        : int.parse(modalPriceController.text);

    if (variant == null) {
      await service.supabase.from('product_variants').insert({
        "product_id": product['id'],
        "type": typeController.text,
        "price": price,
        "modal_price": modal,
        "duration_days": int.parse(durationController.text),
        "is_active": true,
      });
    } else {
      await service.updateVariant(variant!['id'], {
        "type": typeController.text,
        "price": price,
        "modal_price": modal,
        "duration_days": int.parse(durationController.text),
      });
    }

    Navigator.pop(context);
  }

  Future<void> delete() async {
    await service.deleteVariant(variant!['id']);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = variant != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: Text(isEdit ? "Edit Variant" : "Add Variant"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: submit,
            child: const Text("Save"),
          )
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(AppConstants.padding),
        children: [

          /// 🔥 HEADER TEXT
          Text(
            "Refine Your\nSubscription Tiers",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Adjust pricing, duration, and features.",
            style: TextStyle(
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 BANNER
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6F5FEA),
                  Color(0xFF5AF9F3),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// 🔥 FORM CARD
          _card([
            _input("Variant Name", typeController),
            _input("Price", priceController,
                isNumber: true),

            _input("Modal Price (optional)",
                modalPriceController,
                isNumber: true),

            /// 🔥 DURATION
            Row(
              children: [
                Expanded(
                  child: _input(
                      "Duration", durationController,
                      isNumber: true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField(
                    initialValue: durationUnit,
                    items: ["Days", "Months"]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => durationUnit = v!),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
          ]),

          const SizedBox(height: 20),

          /// 🔥 DELETE BUTTON (EDIT ONLY)
          if (isEdit)
            GestureDetector(
              onTap: delete,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),
                  color: Colors.red.withValues(alpha: 0.2),
                ),
                child: const Center(
                  child: Text(
                    "Delete Variant",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🔥 CARD WRAPPER
  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surface
            .withValues(alpha: 0.6),
      ),
      child: Column(children: children),
    );
  }

  /// 🔥 INPUT STYLE
  Widget _input(String label, TextEditingController c,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding:
              const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).brightness ==
                    Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
          child: TextField(
            controller: c,
            keyboardType: isNumber
                ? TextInputType.number
                : TextInputType.text,
            decoration:
                const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}