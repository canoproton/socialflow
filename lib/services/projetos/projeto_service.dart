/// ============================================
/// SERVIÇO: Projeto (CRUD + Cálculos)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import '../debug_service.dart';

class ProjetoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // LISTAR PROJETOS (VERSÃO SIMPLIFICADA - SEM FILTROS)
  // ============================================

  Future<List<ProjetoModel>> list() async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'LIST',
      data: 'Listando todos os projetos',
    );

    try {
      final response = await _supabase
          .from('projetos')
          .select()
          .order('created_at', ascending: false);

      final result = (response as List)
          .map((item) => ProjetoModel.fromJson(item))
          .toList();

      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'LIST',
        data: 'Encontrados ${result.length} projetos',
      );

      return result;
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'LIST',
        error: e.toString(),
        isError: true,
      );
      throw Exception('Erro ao listar projetos: $e');
    }
  }

  // ============================================
  // BUSCAR PROJETO POR ID
  // ============================================

  Future<ProjetoModel?> getById(String id) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'GET_BY_ID',
      data: 'ID: $id',
    );

    try {
      final response = await _supabase
          .from('projetos')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        DebugService.log(
          module: 'PROJETO_SERVICE',
          action: 'GET_BY_ID',
          data: 'Projeto não encontrado',
          isWarning: true,
        );
        return null;
      }

      return ProjetoModel.fromJson(response);
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'GET_BY_ID',
        error: e.toString(),
        isError: true,
      );
      throw Exception('Erro ao buscar projeto: $e');
    }
  }

  // ============================================
  // BUSCAR PROJETO COMPLETO (COM METAS E ETAPAS)
  // ============================================

  Future<ProjetoModel> getCompleto(String id) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'GET_COMPLETO',
      data: 'ID: $id',
    );

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
          docsMetas: meta.docsMetas,
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

      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'GET_COMPLETO',
        data: 'Projeto: ${projeto.descricao}, Metas: ${metas.length}, Total: $totalMetas',
      );

      return ProjetoModel(
        id: projeto.id,
        descricao: projeto.descricao,
        processo: projeto.processo,
        proponenteId: projeto.proponenteId,
        contaId: projeto.contaId,
        docsAnexo: projeto.docsAnexo,
        recursos: projeto.recursos,
        contraPartida: projeto.contraPartida,
        dataEntrega: projeto.dataEntrega,
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
        createdAt: projeto.createdAt,
        updatedAt: projeto.updatedAt,
        metas: metas,
      );
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'GET_COMPLETO',
        error: e.toString(),
        isError: true,
      );
      throw Exception('Erro ao buscar projeto completo: $e');
    }
  }

  // ============================================
  // CRIAR PROJETO
  // ============================================

  Future<ProjetoModel> create(Map<String, dynamic> data) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'CREATE',
      data: data,
    );

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

      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'CREATE',
        data: 'Projeto criado: ${response['id']}',
      );

      return ProjetoModel.fromJson(response);
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'CREATE',
        error: e.toString(),
        isError: true,
      );
      throw Exception('Erro ao criar projeto: $e');
    }
  }

  // ============================================
  // ATUALIZAR PROJETO
  // ============================================

  Future<ProjetoModel> update(String id, Map<String, dynamic> data) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'UPDATE',
      data: 'ID: $id',
    );

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

      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'UPDATE',
        data: 'Projeto atualizado: $id',
      );

      return ProjetoModel.fromJson(response);
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'UPDATE',
        error: e.toString(),
        isError: true,
      );
      throw Exception('Erro ao atualizar projeto: $e');
    }
  }

  // ============================================
  // DELETAR PROJETO
  // ============================================

  Future<void> delete(String id) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'DELETE',
      data: 'ID: $id',
    );

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

      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'DELETE',
        data: 'Projeto deletado: $id',
      );
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'DELETE',
        error: e.toString(),
        isError: true,
      );
      throw Exception('Erro ao deletar projeto: $e');
    }
  }

  // ============================================
  // RECALCULAR TOTAIS (Regras 4, 5, 6)
  // ============================================

  Future<void> recalcularTotais(String projetoId) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'RECALCULAR_TOTAIS',
      data: 'Projeto ID: $projetoId',
    );

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

      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'RECALCULAR_TOTAIS',
        data: 'Total Metas: $totalMetas, Saldo: $saldo',
      );
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'RECALCULAR_TOTAIS',
        error: e.toString(),
        isError: true,
      );
      throw Exception('Erro ao recalcular totais: $e');
    }
  }

  // ============================================
  // VALIDAR SE PROJETO PODE SER APROVADO (Regra 8)
  // ============================================

  Future<bool> podeAprovar(String projetoId) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'PODE_APROVAR',
      data: 'Projeto ID: $projetoId',
    );

    try {
      final projeto = await getCompleto(projetoId);

      if (projeto.metas.isEmpty) {
        DebugService.log(
          module: 'PROJETO_SERVICE',
          action: 'PODE_APROVAR',
          data: 'Projeto sem metas',
          isWarning: true,
        );
        throw Exception('Projeto não pode ser aprovado sem metas');
      }

      for (var meta in projeto.metas) {
        if (meta.etapas.isEmpty) {
          DebugService.log(
            module: 'PROJETO_SERVICE',
            action: 'PODE_APROVAR',
            data: 'Meta sem etapas: ${meta.descricao}',
            isWarning: true,
          );
          throw Exception('Meta "${meta.descricao}" não tem etapas');
        }
      }

      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'PODE_APROVAR',
        data: 'Projeto pode ser aprovado',
      );

      return true;
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'PODE_APROVAR',
        error: e.toString(),
        isError: true,
      );
      rethrow;
    }
  }
}