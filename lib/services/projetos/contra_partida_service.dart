/// ============================================
/// SERVIÇO: ContraPartida
/// REGRA 11
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/contra_partida_model.dart';
import '../../models/projetos/tipo_ct_partida_model.dart';

class ContraPartidaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // CRUD - CONTRA PARTIDA
  // ============================================

  Future<List<ContraPartidaModel>> list() async {
    print('📋 [CONTRA_PARTIDA_SERVICE] LIST - Listando contra partidas');

    try {
      final response = await _supabase
          .from('contra_partida')
          .select()
          .order('descricao', ascending: true);

      return (response as List)
          .map((item) => ContraPartidaModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] LIST - Erro: $e');
      throw Exception('Erro ao listar contra partidas: $e');
    }
  }

  Future<List<ContraPartidaModel>> getByProjeto(String projetoId) async {
    print('📋 [CONTRA_PARTIDA_SERVICE] GET_BY_PROJETO - Projeto: $projetoId');

    try {
      final response = await _supabase
          .from('contra_partida')
          .select()
          .eq('projeto', projetoId)
          .order('dataentrega', ascending: true);

      return (response as List)
          .map((item) => ContraPartidaModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] GET_BY_PROJETO - Erro: $e');
      return [];
    }
  }

  Future<ContraPartidaModel?> getById(String id) async {
    print('📋 [CONTRA_PARTIDA_SERVICE] GET_BY_ID - ID: $id');

    try {
      final response = await _supabase
          .from('contra_partida')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ContraPartidaModel.fromJson(response);
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] GET_BY_ID - Erro: $e');
      throw Exception('Erro ao buscar contra partida: $e');
    }
  }

  Future<ContraPartidaModel> create(Map<String, dynamic> data) async {
    print('📋 [CONTRA_PARTIDA_SERVICE] CREATE - Criando contra partida');

    try {
      final response = await _supabase
          .from('contra_partida')
          .insert(data)
          .select()
          .single();

      print('✅ [CONTRA_PARTIDA_SERVICE] CREATE - Contra partida criada: ${response['id']}');
      return ContraPartidaModel.fromJson(response);
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] CREATE - Erro: $e');
      throw Exception('Erro ao criar contra partida: $e');
    }
  }

  Future<ContraPartidaModel> update(String id, Map<String, dynamic> data) async {
    print('📋 [CONTRA_PARTIDA_SERVICE] UPDATE - Atualizando contra partida: $id');

    try {
      final response = await _supabase
          .from('contra_partida')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      print('✅ [CONTRA_PARTIDA_SERVICE] UPDATE - Contra partida atualizada: $id');
      return ContraPartidaModel.fromJson(response);
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] UPDATE - Erro: $e');
      throw Exception('Erro ao atualizar contra partida: $e');
    }
  }

  Future<void> delete(String id) async {
    print('🗑️ [CONTRA_PARTIDA_SERVICE] DELETE - Deletando contra partida: $id');

    try {
      await _supabase
          .from('contra_partida')
          .delete()
          .eq('id', id);

      print('✅ [CONTRA_PARTIDA_SERVICE] DELETE - Contra partida deletada: $id');
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] DELETE - Erro: $e');
      throw Exception('Erro ao deletar contra partida: $e');
    }
  }

  // ============================================
  // CRUD - TIPO CT PARTIDA
  // ============================================

  Future<List<TipoCtPartidaModel>> listTipos() async {
    print('📋 [CONTRA_PARTIDA_SERVICE] LIST_TIPOS - Listando tipos de contra partida');

    try {
      final response = await _supabase
          .from('tipo_ct_partida')
          .select()
          .order('descricao', ascending: true);

      return (response as List)
          .map((item) => TipoCtPartidaModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] LIST_TIPOS - Erro: $e');
      return [];
    }
  }

  Future<TipoCtPartidaModel?> getTipoById(String id) async {
    try {
      final response = await _supabase
          .from('tipo_ct_partida')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TipoCtPartidaModel.fromJson(response);
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] GET_TIPO_BY_ID - Erro: $e');
      return null;
    }
  }

  Future<TipoCtPartidaModel> createTipo(Map<String, dynamic> data) async {
    print('📋 [CONTRA_PARTIDA_SERVICE] CREATE_TIPO - Criando tipo de contra partida');

    try {
      final response = await _supabase
          .from('tipo_ct_partida')
          .insert(data)
          .select()
          .single();

      print('✅ [CONTRA_PARTIDA_SERVICE] CREATE_TIPO - Tipo criado: ${response['id']}');
      return TipoCtPartidaModel.fromJson(response);
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] CREATE_TIPO - Erro: $e');
      throw Exception('Erro ao criar tipo de contra partida: $e');
    }
  }

  Future<TipoCtPartidaModel> updateTipo(String id, Map<String, dynamic> data) async {
    print('📋 [CONTRA_PARTIDA_SERVICE] UPDATE_TIPO - Atualizando tipo: $id');

    try {
      final response = await _supabase
          .from('tipo_ct_partida')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      print('✅ [CONTRA_PARTIDA_SERVICE] UPDATE_TIPO - Tipo atualizado: $id');
      return TipoCtPartidaModel.fromJson(response);
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] UPDATE_TIPO - Erro: $e');
      throw Exception('Erro ao atualizar tipo de contra partida: $e');
    }
  }

  Future<void> deleteTipo(String id) async {
    print('🗑️ [CONTRA_PARTIDA_SERVICE] DELETE_TIPO - Deletando tipo: $id');

    try {
      // Verificar se há contra partidas usando este tipo
      final contraPartidas = await _supabase
          .from('contra_partida')
          .select('id')
          .eq('tipo', id);

      if ((contraPartidas as List).isNotEmpty) {
        throw Exception('Não é possível excluir: este tipo está sendo usado');
      }

      await _supabase
          .from('tipo_ct_partida')
          .delete()
          .eq('id', id);

      print('✅ [CONTRA_PARTIDA_SERVICE] DELETE_TIPO - Tipo deletado: $id');
    } catch (e) {
      print('❌ [CONTRA_PARTIDA_SERVICE] DELETE_TIPO - Erro: $e');
      throw Exception('Erro ao deletar tipo de contra partida: $e');
    }
  }
}