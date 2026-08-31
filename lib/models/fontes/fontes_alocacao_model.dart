import '../enums/destino_tipo_enum.dart';

/// Modelo para a tabela fontes_alocacao
class FontesAlocacao {
  final String? id;
  final String fonte_alocacao_id;
  final DestinoTipo destino_tipo;
  final String destino_id;
  final String descricao;
  final double valor_alocado;
  final double saldo_recurso;  // ✅ Armazenado (calculado)
  final DateTime? data_alocacao;
  final String? obs;
  final List<String>? docs_alocacao;  // Lista de IDs de documentos
  final String? atualizado_por;
  final DateTime? atualizado_em;
  final DateTime? created_at;

  // Propriedades para carregar dados do destino (relacionamento)
  Map<String, dynamic>? destino;

  FontesAlocacao({
    this.id,
    required this.fonte_alocacao_id,
    required this.destino_tipo,
    required this.destino_id,
    required this.descricao,
    required this.valor_alocado,
    required this.saldo_recurso,
    this.data_alocacao,
    this.obs,
    this.docs_alocacao,
    this.atualizado_por,
    this.atualizado_em,
    this.created_at,
    this.destino,
  });

  factory FontesAlocacao.fromJson(Map<String, dynamic> json) {
    return FontesAlocacao(
      id: json['id'],
      fonte_alocacao_id: json['fonte_alocacao_id'] ?? '',
      destino_tipo: DestinoTipo.fromString(json['destino_tipo'] ?? 'projeto'),
      destino_id: json['destino_id'] ?? '',
      descricao: json['descricao'] ?? '',
      valor_alocado: (json['valor_alocado'] ?? 0).toDouble(),
      saldo_recurso: (json['saldo_recurso'] ?? 0).toDouble(),
      data_alocacao: json['data_alocacao'] != null
          ? DateTime.parse(json['data_alocacao'])
          : null,
      obs: json['obs'],
      docs_alocacao: json['docs_alocacao'] != null
          ? List<String>.from(json['docs_alocacao'])
          : null,
      atualizado_por: json['atualizado_por'],
      atualizado_em: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      destino: json['destino'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fonte_alocacao_id': fonte_alocacao_id,
      'destino_tipo': destino_tipo.toJson(),
      'destino_id': destino_id,
      'descricao': descricao,
      'valor_alocado': valor_alocado,
      'saldo_recurso': saldo_recurso,
      'data_alocacao': data_alocacao?.toIso8601String(),
      'obs': obs,
      'docs_alocacao': docs_alocacao,
      'atualizado_por': atualizado_por,
      'atualizado_em': atualizado_em?.toIso8601String(),
      'created_at': created_at?.toIso8601String(),
    };
  }

  // ✅ Método para criar cópia com campos atualizados
  FontesAlocacao copyWith({
    String? id,
    String? fonte_alocacao_id,
    DestinoTipo? destino_tipo,
    String? destino_id,
    String? descricao,
    double? valor_alocado,
    double? saldo_recurso,
    DateTime? data_alocacao,
    String? obs,
    List<String>? docs_alocacao,
    String? atualizado_por,
    DateTime? atualizado_em,
    DateTime? created_at,
    Map<String, dynamic>? destino,
  }) {
    return FontesAlocacao(
      id: id ?? this.id,
      fonte_alocacao_id: fonte_alocacao_id ?? this.fonte_alocacao_id,
      destino_tipo: destino_tipo ?? this.destino_tipo,
      destino_id: destino_id ?? this.destino_id,
      descricao: descricao ?? this.descricao,
      valor_alocado: valor_alocado ?? this.valor_alocado,
      saldo_recurso: saldo_recurso ?? this.saldo_recurso,
      data_alocacao: data_alocacao ?? this.data_alocacao,
      obs: obs ?? this.obs,
      docs_alocacao: docs_alocacao ?? this.docs_alocacao,
      atualizado_por: atualizado_por ?? this.atualizado_por,
      atualizado_em: atualizado_em ?? this.atualizado_em,
      created_at: created_at ?? this.created_at,
      destino: destino ?? this.destino,
    );
  }

  // ✅ Getters para formatação
  String get valorAlocadoFormatado {
    return 'R\$ ${valor_alocado.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get saldoRecursoFormatado {
    return 'R\$ ${saldo_recurso.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get dataAlocacaoFormatada {
    if (data_alocacao == null) return '';
    final d = data_alocacao!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get destinoLabel => destino_tipo.label;
}