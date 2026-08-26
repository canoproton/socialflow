/// ============================================
/// MODELO: Projeto
/// ============================================

class ProjetoModel {
  final String id;
  final String? descricao;
  final String? processo;
  final String? proponenteId;
  final String? contaId;
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
  final DateTime? dataEntrega;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.dataEntrega,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjetoModel.fromJson(Map<String, dynamic> json) {
    return ProjetoModel(
      id: json['id']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      processo: json['processo']?.toString(),
      proponenteId: json['proponente']?.toString(),
      contaId: json['conta']?.toString(),
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
      dataEntrega: json['data_entrega'] != null
          ? DateTime.parse(json['data_entrega'].toString())
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
      'data_entrega': dataEntrega?.toIso8601String(),
    };
  }

  String get statusLabel => statusLabels[statusProjeto] ?? statusProjeto;
}