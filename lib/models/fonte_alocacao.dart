class FonteAlocacao {
  final String? id;
  final String? fonte_alocacao_id;  // ← Nome correto (com _id)
  final String? destino_alocao_id;   // ← Nome correto (com _id)
  final String? descricao;
  final double? valor_alocado;
  final double? saldo_recurso;
  final DateTime? data_alocacao;
  final String? obs;
  final String? atualizado_por;
  final DateTime? atualizado_em;
  final DateTime? created_at;

  FonteAlocacao({
    this.id,
    this.fonte_alocacao_id,
    this.destino_alocao_id,
    this.descricao,
    this.valor_alocado,
    this.saldo_recurso,
    this.data_alocacao,
    this.obs,
    this.atualizado_por,
    this.atualizado_em,
    this.created_at,
  });

  factory FonteAlocacao.fromJson(Map<String, dynamic> json) {
    return FonteAlocacao(
      id: json['id'],
      fonte_alocacao_id: json['fonte_alocacao_id'],
      destino_alocao_id: json['destino_alocao_id'],
      descricao: json['descricao'],
      valor_alocado: json['valor_alocado']?.toDouble(),
      saldo_recurso: json['saldo_recurso']?.toDouble(),
      data_alocacao: json['data_alocacao'] != null
          ? DateTime.parse(json['data_alocacao'])
          : null,
      obs: json['obs'],
      atualizado_por: json['atualizado_por'],
      atualizado_em: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fonte_alocacao_id': fonte_alocacao_id,
      'destino_alocao_id': destino_alocao_id,
      'descricao': descricao,
      'valor_alocado': valor_alocado,
      'saldo_recurso': saldo_recurso,
      'data_alocacao': data_alocacao?.toIso8601String(),
      'obs': obs,
      'atualizado_por': atualizado_por,
      'atualizado_em': atualizado_em?.toIso8601String(),
      'created_at': created_at?.toIso8601String(),
    };
  }

  FonteAlocacao copyWith({
    String? id,
    String? fonte_alocacao_id,
    String? destino_alocao_id,
    String? descricao,
    double? valor_alocado,
    double? saldo_recurso,
    DateTime? data_alocacao,
    String? obs,
    String? atualizado_por,
    DateTime? atualizado_em,
    DateTime? created_at,
  }) {
    return FonteAlocacao(
      id: id ?? this.id,
      fonte_alocacao_id: fonte_alocacao_id ?? this.fonte_alocacao_id,
      destino_alocao_id: destino_alocao_id ?? this.destino_alocao_id,
      descricao: descricao ?? this.descricao,
      valor_alocado: valor_alocado ?? this.valor_alocado,
      saldo_recurso: saldo_recurso ?? this.saldo_recurso,
      data_alocacao: data_alocacao ?? this.data_alocacao,
      obs: obs ?? this.obs,
      atualizado_por: atualizado_por ?? this.atualizado_por,
      atualizado_em: atualizado_em ?? this.atualizado_em,
      created_at: created_at ?? this.created_at,
    );
  }
}