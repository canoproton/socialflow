/// Enum para o campo destino_tipo da tabela fontes_alocacao
enum DestinoTipo {
  projeto,
  rubrica;

  /// Nome amigável para exibição
  String get label {
    switch (this) {
      case DestinoTipo.projeto:
        return 'Projeto';
      case DestinoTipo.rubrica:
        return 'Rubrica';
    }
  }

  /// Nome da tabela referenciada
  String get tableName {
    switch (this) {
      case DestinoTipo.projeto:
        return 'projeto';
      case DestinoTipo.rubrica:
        return 'planocontas';
    }
  }

  /// Converte string para enum
  static DestinoTipo fromString(String value) {
    switch (value) {
      case 'projeto':
        return DestinoTipo.projeto;
      case 'rubrica':
        return DestinoTipo.rubrica;
      default:
        throw ArgumentError('Tipo de destino inválido: $value');
    }
  }

  /// Converte enum para string (para JSON/SQL)
  String toJson() => name;

  /// ✅ CORRIGIDO: Usar lista fixa em vez de getter 'values'
  static const List<DestinoTipo> allValues = [
    DestinoTipo.projeto,
    DestinoTipo.rubrica,
  ];

  /// Lista de opções com labels para dropdown
  static List<Map<String, dynamic>> get dropdownItems {
    return allValues.map((e) => {
      'value': e.name,
      'label': e.label,
    }).toList();
  }
}