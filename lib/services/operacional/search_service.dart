/// ============================================
/// SERVIÇO: Pesquisa Avançada
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/empresa_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';

class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ContatoModel>> searchContatos({
    String? query,
    String? tipoVinculo,
    String? cidade,
    String? estado,
  }) async {
    try {
      var queryBuilder = _supabase.from('contato').select();
      
      if (tipoVinculo != null && tipoVinculo.isNotEmpty) {
        queryBuilder = queryBuilder.eq('tipo_vinculo', tipoVinculo);
      }

      final response = await queryBuilder;
      List<ContatoModel> contatos = (response as List)
          .map((item) => ContatoModel.fromJson(item))
          .toList();

      // Buscar relacionamentos
      for (var i = 0; i < contatos.length; i++) {
        final telefones = await _getTelefones(contatos[i].id);
        final emails = await _getEmails(contatos[i].id);
        final enderecos = await _getEnderecos(contatos[i].id);
        final midias = await _getMidias(contatos[i].id);
        
        contatos[i] = contatos[i].copyWith(
          telefones: telefones,
          emails: emails,
          enderecos: enderecos,
          midias: midias,
        );
      }

      // Aplicar filtros de pesquisa
      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        contatos = contatos.where((contato) {
          if (contato.nome.toLowerCase().contains(searchLower)) return true;
          if (contato.cpf != null && contato.cpf!.contains(searchLower)) return true;
          
          for (var tel in contato.telefones) {
            if (tel.numero.contains(searchLower)) return true;
          }
          for (var email in contato.emails) {
            if (email.endereco.toLowerCase().contains(searchLower)) return true;
          }
          for (var end in contato.enderecos) {
            if (end.logradouro.toLowerCase().contains(searchLower)) return true;
            if (end.bairro != null && end.bairro!.toLowerCase().contains(searchLower)) return true;
            if (end.cidade.toLowerCase().contains(searchLower)) return true;
            if (end.cep != null && end.cep!.contains(searchLower)) return true;
          }
          for (var midia in contato.midias) {
            if (midia.descricao.toLowerCase().contains(searchLower)) return true;
            if (midia.nomeDoApp != null && midia.nomeDoApp!.toLowerCase().contains(searchLower)) return true;
          }
          return false;
        }).toList();
      }

      if (cidade != null && cidade.isNotEmpty) {
        contatos = contatos.where((contato) {
          return contato.enderecos.any((end) => 
            end.cidade.toLowerCase().contains(cidade.toLowerCase())
          );
        }).toList();
      }

      if (estado != null && estado.isNotEmpty) {
        contatos = contatos.where((contato) {
          return contato.enderecos.any((end) => 
            end.estado.toUpperCase() == estado.toUpperCase()
          );
        }).toList();
      }

      return contatos;
    } catch (e) {
      throw Exception('Erro ao pesquisar contatos: $e');
    }
  }

  Future<List<EmpresaModel>> searchEmpresas({
    String? query,
    String? qualif,
    String? cidade,
    String? estado,
  }) async {
    try {
      var queryBuilder = _supabase.from('empresa').select();
      
      if (qualif != null && qualif.isNotEmpty) {
        queryBuilder = queryBuilder.eq('qualif', qualif);
      }

      final response = await queryBuilder;
      List<EmpresaModel> empresas = (response as List)
          .map((item) => EmpresaModel.fromJson(item))
          .toList();

      // Buscar relacionamentos
      for (var i = 0; i < empresas.length; i++) {
        final contatos = await _getContatosDaEmpresa(empresas[i].id);
        final telefones = await _getTelefonesEmpresa(empresas[i].id);
        final emails = await _getEmailsEmpresa(empresas[i].id);
        final enderecos = await _getEnderecosEmpresa(empresas[i].id);
        final midias = await _getMidiasEmpresa(empresas[i].id);
        
        empresas[i] = empresas[i].copyWith(
          contatos: contatos,
          telefones: telefones,
          emails: emails,
          enderecos: enderecos,
          midias: midias,
        );
      }

      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        empresas = empresas.where((empresa) {
          if (empresa.nome.toLowerCase().contains(searchLower)) return true;
          if (empresa.razaoSocial.toLowerCase().contains(searchLower)) return true;
          if (empresa.cnpj != null && empresa.cnpj!.contains(searchLower)) return true;
          
          for (var contato in empresa.contatos) {
            if (contato.nome.toLowerCase().contains(searchLower)) return true;
          }
          for (var tel in empresa.telefones) {
            if (tel.numero.contains(searchLower)) return true;
          }
          for (var email in empresa.emails) {
            if (email.endereco.toLowerCase().contains(searchLower)) return true;
          }
          for (var end in empresa.enderecos) {
            if (end.logradouro.toLowerCase().contains(searchLower)) return true;
            if (end.cidade.toLowerCase().contains(searchLower)) return true;
            if (end.cep != null && end.cep!.contains(searchLower)) return true;
          }
          for (var midia in empresa.midias) {
            if (midia.descricao.toLowerCase().contains(searchLower)) return true;
            if (midia.nomeDoApp != null && midia.nomeDoApp!.toLowerCase().contains(searchLower)) return true;
          }
          return false;
        }).toList();
      }

      if (cidade != null && cidade.isNotEmpty) {
        empresas = empresas.where((empresa) {
          return empresa.enderecos.any((end) => 
            end.cidade.toLowerCase().contains(cidade.toLowerCase())
          );
        }).toList();
      }

      if (estado != null && estado.isNotEmpty) {
        empresas = empresas.where((empresa) {
          return empresa.enderecos.any((end) => 
            end.estado.toUpperCase() == estado.toUpperCase()
          );
        }).toList();
      }

      return empresas;
    } catch (e) {
      throw Exception('Erro ao pesquisar empresas: $e');
    }
  }

  // ============================================
  // MÉTODOS AUXILIARES
  // ============================================

  Future<List<TelefoneModel>> _getTelefones(String contatoId) async {
    try {
      final response = await _supabase
          .from('telefone')
          .select()
          .eq('contato_id', contatoId);
      return (response as List)
          .map((item) => TelefoneModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<EmailModel>> _getEmails(String contatoId) async {
    try {
      final response = await _supabase
          .from('email')
          .select()
          .eq('contato_id', contatoId);
      // ⭐ REMOVIDO emailComm
      return (response as List)
          .map((item) => EmailModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<EnderecoModel>> _getEnderecos(String contatoId) async {
    try {
      final response = await _supabase
          .from('endereco')
          .select()
          .eq('contato_id', contatoId);
      return (response as List)
          .map((item) => EnderecoModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<MidiasModel>> _getMidias(String contatoId) async {
    try {
      final response = await _supabase
          .from('midias')
          .select()
          .eq('contato_id', contatoId);
      return (response as List)
          .map((item) => MidiasModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ContatoModel>> _getContatosDaEmpresa(String empresaId) async {
    try {
      final response = await _supabase
          .from('empresa_contato')
          .select('contato_id')
          .eq('empresa_id', empresaId);
      
      if (response.isEmpty) return [];
      
      final contatoIds = (response as List)
          .map((item) => item['contato_id'].toString())
          .toList();
      
      List<ContatoModel> contatos = [];
      for (var id in contatoIds) {
        final result = await _supabase
            .from('contato')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (result != null) {
          contatos.add(ContatoModel.fromJson(result));
        }
      }
      return contatos;
    } catch (e) {
      return [];
    }
  }

  Future<List<TelefoneModel>> _getTelefonesEmpresa(String empresaId) async {
    final contatos = await _getContatosDaEmpresa(empresaId);
    List<TelefoneModel> todos = [];
    for (var contato in contatos) {
      todos.addAll(await _getTelefones(contato.id));
    }
    return todos;
  }

  Future<List<EmailModel>> _getEmailsEmpresa(String empresaId) async {
    final contatos = await _getContatosDaEmpresa(empresaId);
    List<EmailModel> todos = [];
    for (var contato in contatos) {
      todos.addAll(await _getEmails(contato.id));
    }
    return todos;
  }

  Future<List<EnderecoModel>> _getEnderecosEmpresa(String empresaId) async {
    final contatos = await _getContatosDaEmpresa(empresaId);
    List<EnderecoModel> todos = [];
    for (var contato in contatos) {
      todos.addAll(await _getEnderecos(contato.id));
    }
    return todos;
  }

  Future<List<MidiasModel>> _getMidiasEmpresa(String empresaId) async {
    final contatos = await _getContatosDaEmpresa(empresaId);
    List<MidiasModel> todos = [];
    for (var contato in contatos) {
      todos.addAll(await _getMidias(contato.id));
    }
    return todos;
  }
}
