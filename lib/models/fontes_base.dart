class FontesBase {
  final String id;
  final String descricao;
  final String entidade;
  final double valor_recurso;
  final double remanejamento;
  final DateTime data_aprovacao;
  final String? obs;
  final String? atualizado_por;
  final DateTime? atualizado_em;

  FontesBase({
    required this.id,
    required this.descricao,
    required this.entidade,
    required this.valor_recurso,
    required this.remanejamento,
    required this.data_aprovacao,
    this.obs,
    this.atualizado_por,
    this.atualizado_em,
  });

  factory FontesBase.fromJson(Map<String, dynamic> json) {
    return FontesBase(
      id: json['id'] ?? '',
      descricao: json['descricao'] ?? '',
      entidade: json['entidade'] ?? '',
      valor_recurso: (json['valor_recurso'] ?? 0).toDouble(),
      remanejamento: (json['remanejamento'] ?? 0).toDouble(),
      data_aprovacao: DateTime.parse(json['data_aprovacao'] ?? DateTime.now().toIso8601String()),
      obs: json['obs'],
      atualizado_por: json['atualizado_por'],
      atualizado_em: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'entidade': entidade,
      'valor_recurso': valor_recurso,
      'remanejamento': remanejamento,
      'data_aprovacao': data_aprovacao.toIso8601String(),
      'obs': obs,
      'atualizado_por': atualizado_por,
      'atualizado_em': atualizado_em?.toIso8601String(),
    };
  }
}