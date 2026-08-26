/// ============================================
/// MODELO DE LOG DE ACESSO
/// ============================================
/// Registra todas as ações dos usuários no sistema
/// ============================================

class AccessLogModel {
  final String id;
  final String userId;
  final String? moduleId;
  final String action;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  AccessLogModel({
    required this.id,
    required this.userId,
    this.moduleId,
    required this.action,
    this.details,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  factory AccessLogModel.fromJson(Map<String, dynamic> json) {
    return AccessLogModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      moduleId: json['module_id']?.toString(),
      action: json['action']?.toString() ?? '',
      details: json['details'] as Map<String, dynamic>?,
      ipAddress: json['ip_address']?.toString(),
      userAgent: json['user_agent']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'module_id': moduleId,
      'action': action,
      'details': details,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Tipos de ação para logs
class LogAction {
  static const String login = 'LOGIN';
  static const String logout = 'LOGOUT';
  static const String create = 'CREATE';
  static const String read = 'READ';
  static const String update = 'UPDATE';
  static const String delete = 'DELETE';
  static const String export = 'EXPORT';
  static const String access = 'ACCESS';
  static const String permissionChange = 'PERMISSION_CHANGE';
  static const String userCreate = 'USER_CREATE';
  static const String userUpdate = 'USER_UPDATE';
  static const String userDeactivate = 'USER_DEACTIVATE';
  static const String userActivate = 'USER_ACTIVATE';
}
