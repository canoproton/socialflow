/// ============================================
/// MODELO: Empresa (COMPLETO)
/// ============================================

import 'contato_model.dart';
import 'telefone_model.dart';
import 'email_model.dart';
import 'endereco_model.dart';
import 'midias_model.dart';

class EmpresaModel {
  final String id;
  final String nome;
  final String qualif;
  final String razaoSocial;
  final String tipoContr;
  final String? cnpj;
  final String? ie;
  final String? contatoPrincipalId;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // ⭐ RELACIONAMENTOS
  List<ContatoModel> contatos;
  List<TelefoneModel> telefones;
  List<EmailModel> emails;
  List<EnderecoModel> enderecos;
  List<MidiasModel> midias;

  static const Map<String, String> qualifLabels = {
    'INTERNA': 'Interna',
    'COLIGADA': 'Coligada',
    'OPERACIONAL': 'Operacional',
    'PESSOA_FISICA': 'Pessoa Física',
    'FORNECEDOR': 'Fornecedor',
  };

  static const Map<String, String> tipoContrLabels = {
    'RPA': 'RPA',
    'CNPJ': 'CNPJ',
    'MEI': 'MEI',
    'ADH': 'Ad-Hoc',
  };

  EmpresaModel({
    required this.id,
    required this.nome,
    required this.qualif,
    required this.razaoSocial,
    required this.tipoContr,
    this.cnpj,
    this.ie,
    this.contatoPrincipalId,
    this.obs,
    this.atualizadoPor,
    this.createdAt,
    this.updatedAt,
    this.contatos = const [],
    this.telefones = const [],
    this.emails = const [],
    this.enderecos = const [],
    this.midias = const [],
  });

  factory EmpresaModel.fromJson(Map<String, dynamic> json) {
    return EmpresaModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      qualif: json['qualif']?.toString() ?? 'FORNECEDOR',
      razaoSocial: json['razao_social']?.toString() ?? '',
      tipoContr: json['tipo_contr']?.toString() ?? 'CNPJ',
      cnpj: json['cnpj']?.toString(),
      ie: json['ie']?.toString(),
      contatoPrincipalId: json['contato_principal']?.toString(),
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
      'qualif': qualif,
      'razao_social': razaoSocial,
      'tipo_contr': tipoContr,
      'cnpj': cnpj,
      'ie': ie,
      'contato_principal': contatoPrincipalId,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  EmpresaModel copyWith({
    String? id,
    String? nome,
    String? qualif,
    String? razaoSocial,
    String? tipoContr,
    String? cnpj,
    String? ie,
    String? contatoPrincipalId,
    String? obs,
    String? atualizadoPor,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ContatoModel>? contatos,
    List<TelefoneModel>? telefones,
    List<EmailModel>? emails,
    List<EnderecoModel>? enderecos,
    List<MidiasModel>? midias,
  }) {
    return EmpresaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      qualif: qualif ?? this.qualif,
      razaoSocial: razaoSocial ?? this.razaoSocial,
      tipoContr: tipoContr ?? this.tipoContr,
      cnpj: cnpj ?? this.cnpj,
      ie: ie ?? this.ie,
      contatoPrincipalId: contatoPrincipalId ?? this.contatoPrincipalId,
      obs: obs ?? this.obs,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contatos: contatos ?? this.contatos,
      telefones: telefones ?? this.telefones,
      emails: emails ?? this.emails,
      enderecos: enderecos ?? this.enderecos,
      midias: midias ?? this.midias,
    );
  }

  String get qualifLabel {
    return qualifLabels[qualif] ?? qualif;
  }

  String get tipoContrLabel {
    return tipoContrLabels[tipoContr] ?? tipoContr;
  }

  String get cnpjFormatado {
    if (cnpj == null || cnpj!.length != 14) return cnpj ?? '';
    return '${cnpj!.substring(0,2)}.${cnpj!.substring(2,5)}.${cnpj!.substring(5,8)}/${cnpj!.substring(8,12)}-${cnpj!.substring(12,14)}';
  }

  String get initials {
    final names = nome.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return nome.substring(0, 2).toUpperCase();
  }
}
