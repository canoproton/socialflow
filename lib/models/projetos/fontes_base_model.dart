/// ============================================
/// MODELO: FontesBase (Fonte de Recurso)
/// REGRA 7
/// ============================================

class FontesBaseModel {
  final String id;
  final String descricao;
  final String entidade;
  final double valorRecurso;
  final double? remanejamento;
  final DateTime? dataAprovacao;
  final String? obs;
  final List<String>? docsRecursos;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ⭐ CAMPOS CALCULADOS (NÃO VÊM DO BANCO)
  double _totalAlocado = 0;
  double _saldo = 0;

  FontesBaseModel({
    required this.id,
    required this.descricao,
    required this.entidade,
    required this.valorRecurso,
    this.remanejamento,
    this.dataAprovacao,
    this.obs,
    this.docsRecursos,
    this.atualizadoPor,
    this.atualizadoEm,
    this.createdAt,
    this.updatedAt,
  });

  factory FontesBaseModel.fromJson(Map<String, dynamic> json) {
    return FontesBaseModel(
      id: json['id']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      entidade: json['entidade']?.toString() ?? '',
      valorRecurso: (json['valor_recurso'] ?? 0.0).toDouble(),
      remanejamento: json['remanejamento']?.toDouble(),
      dataAprovacao: json['data_aprovacao'] != null
          ? DateTime.parse(json['data_aprovacao'].toString())
          : null,
      obs: json['obs']?.toString(),
      docsRecursos: json['docs_recursos'] != null
          ? List<String>.from(json['docs_recursos'])
          : null,
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
      'entidade': entidade,
      'valor_recurso': valorRecurso,
      'remanejamento': remanejamento,
      'data_aprovacao': dataAprovacao?.toIso8601String(),
      'obs': obs,
      'docs_recursos': docsRecursos,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  FontesBaseModel copyWith({
    String? id,
    String? descricao,
    String? entidade,
    double? valorRecurso,
    double? remanejamento,
    DateTime? dataAprovacao,
    String? obs,
    List<String>? docsRecursos,
    String? atualizadoPor,
    DateTime? atualizadoEm,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalAlocado,
    double? saldo,
  }) {
    final newModel = FontesBaseModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      entidade: entidade ?? this.entidade,
      valorRecurso: valorRecurso ?? this.valorRecurso,
      remanejamento: remanejamento ?? this.remanejamento,
      dataAprovacao: dataAprovacao ?? this.dataAprovacao,
      obs: obs ?? this.obs,
      docsRecursos: docsRecursos ?? this.docsRecursos,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    newModel._totalAlocado = totalAlocado ?? this._totalAlocado;
    newModel._saldo = saldo ?? this._saldo;
    return newModel;
  }

  // ⭐ GETTERS PARA CAMPOS CALCULADOS
  double get totalAlocado => _totalAlocado;
  double get saldo => _saldo;

  // ⭐ MÉTODO PARA ATUALIZAR CAMPOS CALCULADOS
  void atualizarTotais(double totalAlocado) {
    _totalAlocado = totalAlocado;
    _saldo = valorRecurso - totalAlocado;
  }

  // ⭐ PERCENTUAL ALOCADO
  double get percentualAlocado {
    if (valorRecurso == 0) return 0;
    return (_totalAlocado / valorRecurso) * 100;
  }

  // ⭐ PERCENTUAL DISPONÍVEL
  double get percentualDisponivel {
    if (valorRecurso == 0) return 0;
    return ((valorRecurso - _totalAlocado) / valorRecurso) * 100;
  }
}