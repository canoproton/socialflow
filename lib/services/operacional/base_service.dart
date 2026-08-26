/// ============================================
/// SERVIÇO BASE - CRUD GENÉRICO (SIMPLIFICADO)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';

class BaseService<T> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName;
  final T Function(Map<String, dynamic>) fromJson;

  BaseService({
    required this.tableName,
    required this.fromJson,
  });

  /// ============================================
  /// LISTAR TODOS OS REGISTROS
  /// ============================================
  Future<List<T>> list() async {
    try {
      final response = await _supabase.from(tableName).select();
      return (response as List)
          .map((item) => fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar $tableName: $e');
    }
  }

  /// ============================================
  /// BUSCAR REGISTRO POR ID
  /// ============================================
  Future<T?> getById(String id) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar $tableName: $e');
    }
  }

  /// ============================================
  /// CRIAR NOVO REGISTRO
  /// ============================================
  Future<T> create(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();
      
      return fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar $tableName: $e');
    }
  }

  /// ============================================
  /// ATUALIZAR REGISTRO
  /// ============================================
  Future<T> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      
      return fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar $tableName: $e');
    }
  }

  /// ============================================
  /// DELETAR REGISTRO
  /// ============================================
  Future<void> delete(String id) async {
    try {
      await _supabase
          .from(tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar $tableName: $e');
    }
  }

  /// ============================================
  /// BUSCAR REGISTROS POR CAMPO
  /// ============================================
  Future<List<T>> findBy(String field, dynamic value) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq(field, value);
      
      return (response as List)
          .map((item) => fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar $tableName: $e');
    }
  }
}
