import '../enums/documento_categoria_enum.dart';

/// Modelo para a tabela documento_tipo
class DocumentoTipo {
  final String? id;
  final String codigo;
  final String nome;
  final String? descricao;
  final DocumentoCategoria categoria;
  final bool obrigatorio;
  final bool validade_requerida;
  final int? prazo_validade_meses;
  final String extensoes_permitidas;
  final int tamanho_maximo_mb;
  final bool ativo;
  final String? atualizado_por;
  final DateTime? atualizado_em;
  final DateTime? created_at;

  DocumentoTipo({
    this.id,
    required this.codigo,
    required this.nome,
    this.descricao,
    required this.categoria,
    this.obrigatorio = false,
    this.validade_requerida = false,
    this.prazo_validade_meses,
    this.extensoes_permitidas = '.pdf,.jpg,.jpeg,.png',
    this.tamanho_maximo_mb = 10,
    this.ativo = true,
    this.atualizado_por,
    this.atualizado_em,
    this.created_at,
  });

  factory DocumentoTipo.fromJson(Map<String, dynamic> json) {
    return DocumentoTipo(
      id: json['id'],
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      categoria: DocumentoCategoria.fromString(json['categoria'] ?? 'outros'),
      obrigatorio: json['obrigatorio'] ?? false,
      validade_requerida: json['validade_requerida'] ?? false,
      prazo_validade_meses: json['prazo_validade_meses'],
      extensoes_permitidas: json['extensoes_permitidas'] ?? '.pdf,.jpg,.jpeg,.png',
      tamanho_maximo_mb: json['tamanho_maximo_mb'] ?? 10,
      ativo: json['ativo'] ?? true,
      atualizado_por: json['atualizado_por'],
      atualizado_em: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria.toJson(),
      'obrigatorio': obrigatorio,
      'validade_requerida': validade_requerida,
      'prazo_validade_meses': prazo_validade_meses,
      'extensoes_permitidas': extensoes_permitidas,
      'tamanho_maximo_mb': tamanho_maximo_mb,
      'ativo': ativo,
      'atualizado_por': atualizado_por,
      'atualizado_em': atualizado_em?.toIso8601String(),
      'created_at': created_at?.toIso8601String(),
    };
  }

  // ✅ Getters para formatação
  String get categoriaLabel => categoria.label;

  List<String> get extensoesList {
    return extensoes_permitidas.split(',').map((e) => e.trim()).toList();
  }

  String get extensoesFormatadas {
    return extensoesList.join(', ');
  }

  String get tamanhoFormatado {
    if (tamanho_maximo_mb >= 1024) {
      return '${(tamanho_maximo_mb / 1024).toStringAsFixed(1)} GB';
    }
    return '$tamanho_maximo_mb MB';
  }
}