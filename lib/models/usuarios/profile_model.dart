import '../../middleware/security_middleware.dart';

class ProfileModel {
  final String id;
  final String userId;
  final String email;
  final String nome;
  final String? cargo;
  final String? departamento;
  final String? telefone;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.nome,
    this.cargo,
    this.departamento,
    this.telefone,
    this.avatarUrl,
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Instância simples
    final security = SecurityMiddleware();
    
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nome: security.sanitizeInput(json['nome']?.toString() ?? ''),
      cargo: json['cargo'] != null ? security.sanitizeInput(json['cargo'].toString()) : null,
      departamento: json['departamento'] != null ? security.sanitizeInput(json['departamento'].toString()) : null,
      telefone: json['telefone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'].toString()) 
          : null,
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
      'email': email,
      'nome': nome,
      'cargo': cargo,
      'departamento': departamento,
      'telefone': telefone,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? nome,
    String? cargo,
    String? departamento,
    String? telefone,
    String? avatarUrl,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      cargo: cargo ?? this.cargo,
      departamento: departamento ?? this.departamento,
      telefone: telefone ?? this.telefone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get initials {
    final names = nome.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return nome.substring(0, 2).toUpperCase();
  }

  String get firstName => nome.split(' ').first;

  String get maskedEmail => SecurityMiddleware().maskEmail(email);
}
