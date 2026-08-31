/// Enum para o campo status da tabela documento_shelter
enum DocumentoStatus {
  rascunho,
  pendente,
  aprovado,
  rejeitado,
  vencido,
  entregue,
  arquivado;

  String get label {
    switch (this) {
      case DocumentoStatus.rascunho:
        return 'Rascunho';
      case DocumentoStatus.pendente:
        return 'Pendente';
      case DocumentoStatus.aprovado:
        return 'Aprovado';
      case DocumentoStatus.rejeitado:
        return 'Rejeitado';
      case DocumentoStatus.vencido:
        return 'Vencido';
      case DocumentoStatus.entregue:
        return 'Entregue';
      case DocumentoStatus.arquivado:
        return 'Arquivado';
    }
  }

  static DocumentoStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'rascunho':
        return DocumentoStatus.rascunho;
      case 'pendente':
        return DocumentoStatus.pendente;
      case 'aprovado':
        return DocumentoStatus.aprovado;
      case 'rejeitado':
        return DocumentoStatus.rejeitado;
      case 'vencido':
        return DocumentoStatus.vencido;
      case 'entregue':
        return DocumentoStatus.entregue;
      case 'arquivado':
        return DocumentoStatus.arquivado;
      default:
        throw ArgumentError('Status de documento inválido: $value');
    }
  }

  String toJson() => name;

  /// ✅ CORRIGIDO: Usar lista fixa em vez de getter 'values'
  static const List<DocumentoStatus> allValues = [
    DocumentoStatus.rascunho,
    DocumentoStatus.pendente,
    DocumentoStatus.aprovado,
    DocumentoStatus.rejeitado,
    DocumentoStatus.vencido,
    DocumentoStatus.entregue,
    DocumentoStatus.arquivado,
  ];

  static List<Map<String, dynamic>> get dropdownItems {
    return allValues.map((e) => {
      'value': e.name,
      'label': e.label,
    }).toList();
  }
}