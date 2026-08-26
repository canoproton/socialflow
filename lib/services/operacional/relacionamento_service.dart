/// ============================================
/// SERVIÇO: Relacionamentos
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';
import '../../models/operacional/contato_model.dart';

class RelacionamentoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // MÉTODOS PARA CONTATO
  // ============================================

  Future<List<TelefoneModel>> saveTelefones(
    String contatoId, 
    List<TelefoneModel> telefones
  ) async {
    print('=== SALVANDO TELEFONES (CONTATO) ===');
    print('Contato ID: $contatoId');
    
    final validos = telefones.where((t) => t.numero.isNotEmpty).toList();
    
    await _supabase
        .from('telefone')
        .delete()
        .eq('contato_id', contatoId);

    List<TelefoneModel> salvos = [];
    for (var telefone in validos) {
      final data = {
        'contato_id': contatoId,
        'uso': telefone.uso,
        'numero': telefone.numero,
        'obs': telefone.obs,
      };
      
      try {
        final result = await _supabase
            .from('telefone')
            .insert(data)
            .select()
            .single();
        salvos.add(TelefoneModel.fromJson(result));
      } catch (e) {
        print('Erro ao inserir telefone: $e');
      }
    }
    
    print('Telefones salvos: ${salvos.length}');
    return salvos;
  }

  Future<List<EmailModel>> saveEmails(
    String contatoId, 
    List<EmailModel> emails
  ) async {
    print('=== SALVANDO EMAILS (CONTATO) ===');
    
    final validos = emails.where((e) => e.endereco.isNotEmpty).toList();
    
    await _supabase
        .from('email')
        .delete()
        .eq('contato_id', contatoId);

    List<EmailModel> salvos = [];
    for (var email in validos) {
      final data = {
        'contato_id': contatoId,
        'uso': email.uso,
        'endereco': email.endereco,
        'obs': email.obs,
      };
      
      try {
        final result = await _supabase
            .from('email')
            .insert(data)
            .select()
            .single();
        salvos.add(EmailModel.fromJson(result));
      } catch (e) {
        print('Erro ao inserir email: $e');
      }
    }
    
    print('Emails salvos: ${salvos.length}');
    return salvos;
  }

  Future<List<EnderecoModel>> saveEnderecos(
    String contatoId, 
    List<EnderecoModel> enderecos
  ) async {
    print('=== SALVANDO ENDEREÇOS (CONTATO) ===');
    
    final validos = enderecos.where((e) => e.logradouro.isNotEmpty).toList();
    
    await _supabase
        .from('endereco')
        .delete()
        .eq('contato_id', contatoId);

    List<EnderecoModel> salvos = [];
    for (var endereco in validos) {
      final data = {
        'contato_id': contatoId,
        'logradouro': endereco.logradouro,
        'bairro': endereco.bairro,
        'cidade': endereco.cidade,
        'estado': endereco.estado,
        'cep': endereco.cep,
        'obs': endereco.obs,
      };
      
      try {
        final result = await _supabase
            .from('endereco')
            .insert(data)
            .select()
            .single();
        salvos.add(EnderecoModel.fromJson(result));
      } catch (e) {
        print('Erro ao inserir endereço: $e');
      }
    }
    
    print('Endereços salvos: ${salvos.length}');
    return salvos;
  }

  Future<List<MidiasModel>> saveMidias(
    String contatoId, 
    List<MidiasModel> midias
  ) async {
    print('=== SALVANDO MÍDIAS (CONTATO) ===');
    
    final validos = midias.where((m) => m.descricao.isNotEmpty).toList();
    
    await _supabase
        .from('midias')
        .delete()
        .eq('contato_id', contatoId);

    List<MidiasModel> salvos = [];
    for (var midia in validos) {
      final data = {
        'contato_id': contatoId,
        'uso': midia.uso,
        'tipo': midia.tipo,
        'nome_do_app': midia.nomeDoApp,
        'descricao': midia.descricao,
        'obs': midia.obs,
      };
      
      try {
        final result = await _supabase
            .from('midias')
            .insert(data)
            .select()
            .single();
        salvos.add(MidiasModel.fromJson(result));
      } catch (e) {
        print('Erro ao inserir mídia: $e');
      }
    }
    
    print('Mídias salvas: ${salvos.length}');
    return salvos;
  }

  // ============================================
  // MÉTODOS PARA EMPRESA
  // ============================================

  Future<List<TelefoneModel>> saveTelefonesEmpresa(
    String empresaId, 
    List<TelefoneModel> telefones
  ) async {
    print('=== SALVANDO TELEFONES (EMPRESA) ===');
    print('Empresa ID: $empresaId');
    
    // Primeiro, buscar o contato principal da empresa
    final empresa = await _supabase
        .from('empresa')
        .select()
        .eq('id', empresaId)
        .maybeSingle();
    
    if (empresa == null) {
      print('❌ Empresa não encontrada');
      return [];
    }
    
    final contatoPrincipalId = empresa['contato_principal'];
    if (contatoPrincipalId == null) {
      print('⚠️ Empresa não tem contato principal');
      // Criar um contato padrão para a empresa
      final novoContato = await _supabase
          .from('contato')
          .insert({
            'nome': empresa['nome'],
            'tipo_vinculo': 'EMPRESA',
          })
          .select()
          .single();
      
      final contatoId = novoContato['id'];
      
      // Vincular à empresa
      await _supabase
          .from('empresa')
          .update({'contato_principal': contatoId})
          .eq('id', empresaId);
      
      // Salvar telefones no contato criado
      return await saveTelefones(contatoId, telefones);
    }
    
    // Salvar telefones no contato principal
    return await saveTelefones(contatoPrincipalId, telefones);
  }

  Future<List<EmailModel>> saveEmailsEmpresa(
    String empresaId, 
    List<EmailModel> emails
  ) async {
    print('=== SALVANDO EMAILS (EMPRESA) ===');
    
    final empresa = await _supabase
        .from('empresa')
        .select()
        .eq('id', empresaId)
        .maybeSingle();
    
    if (empresa == null) return [];
    
    final contatoPrincipalId = empresa['contato_principal'];
    if (contatoPrincipalId == null) return [];
    
    return await saveEmails(contatoPrincipalId, emails);
  }

  Future<List<EnderecoModel>> saveEnderecosEmpresa(
    String empresaId, 
    List<EnderecoModel> enderecos
  ) async {
    print('=== SALVANDO ENDEREÇOS (EMPRESA) ===');
    
    final empresa = await _supabase
        .from('empresa')
        .select()
        .eq('id', empresaId)
        .maybeSingle();
    
    if (empresa == null) return [];
    
    final contatoPrincipalId = empresa['contato_principal'];
    if (contatoPrincipalId == null) return [];
    
    return await saveEnderecos(contatoPrincipalId, enderecos);
  }

  Future<List<MidiasModel>> saveMidiasEmpresa(
    String empresaId, 
    List<MidiasModel> midias
  ) async {
    print('=== SALVANDO MÍDIAS (EMPRESA) ===');
    
    final empresa = await _supabase
        .from('empresa')
        .select()
        .eq('id', empresaId)
        .maybeSingle();
    
    if (empresa == null) return [];
    
    final contatoPrincipalId = empresa['contato_principal'];
    if (contatoPrincipalId == null) return [];
    
    return await saveMidias(contatoPrincipalId, midias);
  }
}
