/// ============================================
/// MODELO: Projeto (Especificação Completa)
/// ============================================

class ProjetoModel {
  final String id;
  final String? descricao;
  final String? processo; // Formato: XXXXX-XXXXXXXX/XXXX-XX
  final String? proponenteId; // One2one com Empresa
  final String? contaId; // One2one com CBanc
  final double? valorEstimado;
  final DateTime? dataAprovacao;
  final double? valorAprovado;
  final double? valorTotalAportado;
  final double? valorTotalMetas;
  final double? saldoProjeto;
  final String? gerenteProjetoId; // One2one com Users
  final String statusProjeto; // ORÇAMENTO, EMITIDO, APROVADO, INDEFERIDO, EXECUTANDO, FINALIZADO
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? dataEntrega;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relacionamentos (serão carregados separadamente)
  List<MetaModel> metas;
  List<DocumentoModel>? documentos;
  List<FontesBaseModel>? recursos;
  List<ContraPartidaModel>? contraPartidas;

  // ✅ CONSTANTES DE STATUS (conforme especificação)
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

  static const Map<String, Color> statusColors = {
    STATUS_ORCAMENTO: Colors.orange,
    STATUS_EMITIDO: Colors.blue,
    STATUS_APROVADO: Colors.green,
    STATUS_INDEFERIDO: Colors.red,
    STATUS_EXECUTANDO: Colors.purple,
    STATUS_FINALIZADO: Colors.grey,
  };

  // ✅ CONSTRUTOR
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
    this.metas = const [],
    this.documentos,
    this.recursos,
    this.contraPartidas,
  });

  // ✅ FACTORY FROM JSON
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

  // ✅ TO JSON
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

  // ✅ COPY WITH
  ProjetoModel copyWith({
    String? id,
    String? descricao,
    String? processo,
    String? proponenteId,
    String? contaId,
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
    DateTime? dataEntrega,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MetaModel>? metas,
    List<DocumentoModel>? documentos,
    List<FontesBaseModel>? recursos,
    List<ContraPartidaModel>? contraPartidas,
  }) {
    return ProjetoModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      processo: processo ?? this.processo,
      proponenteId: proponenteId ?? this.proponenteId,
      contaId: contaId ?? this.contaId,
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
      dataEntrega: dataEntrega ?? this.dataEntrega,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metas: metas ?? this.metas,
      documentos: documentos ?? this.documentos,
      recursos: recursos ?? this.recursos,
      contraPartidas: contraPartidas ?? this.contraPartidas,
    );
  }

  // ✅ GETTERS
  String get statusLabel => statusLabels[statusProjeto] ?? statusProjeto;
  Color get statusColor => statusColors[statusProjeto] ?? Colors.grey;

  // ✅ VALIDAÇÃO DO PROCESSO (Regra 1)
  static bool validarProcesso(String processo) {
    // Formato: XXXXX-XXXXXXXX/XXXX-XX
    final regex = RegExp(r'^\d{5}-\d{8}/\d{4}-\d{2}$');
    return regex.hasMatch(processo);
  }
}