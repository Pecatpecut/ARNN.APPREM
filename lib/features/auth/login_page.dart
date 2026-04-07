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

  final _authService = AuthService();

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final role = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Redirect sesuai role
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0D18),
              Color(0xFF1A1A2E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: ListView(
              children: [

                const SizedBox(height: 40),

                /// 🔥 LOGO + BRAND
                Column(
                  children: [

                    /// 🔥 LOGO
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Image.asset(
                        'assets/images/profile.png',
                        height: 70,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "iniarnn.apprem",
                      style: TextStyle(
                        color: Color(0xFFACA3FF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "˗ˏˋ apps premium by arnn 🐰 ࿐ྂ",
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// 🔥 TITLE
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔥 CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radius),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [

                      _input("Email", controller: _emailController),
                      const SizedBox(height: 16),
                      _input("Password", controller: _passwordController, isPassword: true),

                      const SizedBox(height: 20),

                      _isLoading
                          ? const CircularProgressIndicator()
                      : _button(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 REGISTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Color(0xFFACA3FF)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _button() {
    return GestureDetector(
      onTap: _login,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFACA3FF),
              Color(0xFF6F5FEA),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6F5FEA).withOpacity(0.6),
              blurRadius: 20,
            )
          ],
        ),
        child: const Center(
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}