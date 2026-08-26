/// ============================================
/// MODELO: Meta do Projeto (Especificação Completa)
/// ============================================

class MetaModel {
  final String id;
  final String projetoId;
  final int? sequencia; // Auto incremento pelo sistema
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
  final String? supervisorId; // One2one com Users
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relacionamentos
  List<EtapaModel> etapas;
  List<DocumentoModel>? documentos;

  // ✅ CONSTANTES DE STATUS
  static const String STATUS_PENDENTE = 'pendente';
  static const String STATUS_EM_ANDAMENTO = 'em_andamento';
  static const String STATUS_CONCLUIDA = 'concluida';
  static const String STATUS_CANCELADA = 'cancelada';

  static const List<String> statusOptions = [
    STATUS_PENDENTE,
    STATUS_EM_ANDAMENTO,
    STATUS_CONCLUIDA,
    STATUS_CANCELADA,
  ];

  static const Map<String, String> statusLabels = {
    STATUS_PENDENTE: 'Pendente',
    STATUS_EM_ANDAMENTO: 'Em Andamento',
    STATUS_CONCLUIDA: 'Concluída',
    STATUS_CANCELADA: 'Cancelada',
  };

  static const Map<String, Color> statusColors = {
    STATUS_PENDENTE: Colors.orange,
    STATUS_EM_ANDAMENTO: Colors.blue,
    STATUS_CONCLUIDA: Colors.green,
    STATUS_CANCELADA: Colors.red,
  };

  // ✅ CONSTRUTOR
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
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
    this.createdAt,
    this.updatedAt,
    this.etapas = const [],
    this.documentos,
  });

  // ✅ FACTORY FROM JSON
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

  // ✅ TO JSON
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
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  // ✅ COPY WITH
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
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<EtapaModel>? etapas,
    List<DocumentoModel>? documentos,
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
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      etapas: etapas ?? this.etapas,
      documentos: documentos ?? this.documentos,
    );
  }

  // ✅ GETTERS
  String get statusLabel => 'Pendente'; // Status da meta é calculado baseado nas etapas
  Color get statusColor => Colors.orange;

  // ✅ CÁLCULO DO STATUS BASEADO NAS ETAPAS
  String calcularStatus() {
    if (etapas.isEmpty) return STATUS_PENDENTE;
    
    bool todasConcluidas = etapas.every((e) => e.status == EtapaModel.STATUS_CONCLUIDA);
    if (todasConcluidas) return STATUS_CONCLUIDA;
    
    bool algumaEmExecucao = etapas.any((e) => e.status == EtapaModel.STATUS_EXECUCAO);
    if (algumaEmExecucao) return STATUS_EM_ANDAMENTO;
    
    bool algumaCancelada = etapas.any((e) => e.status == EtapaModel.STATUS_CANCELADA);
    if (algumaCancelada) return STATUS_CANCELADA;
    
    return STATUS_PENDENTE;
  }
}