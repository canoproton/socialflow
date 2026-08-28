/// ============================================
/// SERVIÇO: FontesBase
/// REGRA 7
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../models/projetos/fonte_alocacao_model.dart';

class FontesBaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // CRUD - FONTESBASE
  // ============================================

  Future<List<FontesBaseModel>> list() async {
    print('📋 [FONTES_BASE_SERVICE] LIST - Listando fontes de recursos');

    try {
      final response = await _supabase
          .from('fontes_base')
          .select()
          .order('descricao', ascending: true);

      return (response as List)
          .map((item) => FontesBaseModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] LIST - Erro: $e');
      throw Exception('Erro ao listar fontes de recursos: $e');
    }
  }

  Future<FontesBaseModel?> getById(String id) async {
    print('📋 [FONTES_BASE_SERVICE] GET_BY_ID - ID: $id');

    try {
      final response = await _supabase
          .from('fontes_base')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return FontesBaseModel.fromJson(response);
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] GET_BY_ID - Erro: $e');
      throw Exception('Erro ao buscar fonte de recurso: $e');
    }
  }

  Future<FontesBaseModel> create(Map<String, dynamic> data) async {
    print('📋 [FONTES_BASE_SERVICE] CREATE - Criando fonte de recurso');

    try {
      final response = await _supabase
          .from('fontes_base')
          .insert(data)
          .select()
          .single();

      print('✅ [FONTES_BASE_SERVICE] CREATE - Fonte criada: ${response['id']}');
      return FontesBaseModel.fromJson(response);
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] CREATE - Erro: $e');
      throw Exception('Erro ao criar fonte de recurso: $e');
    }
  }

  Future<FontesBaseModel> update(String id, Map<String, dynamic> data) async {
    print('📋 [FONTES_BASE_SERVICE] UPDATE - Atualizando fonte: $id');

    try {
      final response = await _supabase
          .from('fontes_base')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      print('✅ [FONTES_BASE_SERVICE] UPDATE - Fonte atualizada: $id');
      return FontesBaseModel.fromJson(response);
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] UPDATE - Erro: $e');
      throw Exception('Erro ao atualizar fonte de recurso: $e');
    }
  }

  Future<void> delete(String id) async {
    print('🗑️ [FONTES_BASE_SERVICE] DELETE - Deletando fonte: $id');

    try {
      // Verificar se há alocações vinculadas
      final alocacoes = await _supabase
          .from('fonte_alocacao')
          .select('id')
          .eq('fonte_alocacao', id);

      if ((alocacoes as List).isNotEmpty) {
        throw Exception('Não é possível excluir: esta fonte tem alocações vinculadas');
      }

      await _supabase
          .from('fontes_base')
          .delete()
          .eq('id', id);

      print('✅ [FONTES_BASE_SERVICE] DELETE - Fonte deletada: $id');
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] DELETE - Erro: $e');
      throw Exception('Erro ao deletar fonte de recurso: $e');
    }
  }

  // ============================================
  // ALOCAÇÕES
  // ============================================

  Future<List<FonteAlocacaoModel>> getAlocacoes(String fonteId) async {
    print('📋 [FONTES_BASE_SERVICE] GET_ALOCACOES - Fonte: $fonteId');

    try {
      final response = await _supabase
          .from('fonte_alocacao')
          .select()
          .eq('fonte_alocacao', fonteId)
          .order('data_alocacao', ascending: false);

      return (response as List)
          .map((item) => FonteAlocacaoModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] GET_ALOCACOES - Erro: $e');
      return [];
    }
  }

  Future<FonteAlocacaoModel> createAlocacao(Map<String, dynamic> data) async {
    print('📋 [FONTES_BASE_SERVICE] CREATE_ALOCACAO - Criando alocação');

    try {
      final response = await _supabase
          .from('fonte_alocacao')
          .insert(data)
          .select()
          .single();

      print('✅ [FONTES_BASE_SERVICE] CREATE_ALOCACAO - Alocação criada: ${response['id']}');
      return FonteAlocacaoModel.fromJson(response);
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] CREATE_ALOCACAO - Erro: $e');
      throw Exception('Erro ao criar alocação: $e');
    }
  }

  Future<void> deleteAlocacao(String id) async {
    print('🗑️ [FONTES_BASE_SERVICE] DELETE_ALOCACAO - Deletando alocação: $id');

    try {
      await _supabase
          .from('fonte_alocacao')
          .delete()
          .eq('id', id);

      print('✅ [FONTES_BASE_SERVICE] DELETE_ALOCACAO - Alocação deletada: $id');
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] DELETE_ALOCACAO - Erro: $e');
      throw Exception('Erro ao deletar alocação: $e');
    }
  }
}