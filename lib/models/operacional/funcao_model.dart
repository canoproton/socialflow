/// ============================================
/// MODELO: Funcao
/// ============================================
/// Representa um cargo/função exercida por um contato
/// 
/// Tabela: funcao
/// Campos:
///   - id: UUID (PK)
///   - descricao: String (ex: "Gerente de Projetos")
///   - atualizado_por: UUID (FK para Users)
///   - atualizado_em: DateTime
/// ============================================

class FuncaoModel {
  final String id;
  final String descricao;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  FuncaoModel({
    required this.id,
    required this.descricao,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  /// Converte JSON para objeto
  factory FuncaoModel.fromJson(Map<String, dynamic> json) {
    return FuncaoModel(
      id: json['id']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em'].toString()) 
          : null,
    );
  }

  /// Converte objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  /// Cria cópia com dados atualizados
  FuncaoModel copyWith({
    String? id,
    String? descricao,
    String? atualizadoPor,
    DateTime? atualizadoEm,
  }) {
    return FuncaoModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
