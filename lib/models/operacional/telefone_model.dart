/// ============================================
/// MODELO: Telefone
/// ============================================
/// Representa um telefone vinculado a um contato
/// 
/// Tabela: telefone
/// Campos:
///   - id: UUID (PK)
///   - contato_id: UUID (FK para contato)
///   - uso: String (CORPORATIVO, PARTICULAR, COMUNITARIO)
///   - numero: String
///   - obs: Text
///   - atualizado_por: UUID (FK para Users)
///   - atualizado_em: DateTime
/// ============================================

class TelefoneModel {
  final String id;
  final String contatoId;
  final String uso;
  final String numero;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  static const Map<String, String> usoLabels = {
    'CORPORATIVO': 'Corporativo',
    'PARTICULAR': 'Particular',
    'COMUNITARIO': 'Comunitário',
  };

  TelefoneModel({
    required this.id,
    required this.contatoId,
    required this.uso,
    required this.numero,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory TelefoneModel.fromJson(Map<String, dynamic> json) {
    return TelefoneModel(
      id: json['id']?.toString() ?? '',
      contatoId: json['contato_id']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      numero: json['numero']?.toString() ?? '',
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
      'uso': uso,
      'numero': numero,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  TelefoneModel copyWith({
    String? id,
    String? contatoId,
    String? uso,
    String? numero,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
  }) {
    return TelefoneModel(
      id: id ?? this.id,
      contatoId: contatoId ?? this.contatoId,
      uso: uso ?? this.uso,
      numero: numero ?? this.numero,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  String get usoLabel => usoLabels[uso] ?? uso;

  /// Formata número de telefone (ex: (11) 99999-9999)
  String get numeroFormatado {
    final clean = numero.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '(${clean.substring(0,2)}) ${clean.substring(2,6)}-${clean.substring(6,10)}';
    } else if (clean.length == 11) {
      return '(${clean.substring(0,2)}) ${clean.substring(2,7)}-${clean.substring(7,11)}';
    }
    return numero;
  }
}
