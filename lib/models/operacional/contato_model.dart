/// ============================================
/// MODELO: Contato (COMPLETO)
/// ============================================

import 'telefone_model.dart';
import 'email_model.dart';
import 'endereco_model.dart';
import 'midias_model.dart';

class ContatoModel {
  final String id;
  final String nome;
  final String tipoVinculo;
  final String? funcaoId;
  final String? empresaId;
  final String? cpf;
  final String? rg;
  final String? genero;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? createdAt;
  final DateTime? atualizadoEm;
  
  // Relacionamentos
  List<TelefoneModel> telefones;
  List<EmailModel> emails;
  List<EnderecoModel> enderecos;
  List<MidiasModel> midias;

  static const Map<String, String> tipoVinculoLabels = {
    'BANCO': 'Banco',
    'INTERNO': 'Interno',
    'EXTERNO': 'Externo',
    'EMPRESA': 'Empresa',
    'PATROCINADOR': 'Patrocinador',
    'OPERACIONAL': 'Operacional',
    'VARIOS': 'Vários',
  };

  static const Map<String, String> generoLabels = {
    'FEMININO': 'Feminino',
    'MASCULINO': 'Masculino',
    'OUTROS': 'Outros',
  };

  ContatoModel({
    required this.id,
    required this.nome,
    required this.tipoVinculo,
    this.funcaoId,
    this.empresaId,
    this.cpf,
    this.rg,
    this.genero,
    this.obs,
    this.atualizadoPor,
    this.createdAt,
    this.atualizadoEm,
    this.telefones = const [],
    this.emails = const [],
    this.enderecos = const [],
    this.midias = const [],
  });

  factory ContatoModel.fromJson(Map<String, dynamic> json) {
    return ContatoModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      tipoVinculo: json['tipo_vinculo']?.toString() ?? 'EXTERNO',
      funcaoId: json['funcao_id']?.toString(),
      empresaId: json['empresa_id']?.toString(),
      cpf: json['cpf']?.toString(),
      rg: json['rg']?.toString(),
      genero: json['genero']?.toString(),
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : null,
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo_vinculo': tipoVinculo,
      'funcao_id': funcaoId,
      'empresa_id': empresaId,
      'cpf': cpf,
      'rg': rg,
      'genero': genero,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'created_at': createdAt?.toIso8601String(),
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  ContatoModel copyWith({
    String? id,
    String? nome,
    String? tipoVinculo,
    String? funcaoId,
    String? empresaId,
    String? cpf,
    String? rg,
    String? genero,
    String? obs,
    String? atualizadoPor,
    DateTime? createdAt,
    DateTime? atualizadoEm,
    List<TelefoneModel>? telefones,
    List<EmailModel>? emails,
    List<EnderecoModel>? enderecos,
    List<MidiasModel>? midias,
  }) {
    return ContatoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipoVinculo: tipoVinculo ?? this.tipoVinculo,
      funcaoId: funcaoId ?? this.funcaoId,
      empresaId: empresaId ?? this.empresaId,
      cpf: cpf ?? this.cpf,
      rg: rg ?? this.rg,
      genero: genero ?? this.genero,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      createdAt: createdAt ?? this.createdAt,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      telefones: telefones ?? this.telefones,
      emails: emails ?? this.emails,
      enderecos: enderecos ?? this.enderecos,
      midias: midias ?? this.midias,
    );
  }

  String get tipoVinculoLabel {
    return tipoVinculoLabels[tipoVinculo] ?? tipoVinculo;
  }

  String get generoLabel {
    return generoLabels[genero ?? ''] ?? genero ?? '';
  }

  String get cpfFormatado {
    if (cpf == null || cpf!.length != 11) return cpf ?? '';
    return '${cpf!.substring(0,3)}.${cpf!.substring(3,6)}.${cpf!.substring(6,9)}-${cpf!.substring(9,11)}';
  }

  String get initials {
    final names = nome.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return nome.substring(0, 2).toUpperCase();
  }
}
