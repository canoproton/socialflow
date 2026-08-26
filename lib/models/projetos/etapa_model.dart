/// ============================================
/// MODELO: Etapa da Meta
/// ============================================

class EtapaModel {
  final String id;
  final String metaId;
  final int? sequencia;
  final String? descricao;
  final String? rubricaId;
  final String? executorId;
  final String? areaId;
  final String? unidadeEtapaId;
  final DateTime? dataInicio;
  final DateTime? dataVencimento;
  final double? valorUnitario;
  final String? unidadePgtoId;
  final double? quantidade;
  final double? valorEtapa;
  final String status;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static const String STATUS_PLANEJADA = 'PLANEJADA';
  static const String STATUS_ACIONADO = 'ACIONADO';
  static const String STATUS_EXECUCAO = 'EXECUÇÃO';
  static const String STATUS_PENDENTE = 'PENDENTE';
  static const String STATUS_CONCLUIDA = 'CONCLUIDA';
  static const String STATUS_CANCELADA = 'CANCELADA';

  static const List<String> statusOptions = [
    STATUS_PLANEJADA,
    STATUS_ACIONADO,
    STATUS_EXECUCAO,
    STATUS_PENDENTE,
    STATUS_CONCLUIDA,
    STATUS_CANCELADA,
  ];

  static const Map<String, String> statusLabels = {
    STATUS_PLANEJADA: 'Planejada',
    STATUS_ACIONADO: 'Acionado',
    STATUS_EXECUCAO: 'Execução',
    STATUS_PENDENTE: 'Pendente',
    STATUS_CONCLUIDA: 'Concluída',
    STATUS_CANCELADA: 'Cancelada',
  };

  EtapaModel({
    required this.id,
    required this.metaId,
    this.sequencia,
    this.descricao,
    this.rubricaId,
    this.executorId,
    this.areaId,
    this.unidadeEtapaId,
    this.dataInicio,
    this.dataVencimento,
    this.valorUnitario,
    this.unidadePgtoId,
    this.quantidade,
    this.valorEtapa,
    required this.status,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
    this.createdAt,
    this.updatedAt,
  });

  factory EtapaModel.fromJson(Map<String, dynamic> json) {
    return EtapaModel(
      id: json['id']?.toString() ?? '',
      metaId: json['meta_projeto_id']?.toString() ?? '',
      sequencia: json['sequencia'] as int?,
      descricao: json['descricao']?.toString(),
      rubricaId: json['rubrica']?.toString(),
      executorId: json['executor']?.toString(),
      areaId: json['area']?.toString(),
      unidadeEtapaId: json['unidade_etapa']?.toString(),
      dataInicio: json['data_inicio'] != null
          ? DateTime.parse(json['data_inicio'].toString())
          : null,
      dataVencimento: json['data_vencimento'] != null
          ? DateTime.parse(json['data_vencimento'].toString())
          : null,
      valorUnitario: json['valor_unitario']?.toDouble(),
      unidadePgtoId: json['unidade_pgto']?.toString(),
      quantidade: json['quantidade']?.toDouble(),
      valorEtapa: json['valor_etapa']?.toDouble(),
      status: json['status']?.toString() ?? STATUS_PLANEJADA,
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
      'meta_projeto_id': metaId,
      'sequencia': sequencia,
      'descricao': descricao,
      'rubrica': rubricaId,
      'executor': executorId,
      'area': areaId,
      'unidade_etapa': unidadeEtapaId,
      'data_inicio': dataInicio?.toIso8601String(),
      'data_vencimento': dataVencimento?.toIso8601String(),
      'valor_unitario': valorUnitario,
      'unidade_pgto': unidadePgtoId,
      'quantidade': quantidade,
      'valor_etapa': valorEtapa,
      'status': status,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  String get statusLabel => statusLabels[status] ?? status;
}