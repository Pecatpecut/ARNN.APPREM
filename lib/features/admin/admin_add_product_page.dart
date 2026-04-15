import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

class AdminAddProductPage extends StatefulWidget {
  const AdminAddProductPage({super.key});

  @override
  State<AdminAddProductPage> createState() =>
      _AdminAddProductPageState();
}

class _AdminAddProductPageState
    extends State<AdminAddProductPage> {

  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();

  String selectedCategory = "Streaming";
  

  XFile? pickedFile;
  Uint8List? imageBytes;

  final categories = [
    "Streaming",
    "Music",
    "Study",
    "Editing",
  ];

  /// 🔥 PICK IMAGE
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

  /// 🔥 UPLOAD IMAGE
  Future<String?> uploadImage() async {
    if (pickedFile == null) return null;

    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final bytes = await pickedFile!.readAsBytes();

    await supabase.storage
        .from('product-images')
        .uploadBinary(fileName, bytes);

    return supabase.storage
        .from('product-images')
        .getPublicUrl(fileName);
  }

  /// 🔥 SAVE PRODUCT + VARIANT
  Future<void> saveProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data")),
      );
      return;
    }

    try {
      final imageUrl = await uploadImage();

      /// 🔥 INSERT PRODUCT
      final product = await supabase.from('products').insert({
        "name": nameController.text,
        "description": descController.text,
        "image": imageUrl,
        "category": selectedCategory,
        "is_active": true,
      }).select().single();

      /// 🔥 INSERT VARIANT
      await supabase.from('product_variants').insert({
        "product_id": product['id'],
        "type": "Default",
        "price": int.parse(priceController.text),
        "duration_days": int.parse(durationController.text),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil ditambahkan")),
      );

      Navigator.pop(context);

    } catch (e) {
      print("ERROR ADD PRODUCT: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan produk")),
      );
    }
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    backgroundColor: theme.colorScheme.surface,

    appBar: AppBar(
      title: const Text("Add Product"),
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

          /// 🔥 IMAGE UPLOAD (UPGRADE)
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(imageBytes!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload,
                            size: 40,
                            color: theme.colorScheme.primary),
                        const SizedBox(height: 10),
                        const Text("Upload Product Image"),
                        const SizedBox(height: 5),
                        Text(
                          "SVG, PNG, JPG (max. 400x400px)",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 25),

          /// 🔥 FORM CARD
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

                /// PRODUCT NAME
                _label("PRODUCT NAME"),
                _input(nameController, "e.g., Netflix Premium"),

                const SizedBox(height: 15),

                /// CATEGORY
              /// CATEGORY
              _label("CATEGORY"),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  /// 🔥 FIX DEPRECATED
                  initialValue: selectedCategory,

                  dropdownColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,

                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),

                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),

                  items: categories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(
                        c,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },

                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),

                const SizedBox(height: 15),

                /// PRICE + DURATION
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("PRICE"),
                          _input(priceController, "0.00", isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("DURATION"),
                          _input(durationController, "30", isNumber: true),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// DESCRIPTION
                _label("DESCRIPTION"),
                _input(descController,
                    "Describe the features and terms of the subscription...",
                    maxLines: 4),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// 🔥 BUTTON (UPGRADE)
          GestureDetector(
            onTap: saveProduct,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  "Save Product",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );
}

  /// 🔥 INPUT
  Widget _input(TextEditingController controller, String hint,
      {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}