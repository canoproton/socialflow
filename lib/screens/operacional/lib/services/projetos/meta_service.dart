/// ============================================
/// SERVIÇO: Meta do Projeto (CRUD + Cálculos)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import 'projeto_service.dart';

class MetaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProjetoService _projetoService = ProjetoService();

  // ============================================
  // CRUD - META
  // ============================================

  /// Listar metas por projeto
  Future<List<MetaModel>> getByProjeto(String projetoId) async {
    try {
      final response = await _supabase
          .from('meta_projetos')
          .select()
          .eq('projeto_id', projetoId)
          .order('sequencia', ascending: true);

      return (response as List)
          .map((item) => MetaModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar metas do projeto: $e');
    }
  }

  /// Buscar meta por ID
  Future<MetaModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('meta_projetos')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return MetaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar meta: $e');
    }
  }

  /// Buscar meta completa (com etapas)
  Future<MetaModel> getCompleta(String id) async {
    try {
      final meta = await getById(id);
      if (meta == null) throw Exception('Meta não encontrada');

      // Buscar etapas
      final etapasResponse = await _supabase
          .from('etapas')
          .select()
          .eq('meta_projeto_id', id)
          .order('sequencia', ascending: true);

      final etapas = (etapasResponse as List)
          .map((item) => EtapaModel.fromJson(item))
          .toList();

      return meta.copyWith(etapas: etapas);
    } catch (e) {
      throw Exception('Erro ao buscar meta completa: $e');
    }
  }

  /// Criar meta (Regra 6 - recalcula automaticamente)
  Future<MetaModel> create(Map<String, dynamic> data) async {
    try {
      // Buscar última sequência
      final projetoId = data['projeto_id'];
      final metasExistentes = await getByProjeto(projetoId);
      final proximaSequencia = metasExistentes.length + 1;

      final response = await _supabase
          .from('meta_projetos')
          .insert({
            ...data,
            'sequencia': proximaSequencia,
            'valor_total_etapas': 0,
            'saldo_meta': 0,
          })
          .select()
          .single();

      final meta = MetaModel.fromJson(response);

      // Recalcular totais do projeto (Regra 6)
      await _projetoService.recalcularTotais(meta.projetoId);

      return meta;
    } catch (e) {
      throw Exception('Erro ao criar meta: $e');
    }
  }

  /// Atualizar meta
  Future<MetaModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('meta_projetos')
          .update({
            ...data,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final meta = MetaModel.fromJson(response);

      // Recalcular totais do projeto (Regra 6)
      await _projetoService.recalcularTotais(meta.projetoId);

      return meta;
    } catch (e) {
      throw Exception('Erro ao atualizar meta: $e');
    }
  }

  /// Deletar meta (cascata)
  Future<void> delete(String id) async {
    try {
      // Buscar meta para pegar projeto_id
      final meta = await getById(id);
      if (meta == null) return;

      // Deletar etapas
      await _supabase
          .from('etapas')
          .delete()
          .eq('meta_projeto_id', id);

      // Deletar meta
      await _supabase
          .from('meta_projetos')
          .delete()
          .eq('id', id);

      // Recalcular totais do projeto (Regra 6)
      await _projetoService.recalcularTotais(meta.projetoId);
    } catch (e) {
      throw Exception('Erro ao deletar meta: $e');
    }
  }

  // ============================================
  // CÁLCULOS AUTOMÁTICOS (Regra 4)
  // ============================================

  /// Recalcular total de etapas da meta (Regra 4)
  Future<double> recalcularTotalEtapas(String metaId) async {
    try {
      // Buscar todas etapas da meta
      final etapasResponse = await _supabase
          .from('etapas')
          .select('valor_etapa')
          .eq('meta_projeto_id', metaId);

      final etapas = etapasResponse as List;
      
      // Calcular total (Regra 4)
      double totalEtapas = 0;
      for (var etapa in etapas) {
        totalEtapas += (etapa['valor_etapa'] ?? 0.0).toDouble();
      }

      // Buscar meta para pegar vl_meta_aprov
      final meta = await getById(metaId);
      if (meta == null) return 0;

      // Calcular saldo_meta (Regra 4)
      final saldoMeta = (meta.vlMetaAprov ?? 0) - totalEtapas;

      // Atualizar meta
      await _supabase
          .from('meta_projetos')
          .update({
            'valor_total_etapas': totalEtapas,
            'saldo_meta': saldoMeta,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', metaId);

      // Recalcular totais do projeto (Regra 6)
      await _projetoService.recalcularTotais(meta.projetoId);

      return totalEtapas;
    } catch (e) {
      throw Exception('Erro ao recalcular total de etapas: $e');
    }
  }

  /// Atualizar sequência das metas (após exclusão/inserção)
  Future<void> reordenarMetas(String projetoId) async {
    try {
      final metas = await getByProjeto(projetoId);
      
      for (var i = 0; i < metas.length; i++) {
        await _supabase
            .from('meta_projetos')
            .update({'sequencia': i + 1})
            .eq('id', metas[i].id);
      }
    } catch (e) {
      throw Exception('Erro ao reordenar metas: $e');
    }
  }
}