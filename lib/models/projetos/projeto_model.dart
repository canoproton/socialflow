/// ============================================
/// MODELO: Projeto (Especificação Completa)
/// ============================================

import 'meta_model.dart';

class ProjetoModel {
  final String id;
  final String? descricao;
  final String? processo;
  final String? proponenteId;
  final String? contaId;
  final List<String>? docsAnexo;
  final List<String>? recursos;
  final List<String>? contraPartida;
  final DateTime? dataEntrega;
  final double? valorEstimado;
  final DateTime? dataAprovacao;
  final double? valorAprovado;
  final double? valorTotalAportado;
  final double? valorTotalMetas;
  final double? saldoProjeto;
  final String? gerenteProjetoId;
  final String statusProjeto;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<MetaModel> metas;

  // ⭐ STATUS DO PROJETO (Regra 1)
  static const String STATUS_ORCAMENTO = 'ORÇAMENTO';
  static const String STATUS_EMITIDO = 'EMITIDO';
  static const String STATUS_APROVADO = 'APROVADO';
  static const String STATUS_INDEFERIDO = 'INDEFERIDO';
  static const String STATUS_EXECUTANDO = 'EXECUTANDO';
  static const String STATUS_FINALIZADO = 'FINALIZADO';

  static const List<String> statusOptions = [
    STATUS_ORCAMENTO,
    STATUS_EMITIDO,
    STATUS_APROVADO,
    STATUS_INDEFERIDO,
    STATUS_EXECUTANDO,
    STATUS_FINALIZADO,
  ];

  static const Map<String, String> statusLabels = {
    STATUS_ORCAMENTO: 'Orçamento',
    STATUS_EMITIDO: 'Emitido',
    STATUS_APROVADO: 'Aprovado',
    STATUS_INDEFERIDO: 'Indeferido',
    STATUS_EXECUTANDO: 'Executando',
    STATUS_FINALIZADO: 'Finalizado',
  };

  ProjetoModel({
    required this.id,
    this.descricao,
    this.processo,
    this.proponenteId,
    this.contaId,
    this.docsAnexo,
    this.recursos,
    this.contraPartida,
    this.dataEntrega,
    this.valorEstimado,
    this.dataAprovacao,
    this.valorAprovado,
    this.valorTotalAportado,
    this.valorTotalMetas,
    this.saldoProjeto,
    this.gerenteProjetoId,
    required this.statusProjeto,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
    this.createdAt,
    this.updatedAt,
    this.metas = const [],
  });

  factory ProjetoModel.fromJson(Map<String, dynamic> json) {
    return ProjetoModel(
      id: json['id']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      processo: json['processo']?.toString(),
      proponenteId: json['proponente']?.toString(),
      contaId: json['conta']?.toString(),
      docsAnexo: json['docs_anexo'] != null
          ? List<String>.from(json['docs_anexo'])
          : null,
      recursos: json['recursos'] != null
          ? List<String>.from(json['recursos'])
          : null,
      contraPartida: json['contra_partida'] != null
          ? List<String>.from(json['contra_partida'])
          : null,
      dataEntrega: json['data_entrega'] != null
          ? DateTime.parse(json['data_entrega'].toString())
          : null,
      valorEstimado: json['valor_estimado']?.toDouble(),
      dataAprovacao: json['data_aprovacao'] != null
          ? DateTime.parse(json['data_aprovacao'].toString())
          : null,
      valorAprovado: json['valor_aprovado']?.toDouble(),
      valorTotalAportado: json['valor_total_aportado']?.toDouble(),
      valorTotalMetas: json['valor_total_metas']?.toDouble(),
      saldoProjeto: json['saldo_projeto']?.toDouble(),
      gerenteProjetoId: json['gerente_projeto']?.toString(),
      statusProjeto: json['status_projeto']?.toString() ?? STATUS_ORCAMENTO,
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
      'descricao': descricao,
      'processo': processo,
      'proponente': proponenteId,
      'conta': contaId,
      'docs_anexo': docsAnexo,
      'recursos': recursos,
      'contra_partida': contraPartida,
      'data_entrega': dataEntrega?.toIso8601String(),
      'valor_estimado': valorEstimado,
      'data_aprovacao': dataAprovacao?.toIso8601String(),
      'valor_aprovado': valorAprovado,
      'valor_total_aportado': valorTotalAportado,
      'valor_total_metas': valorTotalMetas,
      'saldo_projeto': saldoProjeto,
      'gerente_projeto': gerenteProjetoId,
      'status_projeto': statusProjeto,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  ProjetoModel copyWith({
    String? id,
    String? descricao,
    String? processo,
    String? proponenteId,
    String? contaId,
    List<String>? docsAnexo,
    List<String>? recursos,
    List<String>? contraPartida,
    DateTime? dataEntrega,
    double? valorEstimado,
    DateTime? dataAprovacao,
    double? valorAprovado,
    double? valorTotalAportado,
    double? valorTotalMetas,
    double? saldoProjeto,
    String? gerenteProjetoId,
    String? statusProjeto,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MetaModel>? metas,
  }) {
    return ProjetoModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      processo: processo ?? this.processo,
      proponenteId: proponenteId ?? this.proponenteId,
      contaId: contaId ?? this.contaId,
      docsAnexo: docsAnexo ?? this.docsAnexo,
      recursos: recursos ?? this.recursos,
      contraPartida: contraPartida ?? this.contraPartida,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      valorEstimado: valorEstimado ?? this.valorEstimado,
      dataAprovacao: dataAprovacao ?? this.dataAprovacao,
      valorAprovado: valorAprovado ?? this.valorAprovado,
      valorTotalAportado: valorTotalAportado ?? this.valorTotalAportado,
      valorTotalMetas: valorTotalMetas ?? this.valorTotalMetas,
      saldoProjeto: saldoProjeto ?? this.saldoProjeto,
      gerenteProjetoId: gerenteProjetoId ?? this.gerenteProjetoId,
      statusProjeto: statusProjeto ?? this.statusProjeto,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metas: metas ?? this.metas,
    );
  }

  String get statusLabel => statusLabels[statusProjeto] ?? statusProjeto;

  // ⭐ VALIDAÇÃO DO PROCESSO (Regra 1)
  static bool validarProcesso(String processo) {
    final regex = RegExp(r'^\d{5}-\d{8}/\d{4}-\d{2}$');
    return regex.hasMatch(processo);
  }

  // ⭐ CÁLCULO DO SALDO DO PROJETO
  double get saldoCalculado {
    return (valorTotalAportado ?? 0) - (valorTotalMetas ?? 0);
  }
}