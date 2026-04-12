import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../core/theme_provider.dart';

class AdminSettingPage extends StatefulWidget {
  const AdminSettingPage({super.key});

  @override
  State<AdminSettingPage> createState() => _AdminSettingPageState();
}

class _AdminSettingPageState extends State<AdminSettingPage> {
  final supabase = Supabase.instance.client;

  String name = "Admin";
  String email = "admin@email.com";
  bool isLoading = true;

  bool maintenanceMode = false;
  bool allowRegister = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      final data = await supabase
          .from('users')
          .select('name, email')
          .eq('id', user.id)
          .single();

      setState(() {
        name = data['name'] ?? "Admin";
        email = data['email'] ?? "-";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
        ),

        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.padding),
            children: [

              /// 🔥 HEADER
              Text(
                "Admin Settings",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 PROFILE CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: theme.brightness == Brightness.dark
                        ? [
                            const Color(0xFF1B1B2F),
                            const Color(0xFF1F1F3A),
                          ]
                        : [
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            theme.colorScheme.surface,
                          ],
                  ),
                ),
                child: Column(
                  children: [

                    CircleAvatar(
                      radius: 45,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "A",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.teal.withValues(alpha: 0.2),
                      ),
                      child: const Text(
                        "ADMIN VERIFIED",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 STORE CONFIG
              _sectionTitle("Store Configuration"),

              _toggleTile(
                "Maintenance Mode",
                "Tutup akses user",
                maintenanceMode,
                (val) => setState(() => maintenanceMode = val),
              ),

              _toggleTile(
                "Allow Registration",
                "User bisa daftar",
                allowRegister,
                (val) => setState(() => allowRegister = val),
              ),

              _toggleTile(
                "Dark Mode",
                "Ganti tema",
                themeProvider.isDarkMode,
                (val) => themeProvider.toggleTheme(),
              ),

              const SizedBox(height: 20),

              /// 🔥 SYSTEM
              _sectionTitle("System"),

              _menu(Icons.password, "Change Password"),
              _menu(Icons.security, "Security Settings"),

              const SizedBox(height: 20),

              /// 🔥 DANGER ZONE
              _sectionTitle("Danger Zone", color: Colors.red),

              _dangerButton("Clear Cache"),
              _dangerButton("Reset System"),

              const SizedBox(height: 30),

              /// 🔥 LOGOUT
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  await supabase.auth.signOut();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 SECTION TITLE
  Widget _sectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// 🔥 TOGGLE TILE
  Widget _toggleTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6))),
              ]),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  /// 🔥 MENU TILE
  Widget _menu(IconData icon, String title) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  /// 🔥 DANGER BUTTON
  Widget _dangerButton(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withValues(alpha: 0.2),
        ),
        onPressed: () {},
        child: Text(title),
      ),
    );
  }
}