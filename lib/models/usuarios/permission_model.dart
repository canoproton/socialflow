/// ============================================
/// MODELO DE PERMISSÃO
/// ============================================
/// Define o nível de acesso para cada módulo
/// ============================================

enum PermissionAction {
  read,
  insert,
  edit,
  delete,
  export,
}

class PermissionModel {
  final String id;
  final String userId;
  final String moduleId;
  final bool canRead;
  final bool canInsert;
  final bool canEdit;
  final bool canDelete;
  final bool canExport;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PermissionModel({
    required this.id,
    required this.userId,
    required this.moduleId,
    this.canRead = false,
    this.canInsert = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canExport = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Combinações comuns de permissões
  static PermissionModel readonly({
    required String userId,
    required String moduleId,
  }) {
    return PermissionModel(
      id: '',
      userId: userId,
      moduleId: moduleId,
      canRead: true,
      canInsert: false,
      canEdit: false,
      canDelete: false,
      canExport: true,
    );
  }

  static PermissionModel fullAccess({
    required String userId,
    required String moduleId,
  }) {
    return PermissionModel(
      id: '',
      userId: userId,
      moduleId: moduleId,
      canRead: true,
      canInsert: true,
      canEdit: true,
      canDelete: true,
      canExport: true,
    );
  }

  static PermissionModel editor({
    required String userId,
    required String moduleId,
  }) {
    return PermissionModel(
      id: '',
      userId: userId,
      moduleId: moduleId,
      canRead: true,
      canInsert: true,
      canEdit: true,
      canDelete: false,
      canExport: true,
    );
  }

  bool hasPermission(PermissionAction action) {
    switch (action) {
      case PermissionAction.read:
        return canRead;
      case PermissionAction.insert:
        return canInsert;
      case PermissionAction.edit:
        return canEdit;
      case PermissionAction.delete:
        return canDelete;
      case PermissionAction.export:
        return canExport;
    }
  }

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      moduleId: json['module_id']?.toString() ?? '',
      canRead: json['can_read'] ?? false,
      canInsert: json['can_insert'] ?? false,
      canEdit: json['can_edit'] ?? false,
      canDelete: json['can_delete'] ?? false,
      canExport: json['can_export'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'module_id': moduleId,
      'can_read': canRead,
      'can_insert': canInsert,
      'can_edit': canEdit,
      'can_delete': canDelete,
      'can_export': canExport,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
