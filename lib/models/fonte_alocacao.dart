import 'projeto_model.dart';
import 'fontes_base.dart';

class FonteAlocacao {
  final String id;
  final String fonte_alocacao_id;
  final String destino_alocao_id;
  final String descricao;
  final double valor_alocado;
  final double saldo_recurso;
  final DateTime data_alocacao;
  final String? obs;
  final String? atualizado_por;
  final DateTime? atualizado_em;
  
  final FontesBase? fonte;
  final Projeto? projeto;

  FonteAlocacao({
    required this.id,
    required this.fonte_alocacao_id,
    required this.destino_alocao_id,
    required this.descricao,
    required this.valor_alocado,
    required this.saldo_recurso,
    required this.data_alocacao,
    this.obs,
    this.atualizado_por,
    this.atualizado_em,
    this.fonte,
    this.projeto,
  });

  factory FonteAlocacao.fromJson(Map<String, dynamic> json) {
    return FonteAlocacao(
      id: json['id'] ?? '',
      fonte_alocacao_id: json['fonte_alocacao_id'] ?? json['fonte_alocacao'] ?? '',
      destino_alocao_id: json['destino_alocao_id'] ?? json['destino_alocao'] ?? '',
      descricao: json['descricao'] ?? '',
      valor_alocado: (json['valor_alocado'] ?? 0).toDouble(),
      saldo_recurso: (json['saldo_recurso'] ?? 0).toDouble(),
      data_alocacao: DateTime.parse(json['data_alocacao'] ?? DateTime.now().toIso8601String()),
      obs: json['obs'],
      atualizado_por: json['atualizado_por'],
      atualizado_em: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em']) 
          : null,
      fonte: json['fonte'] is Map 
          ? FontesBase.fromJson(json['fonte']) 
          : null,
      projeto: json['projeto'] is Map 
          ? Projeto.fromJson(json['projeto']) 
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
      'data_alocacao': data_alocacao.toIso8601String(),
      'obs': obs,
      'atualizado_por': atualizado_por,
      'atualizado_em': atualizado_em?.toIso8601String(),
    };
  }
}