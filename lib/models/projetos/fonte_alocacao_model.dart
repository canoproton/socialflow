/// ============================================
/// MODELO: FonteAlocacao (Alocação de Recurso)
/// REGRA 7
/// ============================================

class FonteAlocacaoModel {
  final String id;
  final String fonteAlocacaoId;
  final String destinoAlocacaoId;
  final String descricao;
  final double valorAlocado;
  final double? saldoRecurso;
  final DateTime? dataAlocacao;
  final String? obs;
  final String? docsAlocacao;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FonteAlocacaoModel({
    required this.id,
    required this.fonteAlocacaoId,
    required this.destinoAlocacaoId,
    required this.descricao,
    required this.valorAlocado,
    this.saldoRecurso,
    this.dataAlocacao,
    this.obs,
    this.docsAlocacao,
    this.atualizadoPor,
    this.atualizadoEm,
    this.createdAt,
    this.updatedAt,
  });

  factory FonteAlocacaoModel.fromJson(Map<String, dynamic> json) {
    return FonteAlocacaoModel(
      id: json['id']?.toString() ?? '',
      fonteAlocacaoId: json['fonte_alocacao']?.toString() ?? '',
      destinoAlocacaoId: json['destino_alocacao']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      valorAlocado: (json['valor_alocado'] ?? 0.0).toDouble(),
      saldoRecurso: json['saldo_recurso']?.toDouble(),
      dataAlocacao: json['data_alocacao'] != null
          ? DateTime.parse(json['data_alocacao'].toString())
          : null,
      obs: json['obs']?.toString(),
      docsAlocacao: json['docs_alocacao']?.toString(),
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
      'fonte_alocacao': fonteAlocacaoId,
      'destino_alocacao': destinoAlocacaoId,
      'descricao': descricao,
      'valor_alocado': valorAlocado,
      'saldo_recurso': saldoRecurso,
      'data_alocacao': dataAlocacao?.toIso8601String(),
      'obs': obs,
      'docs_alocacao': docsAlocacao,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  FonteAlocacaoModel copyWith({
    String? id,
    String? fonteAlocacaoId,
    String? destinoAlocacaoId,
    String? descricao,
    double? valorAlocado,
    double? saldoRecurso,
    DateTime? dataAlocacao,
    String? obs,
    String? docsAlocacao,
    String? atualizadoPor,
    DateTime? atualizadoEm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FonteAlocacaoModel(
      id: id ?? this.id,
      fonteAlocacaoId: fonteAlocacaoId ?? this.fonteAlocacaoId,
      destinoAlocacaoId: destinoAlocacaoId ?? this.destinoAlocacaoId,
      descricao: descricao ?? this.descricao,
      valorAlocado: valorAlocado ?? this.valorAlocado,
      saldoRecurso: saldoRecurso ?? this.saldoRecurso,
      dataAlocacao: dataAlocacao ?? this.dataAlocacao,
      obs: obs ?? this.obs,
      docsAlocacao: docsAlocacao ?? this.docsAlocacao,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}