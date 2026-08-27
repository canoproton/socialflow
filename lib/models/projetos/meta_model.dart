/// ============================================
/// MODELO: Meta do Projeto (Especificação Completa)
/// ============================================

import 'etapa_model.dart';

class MetaModel {
  final String id;
  final String projetoId;
  final int? sequencia;
  final String? descricao;
  final String? indicador;
  final String? unidade;
  final String? quantifiq;
  final String? publicoAlvo;
  final String? local;
  final String? prova;
  final double? vlMetaAprov;
  final double? valorTotalEtapas;
  final double? saldoMeta;
  final String? supervisorId;
  final List<String>? docsMetas;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<EtapaModel> etapas;

  MetaModel({
    required this.id,
    required this.projetoId,
    this.sequencia,
    this.descricao,
    this.indicador,
    this.unidade,
    this.quantifiq,
    this.publicoAlvo,
    this.local,
    this.prova,
    this.vlMetaAprov,
    this.valorTotalEtapas,
    this.saldoMeta,
    this.supervisorId,
    this.docsMetas,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
    this.createdAt,
    this.updatedAt,
    this.etapas = const [],
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      id: json['id']?.toString() ?? '',
      projetoId: json['projeto_id']?.toString() ?? '',
      sequencia: json['sequencia'] as int?,
      descricao: json['descricao']?.toString(),
      indicador: json['indicador']?.toString(),
      unidade: json['unidade']?.toString(),
      quantifiq: json['quantifiq']?.toString(),
      publicoAlvo: json['publico']?.toString(),
      local: json['local']?.toString(),
      prova: json['prova']?.toString(),
      vlMetaAprov: json['vl_meta_aprov']?.toDouble(),
      valorTotalEtapas: json['valor_total_etapas']?.toDouble(),
      saldoMeta: json['saldo_meta']?.toDouble(),
      supervisorId: json['supervisor']?.toString(),
      docsMetas: json['docs_metas'] != null
          ? List<String>.from(json['docs_metas'])
          : null,
      obs: json['obs']?.toString(),
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
      'projeto_id': projetoId,
      'sequencia': sequencia,
      'descricao': descricao,
      'indicador': indicador,
      'unidade': unidade,
      'quantifiq': quantifiq,
      'publico': publicoAlvo,
      'local': local,
      'prova': prova,
      'vl_meta_aprov': vlMetaAprov,
      'valor_total_etapas': valorTotalEtapas,
      'saldo_meta': saldoMeta,
      'supervisor': supervisorId,
      'docs_metas': docsMetas,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  MetaModel copyWith({
    String? id,
    String? projetoId,
    int? sequencia,
    String? descricao,
    String? indicador,
    String? unidade,
    String? quantifiq,
    String? publicoAlvo,
    String? local,
    String? prova,
    double? vlMetaAprov,
    double? valorTotalEtapas,
    double? saldoMeta,
    String? supervisorId,
    List<String>? docsMetas,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<EtapaModel>? etapas,
  }) {
    return MetaModel(
      id: id ?? this.id,
      projetoId: projetoId ?? this.projetoId,
      sequencia: sequencia ?? this.sequencia,
      descricao: descricao ?? this.descricao,
      indicador: indicador ?? this.indicador,
      unidade: unidade ?? this.unidade,
      quantifiq: quantifiq ?? this.quantifiq,
      publicoAlvo: publicoAlvo ?? this.publicoAlvo,
      local: local ?? this.local,
      prova: prova ?? this.prova,
      vlMetaAprov: vlMetaAprov ?? this.vlMetaAprov,
      valorTotalEtapas: valorTotalEtapas ?? this.valorTotalEtapas,
      saldoMeta: saldoMeta ?? this.saldoMeta,
      supervisorId: supervisorId ?? this.supervisorId,
      docsMetas: docsMetas ?? this.docsMetas,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      etapas: etapas ?? this.etapas,
    );
  }

  // ⭐ CÁLCULO DO SALDO DA META (Regra 4)
  double get saldoCalculado {
    return (vlMetaAprov ?? 0) - (valorTotalEtapas ?? 0);
  }
}