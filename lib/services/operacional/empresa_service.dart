/// ============================================
/// SERVIÇO: Empresa
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/empresa_model.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';

class EmpresaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // CRUD PRINCIPAL
  // ============================================

  Future<List<EmpresaModel>> list() async {
    try {
      final response = await _supabase
          .from('empresa')
          .select()
          .order('nome', ascending: true);
      
      return (response as List)
          .map((item) => EmpresaModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar empresas: $e');
    }
  }

  Future<EmpresaModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('empresa')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return EmpresaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar empresa: $e');
    }
  }

  Future<EmpresaModel> create(Map<String, dynamic> data) async {
    try {
      // Criar contato principal
      final contatoData = {
        'nome': data['nome'],
        'tipo_vinculo': 'EMPRESA',
      };
      
      final contatoResponse = await _supabase
          .from('contato')
          .insert(contatoData)
          .select()
          .single();
      
      data['contato_principal'] = contatoResponse['id'];
      
      final response = await _supabase
          .from('empresa')
          .insert(data)
          .select()
          .single();
      
      return EmpresaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar empresa: $e');
    }
  }

  Future<EmpresaModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('empresa')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return EmpresaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar empresa: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      final empresa = await getById(id);
      
      await _supabase
          .from('empresa')
          .delete()
          .eq('id', id);
      
      if (empresa != null && empresa.contatoPrincipalId != null) {
        await _supabase
            .from('contato')
            .delete()
            .eq('id', empresa.contatoPrincipalId!);
      }
    } catch (e) {
      throw Exception('Erro ao deletar empresa: $e');
    }
  }

  // ============================================
  // BUSCAR POR CNPJ
  // ============================================

  Future<EmpresaModel?> findByCnpj(String cnpj) async {
    try {
      final cleanCnpj = cnpj.replaceAll(RegExp(r'\D'), '');
      if (cleanCnpj.isEmpty) return null;
      
      final response = await _supabase
          .from('empresa')
          .select()
          .eq('cnpj', cleanCnpj)
          .maybeSingle();
      
      if (response == null) return null;
      return EmpresaModel.fromJson(response);
    } catch (e) {
      print('Erro ao buscar por CNPJ: $e');
      return null;
    }
  }

  // ============================================
  // SALVAR RELACIONAMENTOS
  // ============================================

  Future<void> saveRelacionamentos(
    String empresaId, {
    List contatos = const [],
    List telefones = const [],
    List emails = const [],
    List enderecos = const [],
    List midias = const [],
  }) async {
    print('=== SALVANDO RELACIONAMENTOS DA EMPRESA ===');
    
    final empresa = await getById(empresaId);
    if (empresa == null || empresa.contatoPrincipalId == null) {
      print('❌ Empresa sem contato principal');
      return;
    }
    
    final contatoPrincipalId = empresa.contatoPrincipalId!;
    print('✅ Contato principal: $contatoPrincipalId');
    
    // Telefones
    await _supabase
        .from('telefone')
        .delete()
        .eq('contato_id', contatoPrincipalId);
    
    for (var telefone in telefones) {
      if (telefone.numero.isNotEmpty) {
        await _supabase
            .from('telefone')
            .insert({
              'contato_id': contatoPrincipalId,
              'uso': telefone.uso,
              'numero': telefone.numero,
              'obs': telefone.obs,
            });
      }
    }
    
    // Emails
    await _supabase
        .from('email')
        .delete()
        .eq('contato_id', contatoPrincipalId);
    
    for (var email in emails) {
      if (email.endereco.isNotEmpty) {
        await _supabase
            .from('email')
            .insert({
              'contato_id': contatoPrincipalId,
              'uso': email.uso,
              'endereco': email.endereco,
              'obs': email.obs,
            });
      }
    }
    
    // Endereços
    await _supabase
        .from('endereco')
        .delete()
        .eq('contato_id', contatoPrincipalId);
    
    for (var endereco in enderecos) {
      if (endereco.logradouro.isNotEmpty) {
        await _supabase
            .from('endereco')
            .insert({
              'contato_id': contatoPrincipalId,
              'logradouro': endereco.logradouro,
              'bairro': endereco.bairro,
              'cidade': endereco.cidade,
              'estado': endereco.estado,
              'cep': endereco.cep,
              'obs': endereco.obs,
            });
      }
    }
    
    // Mídias
    await _supabase
        .from('midias')
        .delete()
        .eq('contato_id', contatoPrincipalId);
    
    for (var midia in midias) {
      if (midia.descricao.isNotEmpty) {
        await _supabase
            .from('midias')
            .insert({
              'contato_id': contatoPrincipalId,
              'uso': midia.uso,
              'tipo': midia.tipo,
              'nome_do_app': midia.nomeDoApp,
              'descricao': midia.descricao,
              'obs': midia.obs,
            });
      }
    }
    
    // Contatos vinculados
    await _supabase
        .from('empresa_contato')
        .delete()
        .eq('empresa_id', empresaId);
    
    for (var contato in contatos) {
      if (contato.id.isNotEmpty) {
        await _supabase
            .from('empresa_contato')
            .insert({
              'empresa_id': empresaId,
              'contato_id': contato.id,
            });
      }
    }
    
    print('=== RELACIONAMENTOS SALVOS ===');
  }

  // ============================================
  // BUSCAR RELACIONAMENTOS
  // ============================================

  Future<List<ContatoModel>> getContatosVinculados(String empresaId) async {
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
          final telefones = await _getTelefonesContato(id);
          final emails = await _getEmailsContato(id);
          final enderecos = await _getEnderecosContato(id);
          final midias = await _getMidiasContato(id);
          
          contatos.add(ContatoModel.fromJson(result).copyWith(
            telefones: telefones,
            emails: emails,
            enderecos: enderecos,
            midias: midias,
          ));
        }
      }
      return contatos;
    } catch (e) {
      print('Erro ao buscar contatos vinculados: $e');
      return [];
    }
  }

  Future<List<TelefoneModel>> getTelefones(String empresaId) async {
    try {
      final empresa = await getById(empresaId);
      if (empresa == null || empresa.contatoPrincipalId == null) return [];
      return await _getTelefonesContato(empresa.contatoPrincipalId!);
    } catch (e) {
      return [];
    }
  }

  Future<List<EmailModel>> getEmails(String empresaId) async {
    try {
      final empresa = await getById(empresaId);
      if (empresa == null || empresa.contatoPrincipalId == null) return [];
      return await _getEmailsContato(empresa.contatoPrincipalId!);
    } catch (e) {
      return [];
    }
  }

  Future<List<EnderecoModel>> getEnderecos(String empresaId) async {
    try {
      final empresa = await getById(empresaId);
      if (empresa == null || empresa.contatoPrincipalId == null) return [];
      return await _getEnderecosContato(empresa.contatoPrincipalId!);
    } catch (e) {
      return [];
    }
  }

  Future<List<MidiasModel>> getMidias(String empresaId) async {
    try {
      final empresa = await getById(empresaId);
      if (empresa == null || empresa.contatoPrincipalId == null) return [];
      return await _getMidiasContato(empresa.contatoPrincipalId!);
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // AUXILIARES
  // ============================================

  Future<List<TelefoneModel>> _getTelefonesContato(String contatoId) async {
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

  Future<List<EmailModel>> _getEmailsContato(String contatoId) async {
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

  Future<List<EnderecoModel>> _getEnderecosContato(String contatoId) async {
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

  Future<List<MidiasModel>> _getMidiasContato(String contatoId) async {
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
}
