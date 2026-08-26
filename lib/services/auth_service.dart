import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Serviço de Autenticação do SocialFlow
class AuthService {
  // Instância do Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Obtém o usuário atual logado
  User? get currentUser => _supabase.auth.currentUser;

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Obtém a sessão atual
  Session? get currentSession => _supabase.auth.currentSession;

  /// Realiza o login do usuário
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

      final userData = await _getUserProfile(response.user!.id);

      return UserModel.fromMap({
        ...response.user!.toJson(),
        ...userData,
      });
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Busca dados adicionais do perfil do usuário
  Future<Map<String, dynamic>> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return response;  // ← CORRIGIDO
      }
    } catch (e) {
      debugPrint('Perfil não encontrado para usuário: $userId');
    }
    return {};
  }

  /// Realiza o logout do usuário
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  /// Verifica se o email é válido
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Verifica se a senha é válida
  bool isValidPassword(String password) {
    return password.trim().length >= 6;
  }

  /// Obtém o nome do usuário logado
  String getUserName() {
    final user = currentUser;
    if (user == null) return 'Usuário';
    
    final name = user.userMetadata?['name'] ?? 
                 user.userMetadata?['full_name'] ?? 
                 user.email?.split('@').first ?? 
                 'Usuário';
    return name.toString();
  }

  /// Obtém o email do usuário logado
  String getUserEmail() {
    final user = currentUser;
    return user?.email ?? '';
  }

  /// Verifica se o usuário está ativo
  bool isUserActive() {
    final user = currentUser;
    return user != null && user.emailConfirmedAt != null;
  }
}
