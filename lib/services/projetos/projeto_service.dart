/// ============================================
/// SERVIÇO: Projeto (Simples para teste)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/projeto_model.dart';

class ProjetoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProjetoModel>> list() async {
    try {
      final response = await _supabase
          .from('projetos')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ProjetoModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erro ao listar projetos: $e');
      return [];
    }
  }

  Future<ProjetoModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('projetos')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ProjetoModel.fromJson(response);
    } catch (e) {
      print('Erro ao buscar projeto: $e');
      return null;
    }
  }

  Future<ProjetoModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('projetos')
          .insert({
            ...data,
            'valor_total_metas': 0,
            'saldo_projeto': 0,
          })
          .select()
          .single();

      return ProjetoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar projeto: $e');
    }
  }

  Future<ProjetoModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('projetos')
          .update({
            ...data,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return ProjetoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar projeto: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _supabase
          .from('projetos')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar projeto: $e');
    }
  }
}