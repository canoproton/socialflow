import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/usuarios/permission_model.dart';
import '../../models/usuarios/module_model.dart';
import '../../services/security/secure_auth_service.dart';

class PermissionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SecureAuthService _auth = SecureAuthService();
  final Map<String, List<PermissionModel>> _permissionsCache = {};

  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  Future<bool> hasPermission({
    required String moduleCode,
    required PermissionAction action,
  }) async {
    final user = _auth.getCurrentUser();
    if (user == null) return false;
    if (await _isAdmin(user.id)) return true;

    final permissions = await _getUserPermissions(user.id);
    final permission = permissions.firstWhere(
      (p) => p.moduleId == moduleCode,
      orElse: () => PermissionModel(
        id: '',
        userId: user.id,
        moduleId: moduleCode,
      ),
    );
    if (!permission.isActive) return false;
    return permission.hasPermission(action);
  }

  Future<bool> _isAdmin(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('cargo')
          .eq('user_id', userId)
          .maybeSingle();
      if (response == null) return false;
      final cargo = response['cargo']?.toString().toLowerCase() ?? '';
      return cargo == 'admin' || cargo == 'administrador';
    } catch (e) {
      return false;
    }
  }

  Future<List<PermissionModel>> _getUserPermissions(String userId) async {
    if (_permissionsCache.containsKey(userId)) {
      return _permissionsCache[userId]!;
    }
    try {
      final response = await _supabase
          .from('permissions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);
      final permissions = (response as List)
          .map((item) => PermissionModel.fromJson(item))
          .toList();
      _permissionsCache[userId] = permissions;
      return permissions;
    } catch (e) {
      print('Erro ao buscar permissões: $e');
      return [];
    }
  }

  Future<void> updatePermissions({
    required String userId,
    required List<PermissionModel> permissions,
    String? requestUserId,
  }) async {
    if (requestUserId != null) {
      final isAdmin = await _isAdmin(requestUserId);
      if (!isAdmin) {
        throw Exception('Apenas administradores podem atualizar permissões');
      }
    }
    try {
      await _supabase
          .from('permissions')
          .delete()
          .eq('user_id', userId);
      for (var permission in permissions) {
        await _supabase
            .from('permissions')
            .insert(permission.toJson());
      }
      _permissionsCache.remove(userId);
    } catch (e) {
      throw Exception('Erro ao atualizar permissões: $e');
    }
  }

  Future<List<ModuleModel>> getAccessibleModules() async {
    final user = _auth.getCurrentUser();
    if (user == null) return [];
    if (await _isAdmin(user.id)) {
      return ModuleModel.defaultModules;
    }
    final permissions = await _getUserPermissions(user.id);
    final moduleIds = permissions
        .where((p) => p.canRead && p.isActive)
        .map((p) => p.moduleId)
        .toList();
    if (moduleIds.isEmpty) return [];
    final response = await _supabase
        .from('modules')
        .select()
        .inFilter('id', moduleIds)
        .eq('is_active', true)
        .order('ordem', ascending: true);
    return (response as List)
        .map((item) => ModuleModel.fromJson(item))
        .toList();
  }

  void clearCache() {
    _permissionsCache.clear();
  }
}
