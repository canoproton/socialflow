/// Enum para o campo categoria da tabela documento_tipo
enum DocumentoCategoria {
  fiscal,
  edital,
  contraPartida,
  contratual,
  social,
  financeiro,
  tecnico,
  administrativo,
  projeto,
  outros;

  String get label {
    switch (this) {
      case DocumentoCategoria.fiscal:
        return 'Documento Fiscal/Tributário';
      case DocumentoCategoria.edital:
        return 'Exigências de Edital';
      case DocumentoCategoria.contraPartida:
        return 'Contra Partida';
      case DocumentoCategoria.contratual:
        return 'Documento Contratual';
      case DocumentoCategoria.social:
        return 'Documento Societário';
      case DocumentoCategoria.financeiro:
        return 'Documento Financeiro';
      case DocumentoCategoria.tecnico:
        return 'Documento Técnico';
      case DocumentoCategoria.administrativo:
        return 'Documento Administrativo';
      case DocumentoCategoria.projeto:
        return 'Documento de Projeto';
      case DocumentoCategoria.outros:
        return 'Outros Documentos';
    }
  }

  static DocumentoCategoria fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fiscal':
        return DocumentoCategoria.fiscal;
      case 'edital':
        return DocumentoCategoria.edital;
      case 'contra partida':
        return DocumentoCategoria.contraPartida;
      case 'contratual':
        return DocumentoCategoria.contratual;
      case 'social':
        return DocumentoCategoria.social;
      case 'financeiro':
        return DocumentoCategoria.financeiro;
      case 'tecnico':
        return DocumentoCategoria.tecnico;
      case 'administrativo':
        return DocumentoCategoria.administrativo;
      case 'projeto':
        return DocumentoCategoria.projeto;
      case 'outros':
        return DocumentoCategoria.outros;
      default:
        throw ArgumentError('Categoria de documento inválida: $value');
    }
  }

  String toJson() => name;

  /// ✅ CORRIGIDO: Usar lista fixa em vez de getter 'values'
  static const List<DocumentoCategoria> allValues = [
    DocumentoCategoria.fiscal,
    DocumentoCategoria.edital,
    DocumentoCategoria.contraPartida,
    DocumentoCategoria.contratual,
    DocumentoCategoria.social,
    DocumentoCategoria.financeiro,
    DocumentoCategoria.tecnico,
    DocumentoCategoria.administrativo,
    DocumentoCategoria.projeto,
    DocumentoCategoria.outros,
  ];

  static List<Map<String, dynamic>> get dropdownItems {
    return allValues.map((e) => {
      'value': e.name,
      'label': e.label,
    }).toList();
  }
}