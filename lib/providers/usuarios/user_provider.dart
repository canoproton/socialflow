import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/usuarios/profile_model.dart';
import '../../models/usuarios/permission_model.dart';
import '../../models/usuarios/module_model.dart';
import '../../services/usuarios/permission_service.dart';
import '../../services/usuarios/audit_service.dart';
import '../../services/security/secure_auth_service.dart';
import '../../services/security/rate_limit_service.dart';
import '../../middleware/security_middleware.dart';

class UserProvider extends ChangeNotifier {
  // Instâncias simples, sem singleton
  final _auth = SecureAuthService();
  final _permission = PermissionService();
  final _audit = AuditService();
  final _rateLimit = RateLimitService();  // ← SIMPLES
  final _security = SecurityMiddleware(); // ← SIMPLES

  ProfileModel? _currentProfile;
  List<ProfileModel> _users = [];
  List<PermissionModel> _permissions = [];
  List<ModuleModel> _modules = [];
  bool _isLoading = false;
  String? _error;

  ProfileModel? get currentProfile => _currentProfile;
  List<ProfileModel> get users => _users;
  List<PermissionModel> get permissions => _permissions;
  List<ModuleModel> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentEmail => _currentProfile?.email ?? _auth.getCurrentEmail();
  String get currentName => _currentProfile?.nome ?? _auth.getCurrentName();

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.getCurrentUser();
      if (user != null) {
        await _loadUserProfile(user.id);
        await _loadUserPermissions(user.id);
        await _loadModules();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final user = _auth.getCurrentUser();
        final email = user?.email ?? '';
        
        _currentProfile = ProfileModel.fromJson({
          ...response,
          'email': email,
        });
      }
    } catch (e) {
      print('Erro ao carregar perfil: $e');
    }
  }

  Future<void> _loadUserPermissions(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('permissions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);

      _permissions = (response as List)
          .map((item) => PermissionModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erro ao carregar permissões: $e');
    }
  }

  Future<void> _loadModules() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('modules')
          .select()
          .eq('is_active', true)
          .order('ordem', ascending: true);

      if (response != null && (response as List).isNotEmpty) {
        _modules = (response as List)
            .map((item) => ModuleModel.fromJson(item))
            .toList();
      } else {
        _modules = ModuleModel.defaultModules;
      }
    } catch (e) {
      _modules = ModuleModel.defaultModules;
    }
  }

  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('profiles')
          .select()
          .order('nome', ascending: true);

      _users = (response as List)
          .map((item) {
            final email = item['email']?.toString() ?? '';
            return ProfileModel.fromJson({
              ...item,
              'email': email,
            });
          })
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> hasPermission({
    required String moduleCode,
    required PermissionAction action,
  }) async {
    return _permission.hasPermission(
      moduleCode: moduleCode,
      action: action,
    );
  }

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('user_id', profile.userId);
      
      if (profile.userId == _currentProfile?.userId) {
        _currentProfile = profile;
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  Future<void> updateUserPermissions({
    required String userId,
    required List<PermissionModel> permissions,
  }) async {
    final currentUser = _auth.getCurrentUser();
    if (currentUser == null) throw Exception('Usuário não autenticado');

    await _permission.updatePermissions(
      userId: userId,
      permissions: permissions,
      requestUserId: currentUser.id,
    );
    
    await _loadUserPermissions(userId);
    notifyListeners();
  }

  Future<void> deactivateUser(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('profiles')
          .update({'is_active': false})
          .eq('user_id', userId);
      
      await loadAllUsers();
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao desativar usuário: $e');
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('profiles')
          .update({'is_active': true})
          .eq('user_id', userId);
      
      await loadAllUsers();
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao ativar usuário: $e');
    }
  }

  Future<void> logout() async {
    await _audit.logLogout();
    await _auth.secureLogout();
    _currentProfile = null;
    _permissions = [];
    _users = [];
    _rateLimit.resetCounters(_auth.getCurrentEmail());
    notifyListeners();
  }

  Map<String, dynamic> getSecurityStats() {
    return _rateLimit.getStats();
  }
}
