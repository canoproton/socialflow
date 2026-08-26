import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../../middleware/security_middleware.dart';
import '../../services/security/rate_limit_service.dart';
import '../../services/security/encryption_service.dart';
import '../../services/usuarios/audit_service.dart';

class SecureAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // ← Usando construtores simples
  final SecurityMiddleware _security = SecurityMiddleware();
  final RateLimitService _rateLimit = RateLimitService();
  final EncryptionService _encryption = EncryptionService();
  final AuditService _audit = AuditService();

  static final SecureAuthService _instance = SecureAuthService._internal();
  factory SecureAuthService() => _instance;
  SecureAuthService._internal();

  Future<UserModel> secureLogin({
    required String email,
    required String password,
    String? ipAddress,
    String? userAgent,
  }) async {
    final safeEmail = _security.sanitizeInput(email);
    if (!_security.isInputSafe(safeEmail)) {
      await _audit.logAction(
        action: 'LOGIN_FAILED',
        details: {'email': email, 'reason': 'INPUT_INVALID'},
        ipAddress: ipAddress,
        userAgent: userAgent,
      );
      throw Exception('Email contém caracteres inválidos');
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(safeEmail)) {
      throw Exception('Formato de email inválido');
    }
    final safePassword = _security.sanitizeInput(password);
    if (!_security.isStrongPassword(safePassword)) {
      throw Exception('Senha deve ter pelo menos 8 caracteres, com maiúscula, minúscula, número e caractere especial');
    }
    final identifier = ipAddress ?? safeEmail;
    if (!_rateLimit.canAttemptLogin(identifier)) {
      await _audit.logAction(
        action: 'LOGIN_BLOCKED',
        details: {'email': safeEmail, 'reason': 'RATE_LIMIT'},
        ipAddress: ipAddress,
        userAgent: userAgent,
      );
      throw Exception('Muitas tentativas falhas. Tente novamente em 15 minutos.');
    }
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: safeEmail,
        password: safePassword,
      );
      if (response.user == null) {
        throw Exception('Usuário não encontrado');
      }
      _rateLimit.registerLoginAttempt(identifier, true);
      final profile = await _getProfile(response.user!.id);
      await _audit.logAction(
        moduleId: null,
        action: 'LOGIN',
        details: {
          'email': safeEmail,
          'user_id': response.user!.id,
        },
        ipAddress: ipAddress,
        userAgent: userAgent,
      );
      await _updateLastLogin(response.user!.id);
      return UserModel.fromMap({
        ...response.user!.toJson(),
        ...profile,
      });
    } catch (e) {
      _rateLimit.registerLoginAttempt(identifier, false);
      await _audit.logAction(
        action: 'LOGIN_FAILED',
        details: {'email': safeEmail, 'error': e.toString()},
        ipAddress: ipAddress,
        userAgent: userAgent,
      );
      final blockedResult = _rateLimit.registerLoginAttempt(identifier, false);
      if (blockedResult['blocked'] == true) {
        throw Exception('Muitas tentativas falhas. Tente novamente em 15 minutos.');
      }
      throw Exception('Email ou senha incorretos');
    }
  }

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response as Map<String, dynamic>? ?? {};
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return {};
    }
  }

  Future<void> _updateLastLogin(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'last_login': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      print('Erro ao atualizar last_login: $e');
    }
  }

  Future<void> secureLogout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  String getCurrentEmail() {
    return _supabase.auth.currentUser?.email ?? '';
  }

  String getCurrentName() {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'Usuário';
    final name = user.userMetadata?['name'] ?? 
                 user.userMetadata?['full_name'] ?? 
                 user.email?.split('@').first ?? 
                 'Usuário';
    return name.toString();
  }
}
