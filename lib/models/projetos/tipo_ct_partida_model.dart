/// ============================================
/// MODELO: TipoCtPartida (Tipo de Contra Partida)
/// REGRA 11
/// ============================================

class TipoCtPartidaModel {
  final String id;
  final String descricao;
  final String rubricaId;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TipoCtPartidaModel({
    required this.id,
    required this.descricao,
    required this.rubricaId,
    this.atualizadoPor,
    this.atualizadoEm,
    this.createdAt,
    this.updatedAt,
  });

  factory TipoCtPartidaModel.fromJson(Map<String, dynamic> json) {
    return TipoCtPartidaModel(
      id: json['id']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      rubricaId: json['rubrica']?.toString() ?? '',
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'].toString())
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
      'descricao': descricao,
      'rubrica': rubricaId,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  TipoCtPartidaModel copyWith({
    String? id,
    String? descricao,
    String? rubricaId,
    String? atualizadoPor,
    DateTime? atualizadoEm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TipoCtPartidaModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      rubricaId: rubricaId ?? this.rubricaId,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}