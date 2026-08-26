/// Modelo de Usuário do SocialFlow
/// Representa os dados do usuário autenticado no sistema
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.isActive = true,
    this.createdAt,
    this.lastLogin,
  });

  /// Converte um mapa (JSON) para um objeto UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString(),
      role: map['role']?.toString(),
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : null,
      lastLogin: map['last_login'] != null 
          ? DateTime.parse(map['last_login'].toString()) 
          : null,
    );
  }

  /// Converte um objeto UserModel para mapa (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Retorna o nome do usuário ou "Usuário" se não tiver nome
  String get displayName => name ?? email.split('@').first;

  /// Cópia do usuário com dados atualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}