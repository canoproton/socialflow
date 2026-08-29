class AlocacaoPesquisaFiltro {
  String? entidade;
  bool? comSaldo;
  String? projetoId;
  DateTime? dataInicio;
  DateTime? dataFim;

  AlocacaoPesquisaFiltro({
    this.entidade,
    this.comSaldo,
    this.projetoId,
    this.dataInicio,
    this.dataFim,
  });

  bool get hasFilters {
    return entidade != null ||
           comSaldo != null ||
           projetoId != null ||
           dataInicio != null ||
           dataFim != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'entidade': entidade,
      'comSaldo': comSaldo,
      'projetoId': projetoId,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
    };
  }
}