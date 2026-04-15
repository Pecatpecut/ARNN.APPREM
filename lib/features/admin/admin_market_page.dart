import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../core/constants.dart';

class AdminMarketPage extends StatefulWidget {
  const AdminMarketPage({super.key});

  @override
  State<AdminMarketPage> createState() => _AdminMarketPageState();
}

class _AdminMarketPageState extends State<AdminMarketPage> {
  final productService = ProductService();

  List products = [];
  bool isLoading = true;

  String selectedCategory = "All";
  String searchQuery = "";

  final categories = ["All", "Streaming", "Music", "Study", "Editing"];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final data = await productService.getProducts();

    setState(() {
      products = data;
      isLoading = false;
    });
  }

  List get filteredProducts {
    return products.where((p) {
      final matchCategory = selectedCategory == "All" ||
          p['category'] == selectedCategory;

      final matchSearch = (p['name'] ?? "")
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin-add-product');
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

        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppConstants.padding),
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
                            Text(
                              "Arini Store",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const CircleAvatar(child: Icon(Icons.person)),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// 🔥 SEARCH
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surface.withValues(alpha: 0.6),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Search product...",
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔥 FILTER
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((c) {
                          final isActive = selectedCategory == c;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = c;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface.withValues(alpha: 0.6),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// 🔥 LIST PRODUCT
                    ...filteredProducts.map((p) => _card(p)).toList(),
                  ],
                ),
        ),
      ),
    );
  }

  /// 🔥 PRODUCT CARD (PREMIUM STYLE)
  Widget _card(Map p) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/admin-product-detail',
          arguments: p,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
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
        child: Row(
          children: [

            /// 🔥 IMAGE
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.black,
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                p['image'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image, color: Colors.white),
              ),
            ),

            const SizedBox(width: 15),

            /// 🔥 TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['name'] ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p['description'] ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}