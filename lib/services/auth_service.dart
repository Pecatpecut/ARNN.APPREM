import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    await supabase.from('users').insert({
      'id': response.user!.id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'customer',
    });
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final authRes = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final data = await supabase
        .from('users')
        .select('role')
        .eq('id', authRes.user!.id)
        .single();

    return data['role']; 
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}