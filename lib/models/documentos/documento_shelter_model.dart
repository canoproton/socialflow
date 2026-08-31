import '../enums/documento_status_enum.dart';

/// Modelo para a tabela documento_shelter
class DocumentoShelter {
  final String? id;
  final String dominio_tipo;  // 'projeto', 'rubrica', 'fontes_base', etc.
  final String dominio_id;
  final String tipo_id;  // ID do DocumentoTipo
  final String? numero;
  final String arquivo;  // Caminho do arquivo
  final String nome_original;
  final String? descricao;
  final DateTime? data_emissao;
  final DateTime? valido_ate;
  final DateTime? prazo_entrega;
  final DateTime? data_apresentacao;
  final DocumentoStatus status;
  final String? obs;
  final String? hash_arquivo;
  final int? tamanho_bytes;
  final int? versao;
  final String? documento_anterior_id;
  final String? atualizado_por;
  final DateTime? atualizado_em;
  final DateTime? created_at;

  // Propriedades para relacionamentos (carregados separadamente)
  DocumentoTipo? tipo;
  Map<String, dynamic>? dominio;

  DocumentoShelter({
    this.id,
    required this.dominio_tipo,
    required this.dominio_id,
    required this.tipo_id,
    this.numero,
    required this.arquivo,
    required this.nome_original,
    this.descricao,
    this.data_emissao,
    this.valido_ate,
    this.prazo_entrega,
    this.data_apresentacao,
    this.status = DocumentoStatus.rascunho,
    this.obs,
    this.hash_arquivo,
    this.tamanho_bytes,
    this.versao = 1,
    this.documento_anterior_id,
    this.atualizado_por,
    this.atualizado_em,
    this.created_at,
    this.tipo,
    this.dominio,
  });

  factory DocumentoShelter.fromJson(Map<String, dynamic> json) {
    return DocumentoShelter(
      id: json['id'],
      dominio_tipo: json['dominio_tipo'] ?? '',
      dominio_id: json['dominio_id'] ?? '',
      tipo_id: json['tipo_id'] ?? '',
      numero: json['numero'],
      arquivo: json['arquivo'] ?? '',
      nome_original: json['nome_original'] ?? '',
      descricao: json['descricao'],
      data_emissao: json['data_emissao'] != null
          ? DateTime.parse(json['data_emissao'])
          : null,
      valido_ate: json['valido_ate'] != null
          ? DateTime.parse(json['valido_ate'])
          : null,
      prazo_entrega: json['prazo_entrega'] != null
          ? DateTime.parse(json['prazo_entrega'])
          : null,
      data_apresentacao: json['data_apresentacao'] != null
          ? DateTime.parse(json['data_apresentacao'])
          : null,
      status: DocumentoStatus.fromString(json['status'] ?? 'rascunho'),
      obs: json['obs'],
      hash_arquivo: json['hash_arquivo'],
      tamanho_bytes: json['tamanho_bytes'],
      versao: json['versao'] ?? 1,
      documento_anterior_id: json['documento_anterior_id'],
      atualizado_por: json['atualizado_por'],
      atualizado_em: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      tipo: json['tipo'] != null
          ? DocumentoTipo.fromJson(json['tipo'] as Map<String, dynamic>)
          : null,
      dominio: json['dominio'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dominio_tipo': dominio_tipo,
      'dominio_id': dominio_id,
      'tipo_id': tipo_id,
      'numero': numero,
      'arquivo': arquivo,
      'nome_original': nome_original,
      'descricao': descricao,
      'data_emissao': data_emissao?.toIso8601String(),
      'valido_ate': valido_ate?.toIso8601String(),
      'prazo_entrega': prazo_entrega?.toIso8601String(),
      'data_apresentacao': data_apresentacao?.toIso8601String(),
      'status': status.toJson(),
      'obs': obs,
      'hash_arquivo': hash_arquivo,
      'tamanho_bytes': tamanho_bytes,
      'versao': versao,
      'documento_anterior_id': documento_anterior_id,
      'atualizado_por': atualizado_por,
      'atualizado_em': atualizado_em?.toIso8601String(),
      'created_at': created_at?.toIso8601String(),
    };
  }

  // ✅ Getters para formatação
  String get statusLabel => status.label;

  String get tamanhoFormatado {
    if (tamanho_bytes == null) return '0 B';
    final bytes = tamanho_bytes!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  String get dataEmissaoFormatada {
    if (data_emissao == null) return '';
    final d = data_emissao!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}