  import 'package:flutter/material.dart';
  import '../../core/constants.dart';
  import 'package:provider/provider.dart';
  import '../../core/theme_provider.dart';
  import '../../services/auth_service.dart';

  class RegisterPage extends StatefulWidget {
    const RegisterPage({super.key});

    @override
    State<RegisterPage> createState() => _RegisterPageState();
  }

  class _RegisterPageState extends State<RegisterPage> {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _isLoading = false;
    bool _isPasswordVisible = false;
    bool _isValidEmail(String email) {
  return email.contains("@");
}

bool _isValidPhone(String phone) {
  return phone.startsWith("08") && phone.length >= 10;
}

    final _authService = AuthService();

          Future<void> _register() async {

            /// 🔥 VALIDASI
                if (_nameController.text.trim().isEmpty ||
                    _emailController.text.trim().isEmpty ||
                    _phoneController.text.trim().isEmpty ||
                    _passwordController.text.trim().isEmpty) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua field wajib diisi")),
                  );
                  return;
                }

                /// 🔥 VALIDASI EMAIL
                if (!_isValidEmail(_emailController.text.trim())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email harus mengandung @")),
                  );
                  return;
                }

                /// 🔥 VALIDASI WA
                if (!_isValidPhone(_phoneController.text.trim())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nomor WA tidak valid")),
                  );
                  return;
                }

            setState(() => _isLoading = true);

            try {
              await _authService.register(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
                password: _passwordController.text.trim(),
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Akun berhasil dibuat!')),
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );

            } catch (e) {

              print("REGISTER ERROR: $e"); // 🔥 LIHAT DI CONSOLE

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),

    );
            } finally {
              setState(() => _isLoading = false);
            }
          }
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Scaffold(
    body: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0D0D18),
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                ]
              : [
                  Colors.white,
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),

      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// 🔥 NAVBAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.blur_on, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "INIARNN.APPREM",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () {
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).toggleTheme();
                      },
                    )
                  ],
                ),

                const SizedBox(height: 30),

                /// 🔥 LOGO
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    'assets/images/profile.png',
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 25),

                /// 🔥 CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Colors.white.withValues(alpha: 0.05),
                              Colors.white.withValues(alpha: 0.02),
                            ]
                          : [
                              Colors.white,
                              Colors.grey.shade100,
                            ],
                    ),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _label("FULL NAME"),
                      _input("Your name", controller: _nameController),

                      const SizedBox(height: 15),

                      _label("EMAIL ADDRESS"),
                      _input("your@email.com", controller: _emailController),

                      const SizedBox(height: 15),

                      _label("WHATSAPP"),
                      _input("08xxxxxxxx", controller: _phoneController),

                      const SizedBox(height: 15),

                      _label("PASSWORD"),
                      _input(
                        "••••••••",
                        controller: _passwordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 25),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _button(),

                      const SizedBox(height: 15),

                      /// 🔥 LOGIN LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/login'),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}



    Widget _input(
    String hint, {
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          borderSide: BorderSide.none,
        ),

        /// 🔥 EYE ICON
        suffixIcon: isPassword
            ? GestureDetector(
                onTapDown: (_) {
                  setState(() => _isPasswordVisible = true);
                },
                onTapUp: (_) {
                  setState(() => _isPasswordVisible = false);
                },
                onTapCancel: () {
                  setState(() => _isPasswordVisible = false);
                },
                child: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: theme.colorScheme.onSurface,
                ),
              )
            : null,
      ),
    );
  }

  Widget _label(String text) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: theme.colorScheme.primary.withValues(alpha: 0.8),
      ),
    ),
  );
}

    Widget _button() {
      final theme = Theme.of(context);
      return GestureDetector(
        onTap: _register,
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radius),
            gradient: LinearGradient(
              colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6F5FEA).withOpacity(0.6),
                blurRadius: 20,
              )
            ],
          ),
          child: Center(
            child: Text(
              "Register",
              style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }