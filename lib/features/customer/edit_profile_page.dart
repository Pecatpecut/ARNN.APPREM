import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../widgets/shared/spacing.dart';
import '../../widgets/buttons/primary_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('users')
        .select('name, email, phone')
        .eq('id', user.id)
        .single();

    setState(() {
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
      isLoading = false;
    });
  }

  Future<void> saveChanges() async {
    setState(() => isSaving = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Update tabel users
      await supabase.from('users').update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
      }).eq('id', user.id);

      if (passwordController.text.isNotEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(password: passwordController.text.trim()),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diupdate!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/profile.png'),
                      ),
                    ),

                    Space.h20,

                    _input("Name", controller: nameController),
                    Space.h10,

                    _input("Email", controller: emailController),
                    Space.h10,

                    _input("Phone Number", controller: phoneController),
                    Space.h10,

                    _input("New Password (optional)", controller: passwordController, isPassword: true),

                    Space.h30,

                    isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            text: "Save Changes",
                            onTap: saveChanges,
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _input(String hint,
      {required TextEditingController controller,
      bool isPassword = false,
      bool enabled = true}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}