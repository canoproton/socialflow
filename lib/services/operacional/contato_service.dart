/// ============================================
/// SERVIÇO: Contato
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';

class ContatoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ContatoModel>> list() async {
    try {
      final response = await _supabase
          .from('contato')
          .select()
          .order('nome', ascending: true);

      return (response as List)
          .map((item) => ContatoModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar contatos: $e');
    }
  }

  Future<ContatoModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('contato')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar contato: $e');
    }
  }

  Future<ContatoModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('contato')
          .insert(data)
          .select()
          .single();

      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar contato: $e');
    }
  }

  Future<ContatoModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('contato')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar contato: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _supabase
          .from('contato')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar contato: $e');
    }
  }

  // ============================================
  // RELACIONAMENTOS
  // ============================================

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