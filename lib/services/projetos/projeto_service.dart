/// ============================================
/// SERVIÇO: Projeto (CRUD + Cálculos)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';

class ProjetoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // LISTAR PROJETOS (SIMPLES)
  // ============================================

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
      throw Exception('Erro ao listar projetos: $e');
    }
  }

  // ============================================
  // BUSCAR PROJETO POR ID
  // ============================================

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
      throw Exception('Erro ao buscar projeto: $e');
    }
  }

  // ============================================
  // BUSCAR PROJETO COMPLETO (COM METAS E ETAPAS)
  // ============================================

  Future<ProjetoModel> getCompleto(String id) async {
    try {
      final projeto = await getById(id);
      if (projeto == null) throw Exception('Projeto não encontrado');

      // Buscar metas
      final metasResponse = await _supabase
          .from('meta_projetos')
          .select()
          .eq('projeto_id', id)
          .order('sequencia', ascending: true);

      List<MetaModel> metas = [];

      for (var item in metasResponse) {
        final meta = MetaModel.fromJson(item);
        
        // Buscar etapas da meta
        final etapasResponse = await _supabase
            .from('etapas')
            .select()
            .eq('meta_projeto_id', meta.id)
            .order('sequencia', ascending: true);

        final etapas = (etapasResponse as List)
            .map((e) => EtapaModel.fromJson(e))
            .toList();

        metas.add(MetaModel(
          id: meta.id,
          projetoId: meta.projetoId,
          sequencia: meta.sequencia,
          descricao: meta.descricao,
          indicador: meta.indicador,
          unidade: meta.unidade,
          quantifiq: meta.quantifiq,
          publicoAlvo: meta.publicoAlvo,
          local: meta.local,
          prova: meta.prova,
          vlMetaAprov: meta.vlMetaAprov,
          valorTotalEtapas: meta.valorTotalEtapas,
          saldoMeta: meta.saldoMeta,
          supervisorId: meta.supervisorId,
          obs: meta.obs,
          atualizadoPor: meta.atualizadoPor,
          atualizadoEm: meta.atualizadoEm,
          createdAt: meta.createdAt,
          updatedAt: meta.updatedAt,
          etapas: etapas,
        ));
      }

      // Calcular totais
      double totalMetas = 0;
      for (var meta in metas) {
        totalMetas += meta.valorTotalEtapas ?? 0;
      }

      final saldo = (projeto.valorTotalAportado ?? 0) - totalMetas;

      return ProjetoModel(
        id: projeto.id,
        descricao: projeto.descricao,
        processo: projeto.processo,
        proponenteId: projeto.proponenteId,
        contaId: projeto.contaId,
        valorEstimado: projeto.valorEstimado,
        dataAprovacao: projeto.dataAprovacao,
        valorAprovado: projeto.valorAprovado,
        valorTotalAportado: projeto.valorTotalAportado,
        valorTotalMetas: totalMetas,
        saldoProjeto: saldo,
        gerenteProjetoId: projeto.gerenteProjetoId,
        statusProjeto: projeto.statusProjeto,
        obs: projeto.obs,
        atualizadoPor: projeto.atualizadoPor,
        atualizadoEm: projeto.atualizadoEm,
        dataEntrega: projeto.dataEntrega,
        createdAt: projeto.createdAt,
        updatedAt: projeto.updatedAt,
        metas: metas,
      );
    } catch (e) {
      throw Exception('Erro ao buscar projeto completo: $e');
    }
  }

  // ============================================
  // CRIAR PROJETO
  // ============================================

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

  // ============================================
  // ATUALIZAR PROJETO
  // ============================================

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

  // ============================================
  // DELETAR PROJETO (CASCATA)
  // ============================================

  Future<void> delete(String id) async {
    try {
      // Buscar metas
      final metasResponse = await _supabase
          .from('meta_projetos')
          .select('id')
          .eq('projeto_id', id);

      // Deletar etapas de cada meta
      for (var meta in metasResponse) {
        await _supabase
            .from('etapas')
            .delete()
            .eq('meta_projeto_id', meta['id']);
      }

      // Deletar metas
      await _supabase
          .from('meta_projetos')
          .delete()
          .eq('projeto_id', id);

      // Deletar projeto
      await _supabase
          .from('projetos')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar projeto: $e');
    }
  }

  // ============================================
  // RECALCULAR TOTAIS (Regras 4, 5, 6)
  // ============================================

  Future<void> recalcularTotais(String projetoId) async {
    try {
      final metasResponse = await _supabase
          .from('meta_projetos')
          .select('valor_total_etapas')
          .eq('projeto_id', projetoId);

      double totalMetas = 0;
      for (var meta in metasResponse) {
        totalMetas += (meta['valor_total_etapas'] ?? 0.0).toDouble();
      }

      final projeto = await getById(projetoId);
      if (projeto == null) return;

      final saldo = (projeto.valorTotalAportado ?? 0) - totalMetas;

      await _supabase
          .from('projetos')
          .update({
            'valor_total_metas': totalMetas,
            'saldo_projeto': saldo,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', projetoId);
    } catch (e) {
      throw Exception('Erro ao recalcular totais: $e');
    }
  }

  // ============================================
  // VALIDAR SE PROJETO PODE SER APROVADO
  // ============================================

  Future<bool> podeAprovar(String projetoId) async {
    try {
      final projeto = await getCompleto(projetoId);

      if (projeto.metas.isEmpty) {
        throw Exception('Projeto não pode ser aprovado sem metas');
      }

      for (var meta in projeto.metas) {
        if (meta.etapas.isEmpty) {
          throw Exception('Meta "${meta.descricao}" não tem etapas');
        }
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}