/// ============================================
/// MODELO: Midias
/// ============================================

class MidiasModel {
  final String id;
  final String contatoId;
  final String uso;
  final String tipo;
  final String? nomeDoApp;
  final String descricao;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  static const Map<String, String> usoLabels = {
    'CORPORATIVO': 'Corporativo',
    'PARTICULAR': 'Particular',
    'COMUNITARIO': 'Comunitário',
  };

  static const Map<String, String> tipoLabels = {
    'APLICATIVO': 'Aplicativo',
    'SITE': 'Site',
    'MENSAGERIA': 'Mensageria',
  };

  static const List<String> appsComuns = [
    'WhatsApp', 'LinkedIn', 'Instagram', 'Facebook',
    'Twitter', 'YouTube', 'TikTok', 'Telegram',
    'Signal', 'Discord', 'Slack', 'Teams',
  ];

  MidiasModel({
    required this.id,
    required this.contatoId,
    required this.uso,
    required this.tipo,
    this.nomeDoApp,
    required this.descricao,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory MidiasModel.fromJson(Map<String, dynamic> json) {
    return MidiasModel(
      id: json['id']?.toString() ?? '',
      contatoId: json['contato_id']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      tipo: json['tipo']?.toString() ?? 'APLICATIVO',
      nomeDoApp: json['nome_do_app']?.toString(),
      descricao: json['descricao']?.toString() ?? '',
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
      'tipo': tipo,
      'nome_do_app': nomeDoApp,
      'descricao': descricao,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  MidiasModel copyWith({
    String? id,
    String? contatoId,
    String? uso,
    String? tipo,
    String? nomeDoApp,
    String? descricao,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
  }) {
    return MidiasModel(
      id: id ?? this.id,
      contatoId: contatoId ?? this.contatoId,
      uso: uso ?? this.uso,
      tipo: tipo ?? this.tipo,
      nomeDoApp: nomeDoApp ?? this.nomeDoApp,
      descricao: descricao ?? this.descricao,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  String get usoLabel => usoLabels[uso] ?? uso;
  String get tipoLabel => tipoLabels[tipo] ?? tipo;
}
