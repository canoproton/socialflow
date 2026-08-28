/// ============================================
/// MODELO: ContraPartida
/// REGRA 11
/// ============================================

class ContraPartidaModel {
  final String id;
  final String projetoId;
  final String tipoId;
  final String descricao;
  final double valor;
  final double? quantidade;
  final double? valorTotalCp;
  final DateTime? dataEntrega;
  final String status;
  final String? obs;  // ⭐ CAMPO ADICIONADO
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static const String STATUS_PENDENTE = 'PENDENTE';
  static const String STATUS_CONFIRMADO = 'CONFIRMADO';
  static const String STATUS_REALIZADO = 'REALIZADO';

  static const List<String> statusOptions = [
    STATUS_PENDENTE,
    STATUS_CONFIRMADO,
    STATUS_REALIZADO,
  ];

  static const Map<String, String> statusLabels = {
    STATUS_PENDENTE: 'Pendente',
    STATUS_CONFIRMADO: 'Confirmado',
    STATUS_REALIZADO: 'Realizado',
  };

  ContraPartidaModel({
    required this.id,
    required this.projetoId,
    required this.tipoId,
    required this.descricao,
    required this.valor,
    this.quantidade,
    this.valorTotalCp,
    this.dataEntrega,
    required this.status,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
    this.createdAt,
    this.updatedAt,
  });

  factory ContraPartidaModel.fromJson(Map<String, dynamic> json) {
    return ContraPartidaModel(
      id: json['id']?.toString() ?? '',
      projetoId: json['projeto']?.toString() ?? '',
      tipoId: json['tipo']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      valor: (json['valor'] ?? 0.0).toDouble(),
      quantidade: json['quantidade']?.toDouble(),
      valorTotalCp: json['valor_total_cp']?.toDouble(),
      dataEntrega: json['dataentrega'] != null
          ? DateTime.parse(json['dataentrega'].toString())
          : null,
      status: json['status']?.toString() ?? STATUS_PENDENTE,
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
      'projeto': projetoId,
      'tipo': tipoId,
      'descricao': descricao,
      'valor': valor,
      'quantidade': quantidade,
      'valor_total_cp': valorTotalCp,
      'dataentrega': dataEntrega?.toIso8601String(),
      'status': status,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  ContraPartidaModel copyWith({
    String? id,
    String? projetoId,
    String? tipoId,
    String? descricao,
    double? valor,
    double? quantidade,
    double? valorTotalCp,
    DateTime? dataEntrega,
    String? status,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContraPartidaModel(
      id: id ?? this.id,
      projetoId: projetoId ?? this.projetoId,
      tipoId: tipoId ?? this.tipoId,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      quantidade: quantidade ?? this.quantidade,
      valorTotalCp: valorTotalCp ?? this.valorTotalCp,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      status: status ?? this.status,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusLabel => statusLabels[status] ?? status;
}