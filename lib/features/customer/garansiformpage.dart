import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../services/claims_service.dart';

class GaransiFormPage extends StatefulWidget {
  const GaransiFormPage({super.key});

  @override
  State<GaransiFormPage> createState() => _GaransiFormPageState();
}

class _GaransiFormPageState extends State<GaransiFormPage> {
  final supabase = Supabase.instance.client;
  final service = ClaimsService();

  final descriptionController = TextEditingController();

  String selectedReason = "Cannot login";
  XFile? pickedFile;
  Uint8List? imageBytes;

  final reasons = [
    "Cannot login",
    "Account expired early",
    "Wrong account",
    "Other problem",
  ];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
    final bytes = await picked.readAsBytes();
    setState(() {
      pickedFile = picked; // ← tambah ini
      imageBytes = bytes;
    });
  }
  }

  @override
  Widget build(BuildContext context) {
    final order =
        ModalRoute.of(context)?.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(title: const Text("Ajukan Garansi")),

      body: ListView(
        padding: const EdgeInsets.all(AppConstants.padding),
        children: [

          Text("Product: ${order['product_name']}"),
          Text("Variant: ${order['variant_type']}"),

          const SizedBox(height: 20),

          ...reasons.map((r) => RadioListTile(
                value: r,
                groupValue: selectedReason,
                onChanged: (v) =>
                    setState(() => selectedReason = v!),
                title: Text(r),
              )),

          TextField(
            controller: descriptionController,
            decoration:
                const InputDecoration(hintText: "Deskripsi..."),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 100,
              decoration: BoxDecoration(border: Border.all()),
              child: imageBytes != null
                  ? Image.memory(imageBytes!)
                  : const Center(child: Text("Upload")),
            ),
          ),

          const SizedBox(height: 20),

          PrimaryButton(
            text: "Submit",
            onTap: () async {
              final user = supabase.auth.currentUser;
              if (user == null) return;

              final ctx = context;

              try {
                String? imageUrl;
                if (imageBytes != null && pickedFile != null) {
                  final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  
                  await supabase.storage
                      .from('claim-proofs')
                      .uploadBinary(fileName, imageBytes!);

                  imageUrl = supabase.storage
                      .from('claim-proofs')
                      .getPublicUrl(fileName);
                }

              await service.createClaim(
                orderId: order['id'],
                userId: user.id,
                description:
                    "$selectedReason - ${descriptionController.text}",
                imageUrl: imageUrl,    
              );

              if (!mounted) return;
              Navigator.pop(ctx);

            } catch (e) {
              print("ERROR: $e");
              if (!mounted) return;
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text("Gagal submit: $e")),
              );
            }
            }
          )
        ],
      )
    );
  }
}