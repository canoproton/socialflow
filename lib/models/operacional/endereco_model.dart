/// ============================================
/// MODELO: Endereco
/// ============================================
/// Representa um endereço vinculado a um contato
/// 
/// Tabela: endereco
/// Campos:
///   - id: UUID (PK)
///   - contato_id: UUID (FK para contato)
///   - logradouro: String
///   - bairro: String
///   - cidade: String
///   - estado: String (UF)
///   - cep: String
///   - obs: Text
///   - atualizado_por: UUID (FK para Users)
///   - atualizado_em: DateTime
/// ============================================

class EnderecoModel {
  final String id;
  final String contatoId;
  final String logradouro;
  final String? bairro;
  final String cidade;
  final String estado;
  final String? cep;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  // Lista de estados brasileiros
  static const Map<String, String> estados = {
    'AC': 'Acre',
    'AL': 'Alagoas',
    'AP': 'Amapá',
    'AM': 'Amazonas',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'DF': 'Distrito Federal',
    'ES': 'Espírito Santo',
    'GO': 'Goiás',
    'MA': 'Maranhão',
    'MT': 'Mato Grosso',
    'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais',
    'PA': 'Pará',
    'PB': 'Paraíba',
    'PR': 'Paraná',
    'PE': 'Pernambuco',
    'PI': 'Piauí',
    'RJ': 'Rio de Janeiro',
    'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul',
    'RO': 'Rondônia',
    'RR': 'Roraima',
    'SC': 'Santa Catarina',
    'SP': 'São Paulo',
    'SE': 'Sergipe',
    'TO': 'Tocantins',
  };

  EnderecoModel({
    required this.id,
    required this.contatoId,
    required this.logradouro,
    this.bairro,
    required this.cidade,
    required this.estado,
    this.cep,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
      id: json['id']?.toString() ?? '',
      contatoId: json['contato_id']?.toString() ?? '',
      logradouro: json['logradouro']?.toString() ?? '',
      bairro: json['bairro']?.toString(),
      cidade: json['cidade']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      cep: json['cep']?.toString(),
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contato_id': contatoId,
      'logradouro': logradouro,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  EnderecoModel copyWith({
    String? id,
    String? contatoId,
    String? logradouro,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
  }) {
    return EnderecoModel(
      id: id ?? this.id,
      contatoId: contatoId ?? this.contatoId,
      logradouro: logradouro ?? this.logradouro,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  /// Retorna o nome completo do estado
  String get nomeEstado => estados[estado] ?? estado;

  /// Retorna o endereço completo formatado
  String get enderecoCompleto {
    String completo = logradouro;
    if (bairro != null && bairro!.isNotEmpty) {
      completo += ', $bairro';
    }
    completo += ' - $cidade, $estado';
    if (cep != null && cep!.isNotEmpty) {
      completo += ' - CEP: $cep';
    }
    return completo;
  }
}
