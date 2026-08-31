import '../../models/enums/documento_status_enum.dart';

/// Modelo para a tabela fontes_base
class FontesBase {
  final String? id;
  final String descricao;
  final String entidade;
  final double valor_recurso;
  final double? remanejamento;
  final DateTime? data_aprovacao;
  final String? obs;
  final List<String>? docs_recursos;  // Lista de IDs de documentos
  final String? atualizado_por;
  final DateTime? atualizado_em;
  final DateTime? created_at;

  // Propriedades calculadas (não armazenadas)
  double? saldo_total; // Carregado separadamente

  FontesBase({
    this.id,
    required this.descricao,
    required this.entidade,
    required this.valor_recurso,
    this.remanejamento,
    this.data_aprovacao,
    this.obs,
    this.docs_recursos,
    this.atualizado_por,
    this.atualizado_em,
    this.created_at,
    this.saldo_total,
  });

  factory FontesBase.fromJson(Map<String, dynamic> json) {
    return FontesBase(
      id: json['id'],
      descricao: json['descricao'] ?? '',
      entidade: json['entidade'] ?? '',
      valor_recurso: (json['valor_recurso'] ?? 0).toDouble(),
      remanejamento: json['remanejamento']?.toDouble(),
      data_aprovacao: json['data_aprovacao'] != null
          ? DateTime.parse(json['data_aprovacao'])
          : null,
      obs: json['obs'],
      docs_recursos: json['docs_recursos'] != null
          ? List<String>.from(json['docs_recursos'])
          : null,
      atualizado_por: json['atualizado_por'],
      atualizado_em: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      saldo_total: json['saldo_total']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'entidade': entidade,
      'valor_recurso': valor_recurso,
      'remanejamento': remanejamento,
      'data_aprovacao': data_aprovacao?.toIso8601String(),
      'obs': obs,
      'docs_recursos': docs_recursos,
      'atualizado_por': atualizado_por,
      'atualizado_em': atualizado_em?.toIso8601String(),
      'created_at': created_at?.toIso8601String(),
    };
  }

  // ✅ Método para criar cópia com campos atualizados
  FontesBase copyWith({
    String? id,
    String? descricao,
    String? entidade,
    double? valor_recurso,
    double? remanejamento,
    DateTime? data_aprovacao,
    String? obs,
    List<String>? docs_recursos,
    String? atualizado_por,
    DateTime? atualizado_em,
    DateTime? created_at,
    double? saldo_total,
  }) {
    return FontesBase(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      entidade: entidade ?? this.entidade,
      valor_recurso: valor_recurso ?? this.valor_recurso,
      remanejamento: remanejamento ?? this.remanejamento,
      data_aprovacao: data_aprovacao ?? this.data_aprovacao,
      obs: obs ?? this.obs,
      docs_recursos: docs_recursos ?? this.docs_recursos,
      atualizado_por: atualizado_por ?? this.atualizado_por,
      atualizado_em: atualizado_em ?? this.atualizado_em,
      created_at: created_at ?? this.created_at,
      saldo_total: saldo_total ?? this.saldo_total,
    );
  }

  // ✅ Getters para formatação
  String get valorRecursoFormatado {
    return 'R\$ ${valor_recurso.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get dataAprovacaoFormatada {
    if (data_aprovacao == null) return '';
    final d = data_aprovacao!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get remanejamentoFormatado {
    if (remanejamento == null) return '0%';
    return '${remanejamento!.toStringAsFixed(1)}%';
  }

  String get saldoFormatado {
    if (saldo_total == null) return 'R\$ 0,00';
    return 'R\$ ${saldo_total!.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}