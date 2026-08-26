import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/usuarios/access_log_model.dart';
import '../../middleware/security_middleware.dart';
import '../../services/security/secure_auth_service.dart';

class AuditService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SecureAuthService _auth = SecureAuthService();
  
  // ← Usando construtor simples
  final SecurityMiddleware _security = SecurityMiddleware();

  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  Future<void> logAction({
    String? moduleId,
    required String action,
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
  }) async {
    final user = _auth.getCurrentUser();
    if (user == null) return;
    try {
      final safeDetails = details?.map((key, value) {
        if (value is String) {
          return MapEntry(key, _security.sanitizeInput(value));
        }
        return MapEntry(key, value);
      });
      final log = AccessLogModel(
        id: '',
        userId: user.id,
        moduleId: moduleId,
        action: action,
        details: safeDetails,
        ipAddress: ipAddress != null ? _security.sanitizeInput(ipAddress) : null,
        userAgent: userAgent != null ? _security.sanitizeInput(userAgent) : null,
        createdAt: DateTime.now(),
      );
      await _supabase
          .from('access_logs')
          .insert(log.toJson());
    } catch (e) {
      print('Erro ao registrar log: $e');
    }
  }

  Future<void> logLogin({
    String? ipAddress,
    String? userAgent,
  }) async {
    await logAction(
      action: 'LOGIN',
      details: {'type': 'login'},
      ipAddress: ipAddress,
      userAgent: userAgent,
    );
  }

  Future<void> logLogout() async {
    await logAction(
      action: 'LOGOUT',
      details: {'type': 'logout'},
    );
  }

  Future<List<AccessLogModel>> getUserLogs(String userId, {int limit = 100}) async {
    try {
      final response = await _supabase
          .from('access_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List)
          .map((item) => AccessLogModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erro ao buscar logs: $e');
      return [];
    }
  }

  Future<List<AccessLogModel>> getLogsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 100,
  }) async {
    try {
      final response = await _supabase
          .from('access_logs')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List)
          .map((item) => AccessLogModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erro ao buscar logs: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getLogStats(DateTime period) async {
    try {
      final startDate = period;
      final endDate = DateTime.now();
      final response = await _supabase
          .from('access_logs')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
      final logs = response as List;
      final total = logs.length;
      final actions = logs
          .map((item) => item['action'].toString())
          .toList();
      final actionCounts = <String, int>{};
      for (var action in actions) {
        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
      }
      return {
        'total': total,
        'by_action': actionCounts,
        'period': {
          'start': startDate,
          'end': endDate,
        },
      };
    } catch (e) {
      print('Erro ao obter estatísticas: $e');
      return {};
    }
  }
}
