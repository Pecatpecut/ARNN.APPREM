import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final _authService = AuthService();

    Future<void> _login() async {
      /// 🔥 VALIDASI DULU (WAJIB)
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email & password wajib diisi")),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final role = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }

      } catch (e) {
        /// 🔥 ERROR HANDLE YANG LEBIH RAPI
        String message = "Terjadi kesalahan";

        if (e.toString().contains("Invalid login credentials")) {
          message = "Email atau password salah";
        } else if (e.toString().contains("missing email")) {
          message = "Email wajib diisi";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
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
                            const Color(0xFF0D0D18), // dark background
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                          ]
                        : [
                            Colors.white, // 🔥 light mode fix
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),

            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    child: Column(
                      children: [

                        /// 🔥 NAVBAR (TAMBAHKAN DI SINI)
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
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.more_vert),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// 🔥 LOGO FULL BULAT
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              width: 2,
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
                          "iniarnn.apprem",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ) ,

                        const SizedBox(height: 5),

                        Text(
                          "˗ˏˋ apps premium by arnn 🐰 ࿐ྂ",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        /// 🔥 CARD LOGIN (UPGRADED)

Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(28),

    /// 🔥 GRADIENT FIX
    gradient: LinearGradient(
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.02),
            ]
          : [
              Colors.white,
              Colors.grey.shade50,
            ],
    ),

    /// 🔥 BORDER FIX
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.05),
    ),

    /// 🔥 SHADOW (BIAR NGANGKAT DI LIGHT MODE)
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

      /// 🔥 TITLE
      const Text(
        "WELCOME BACK",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),

      const SizedBox(height: 8),

      Text(
        "Enter your credentials to access your dashboard.",
        style: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.6),
        ),
      ),

      const SizedBox(height: 25),

      /// 🔥 EMAIL LABEL
      _label("EMAIL ADDRESS"),
      _input("your@email.com", controller: _emailController),

      const SizedBox(height: 20),

      /// 🔥 PASSWORD LABEL (NO FORGOT)
      _label("SECURITY KEY"),
      _input(
        "••••••••",
        controller: _passwordController,
        isPassword: true,
      ),

      const SizedBox(height: 20),

      /// 🔥 CHECKBOX
      Row(
        children: [
          Checkbox(
  value: true,
  onChanged: (_) {},
  activeColor: theme.colorScheme.primary,
  checkColor: Colors.white,
),
          Text(
            "Keep session active",
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          )
        ],
      ),

      const SizedBox(height: 20),

      /// 🔥 BUTTON
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _button(),

      const SizedBox(height: 15),

      /// 🔥 REGISTER (PINDAH KE DALAM CARD)
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(color: Color(0xFFACA3FF)),
            ),
          )
        ],
      ),
    ],
  ),
),

                        const SizedBox(height: 20),
                      ],
                    ),
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
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.8),
      ),
    ),
  );
}
    Widget _button() {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _login,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              blurRadius: 25,
            )
          ],
        ),
                child: Center(
          child: Text(
            "SIGN IN",
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white, // 🔥 FIX LIGHT MODE
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}