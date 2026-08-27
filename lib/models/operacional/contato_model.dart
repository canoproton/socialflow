/// ============================================
/// MODELO: Contato
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
  final String? cpf;
  final String? rg;
  final String? genero;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ⭐ RELACIONAMENTOS
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
    this.cpf,
    this.rg,
    this.genero,
    this.obs,
    this.atualizadoPor,
    this.createdAt,
    this.updatedAt,
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
      cpf: json['cpf']?.toString(),
      rg: json['rg']?.toString(),
      genero: json['genero']?.toString(),
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo_vinculo': tipoVinculo,
      'funcao_id': funcaoId,
      'cpf': cpf,
      'rg': rg,
      'genero': genero,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ContatoModel copyWith({
    String? id,
    String? nome,
    String? tipoVinculo,
    String? funcaoId,
    String? cpf,
    String? rg,
    String? genero,
    String? obs,
    String? atualizadoPor,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      cpf: cpf ?? this.cpf,
      rg: rg ?? this.rg,
      genero: genero ?? this.genero,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      telefones: telefones ?? this.telefones,
      emails: emails ?? this.emails,
      enderecos: enderecos ?? this.enderecos,
      midias: midias ?? this.midias,
    );
  }

  String get tipoVinculoLabel => tipoVinculoLabels[tipoVinculo] ?? tipoVinculo;
  String get generoLabel => generoLabels[genero ?? ''] ?? genero ?? '';
  String get initials => nome.isNotEmpty ? nome[0].toUpperCase() : 'C';
}