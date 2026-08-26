import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user == null) {
        throw Exception('Usuário não encontrado');
      }

      return UserModel.fromMap({
        ...response.user!.toJson(),
      });
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  String getUserName() {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'Usuário';
    final name = user.userMetadata?['name'] ?? 
                 user.email?.split('@').first ?? 
                 'Usuário';
    return name.toString();
  }

  String getUserEmail() {
    final user = _supabase.auth.currentUser;
    return user?.email ?? '';
  }
}
