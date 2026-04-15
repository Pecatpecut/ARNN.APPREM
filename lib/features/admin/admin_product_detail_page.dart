import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/product_service.dart';

class AdminProductDetailPage extends StatefulWidget {
  const AdminProductDetailPage({super.key});

  @override
  State<AdminProductDetailPage> createState() =>
      _AdminProductDetailPageState();
}

class _AdminProductDetailPageState
    extends State<AdminProductDetailPage> {
  final service = ProductService();

  late Map product;
  int selectedIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    product =
        ModalRoute.of(context)!.settings.arguments as Map;
  }

  Future<void> deleteProduct() async {
    await service.deleteProduct(product['id']);
    Navigator.pop(context);
  }

  Future<void> deleteVariant(String id) async {
    await service.deleteVariant(id);

    setState(() {
      product['product_variants']
          .removeWhere((v) => v['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variants = product['product_variants'] ?? [];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: Text(product['name']),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteProduct,
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/admin-add-variant',
            arguments: product,
          );
        },
        child: const Icon(Icons.add),
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

            /// 🔥 PRODUCT HEADER
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      product['image'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product['description'] ?? '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// 🔥 TITLE
            const Text(
              "Select Subscription Tier",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            /// 🔥 VARIANT CARD (ADMIN MODE)
...variants.map((v) {
  return GestureDetector(
    onTap: () {
      /// 🔥 EDIT VARIANT
      Navigator.pushNamed(
        context,
        '/admin-add-variant',
        arguments: {
          ...product,
          "variant": v,
        },
      );
    },

    onLongPress: () async {
      /// 🔥 DELETE CONFIRM
      final confirm = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete Variant"),
          content: const Text("Yakin mau hapus variant ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await deleteVariant(v['id']);
      }
    },

    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  const Color(0xFF1B1B2F),
                  const Color(0xFF1F1F3A),
                ]
              : [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface,
                ],
        ),

        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.08),
        ),
      ),

      child: Row(
        children: [

          /// 🔥 ICON
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            child: const Icon(Icons.workspace_premium),
          ),

          const SizedBox(width: 12),

          /// 🔥 TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v['type'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${v['duration_days']} hari",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 PRICE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rp ${v['price']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              /// 🔥 HINT ACTION
              Text(
                "Tap to edit",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}).toList(),

            const SizedBox(height: 20),

            /// 🔥 INFO BOX (MATCH UI)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
              child: const Text(
                "All subscriptions are verified for stability.\n24/7 support available.",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}