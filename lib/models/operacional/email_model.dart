/// ============================================
/// MODELO: Email
/// ============================================
/// Representa um e-mail vinculado a um contato
/// 
/// Tabela: email
/// Campos:
///   - id: UUID (PK)
///   - contato_id: UUID (FK para contato)
///   - uso: String (CORPORATIVO, PARTICULAR, COMUNITARIO)
///   - endereco: String
///   - obs: Text
///   - atualizado_por: UUID (FK para Users)
///   - atualizado_em: DateTime
/// ============================================

class EmailModel {
  final String id;
  final String contatoId;
  final String uso;
  final String endereco;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  static const Map<String, String> usoLabels = {
    'CORPORATIVO': 'Corporativo',
    'PARTICULAR': 'Particular',
    'COMUNITARIO': 'Comunitário',
  };

  EmailModel({
    required this.id,
    required this.contatoId,
    required this.uso,
    required this.endereco,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      id: json['id']?.toString() ?? '',
      contatoId: json['contato_id']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      endereco: json['endereco']?.toString() ?? '',
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contato_id': contatoId,
      'uso': uso,
      'endereco': endereco,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  EmailModel copyWith({
    String? id,
    String? contatoId,
    String? uso,
    String? endereco,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
  }) {
    return EmailModel(
      id: id ?? this.id,
      contatoId: contatoId ?? this.contatoId,
      uso: uso ?? this.uso,
      endereco: endereco ?? this.endereco,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  String get usoLabel => usoLabels[uso] ?? uso;
}
