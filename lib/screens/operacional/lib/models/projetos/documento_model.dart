/// ============================================
/// MODELO: Documento (Referência)
/// ============================================

class DocumentoModel {
  final String id;
  final String? tipoId;
  final String? empresaId;
  final String numero;
  final String? arquivo;
  final String? nomeOriginal;
  final String? descricao;
  final DateTime? dataEmissao;
  final DateTime? validoAte;
  final DateTime? prazoEntrega;
  final DateTime? dataApresentacao;
  final String status;
  final String? obs;
  final String? hashArquivo;
  final int? tamanhoBytes;
  final int? versao;
  final String? documentoAnteriorId;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  DocumentoModel({
    required this.id,
    this.tipoId,
    this.empresaId,
    required this.numero,
    this.arquivo,
    this.nomeOriginal,
    this.descricao,
    this.dataEmissao,
    this.validoAte,
    this.prazoEntrega,
    this.dataApresentacao,
    required this.status,
    this.obs,
    this.hashArquivo,
    this.tamanhoBytes,
    this.versao,
    this.documentoAnteriorId,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory DocumentoModel.fromJson(Map<String, dynamic> json) {
    return DocumentoModel(
      id: json['id']?.toString() ?? '',
      tipoId: json['tipo']?.toString(),
      empresaId: json['empresa']?.toString(),
      numero: json['numero']?.toString() ?? '',
      arquivo: json['arquivo']?.toString(),
      nomeOriginal: json['nome_original']?.toString(),
      descricao: json['descricao']?.toString(),
      dataEmissao: json['data_emissao'] != null
          ? DateTime.parse(json['data_emissao'].toString())
          : null,
      validoAte: json['valido_ate'] != null
          ? DateTime.parse(json['valido_ate'].toString())
          : null,
      prazoEntrega: json['prazo_entrega'] != null
          ? DateTime.parse(json['prazo_entrega'].toString())
          : null,
      dataApresentacao: json['data_apresentacao'] != null
          ? DateTime.parse(json['data_apresentacao'].toString())
          : null,
      status: json['status']?.toString() ?? 'RASCUNHO',
      obs: json['obs']?.toString(),
      hashArquivo: json['hash_arquivo']?.toString(),
      tamanhoBytes: json['tamanho_bytes'] as int?,
      versao: json['versao'] as int?,
      documentoAnteriorId: json['documento_anterior']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'].toString())
          : null,
    );
  }
}