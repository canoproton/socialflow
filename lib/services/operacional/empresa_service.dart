/// ============================================
/// SERVIÇO: Empresa (com Relacionamentos)
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
      await _supabase
          .from('empresa')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar empresa: $e');
    }
  }

  // ============================================
  // RELACIONAMENTOS
  // ============================================

  Future<List<ContatoModel>> getContatos(String empresaId) async {
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

  Future<void> vincularContato(String empresaId, String contatoId) async {
    try {
      await _supabase
          .from('empresa_contato')
          .insert({
            'empresa_id': empresaId,
            'contato_id': contatoId,
          });
    } catch (e) {
      throw Exception('Erro ao vincular contato: $e');
    }
  }

  Future<void> desvincularContato(String empresaId, String contatoId) async {
    try {
      await _supabase
          .from('empresa_contato')
          .delete()
          .eq('empresa_id', empresaId)
          .eq('contato_id', contatoId);
    } catch (e) {
      throw Exception('Erro ao desvincular contato: $e');
    }
  }

  Future<List<TelefoneModel>> getTelefones(String contatoId) async {
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

  Future<List<EmailModel>> getEmails(String contatoId) async {
    try {
      final response = await _supabase
          .from('email')
          .select()
          .eq('contato_id', contatoId);

      return (response as List)
          .map((item) => EmailModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<EnderecoModel>> getEnderecos(String contatoId) async {
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

  Future<List<MidiasModel>> getMidias(String contatoId) async {
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