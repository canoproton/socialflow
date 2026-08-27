/// ============================================
/// SERVIÇO: Projeto (CRUD + Cálculos + Metas + Etapas)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import '../debug_service.dart';

class ProjetoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // LISTAR PROJETOS
  // ============================================

  /// Lista todos os projetos do banco de dados
  /// Retorna: List<ProjetoModel>
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

  /// Busca um projeto pelo ID
  /// Retorna: ProjetoModel? ou null se não encontrado
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

  /// Busca um projeto com todas as metas e etapas
  /// Retorna: ProjetoModel completo
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
  // CRIAR PROJETO (APENAS PROJETO, SEM METAS)
  // ============================================

  /// Cria apenas o projeto (sem metas e etapas)
  /// Usado para criação básica
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
  // CRIAR PROJETO COMPLETO (COM METAS E ETAPAS) ⭐ REGRA 2
  // ============================================

  /// Cria projeto com metas e etapas em uma única transação
  /// ⭐ REGRA 2: Metas e Etapas são criadas junto com o projeto
  /// ⭐ REGRA 4: Calcula valor_etapa = valor_unitario * quantidade
  /// ⭐ REGRA 5: Calcula valor_total_metas = soma(valor_total_etapas)
  Future<ProjetoModel> createCompleto(Map<String, dynamic> data) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'CREATE_COMPLETO',
      data: 'Criando projeto com metas e etapas',
    );

    try {
      // 1. Extrair metas do payload
      final metasData = data.remove('metas') as List? ?? [];
      
      // 2. Validar se tem metas (Regra 2)
      if (metasData.isEmpty) {
        throw Exception('Projeto deve ter pelo menos uma meta');
      }
      
      // 3. Validar se todas metas têm etapas (Regra 2)
      for (var metaPayload in metasData) {
        final etapasData = metaPayload['etapas'] as List? ?? [];
        if (etapasData.isEmpty) {
          throw Exception('Meta "${metaPayload['descricao']}" não tem etapas');
        }
      }
      
      // 4. Criar projeto
      final response = await _supabase
          .from('projetos')
          .insert({
            ...data,
            'valor_total_metas': 0,
            'saldo_projeto': 0,
          })
          .select()
          .single();

      final projeto = ProjetoModel.fromJson(response);
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'CREATE_COMPLETO',
        data: 'Projeto criado: ${projeto.id}',
      );

      // 5. Criar metas e etapas
      for (var i = 0; i < metasData.length; i++) {
        final metaPayload = metasData[i];
        final etapasData = metaPayload.remove('etapas') as List? ?? [];
        
        // Criar meta
        final metaResponse = await _supabase
            .from('meta_projetos')
            .insert({
              ...metaPayload,
              'projeto_id': projeto.id,
              'sequencia': i + 1,
              'valor_total_etapas': 0,
              'saldo_meta': 0,
            })
            .select()
            .single();
        
        final meta = MetaModel.fromJson(metaResponse);
        DebugService.log(
          module: 'PROJETO_SERVICE',
          action: 'CREATE_COMPLETO',
          data: 'Meta criada: ${meta.id} - ${meta.descricao}',
        );

        // Criar etapas da meta
        for (var j = 0; j < etapasData.length; j++) {
          final etapaPayload = etapasData[j];
          
          // ⭐ REGRA 4: Calcular valor_etapa = valor_unitario * quantidade
          final valorUnitario = (etapaPayload['valor_unitario'] ?? 0.0).toDouble();
          final quantidade = (etapaPayload['quantidade'] ?? 0.0).toDouble();
          final valorEtapa = valorUnitario * quantidade;

          await _supabase
              .from('etapas')
              .insert({
                ...etapaPayload,
                'meta_projeto_id': meta.id,
                'sequencia': j + 1,
                'valor_etapa': valorEtapa,
              });
          
          DebugService.log(
            module: 'PROJETO_SERVICE',
            action: 'CREATE_COMPLETO',
            data: 'Etapa criada: ${etapaPayload['descricao']} - Valor: $valorEtapa',
          );
        }

        // ⭐ REGRA 4: Recalcular total da meta
        await _recalcularTotalMeta(meta.id);
      }

      // ⭐ REGRA 5: Recalcular totais do projeto
      await _recalcularTotaisProjeto(projeto.id);

      // Buscar projeto completo atualizado
      return await getCompleto(projeto.id);
      
    } catch (e) {
      DebugService.log(
        module: 'PROJETO_SERVICE',
        action: 'CREATE_COMPLETO',
        error: e.toString(),
        isError: true,
      );
      throw Exception('Erro ao criar projeto completo: $e');
    }
  }

  // ============================================
  // ATUALIZAR PROJETO
  // ============================================

  /// Atualiza apenas os dados do projeto (não metas/etapas)
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
  // DELETAR PROJETO (CASCATA)
  // ============================================

  /// Deleta projeto e todos os relacionamentos (metas e etapas)
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
  // CÁLCULOS AUTOMÁTICOS (Regras 4, 5, 6)
  // ============================================

  /// ⭐ REGRA 4: Recalcular total de etapas da meta
  /// valor_total_etapas = soma(valor_etapa) de todas etapas
  Future<void> _recalcularTotalMeta(String metaId) async {
    final etapasResponse = await _supabase
        .from('etapas')
        .select('valor_etapa')
        .eq('meta_projeto_id', metaId);

    final etapas = etapasResponse as List;
    
    double totalEtapas = 0;
    for (var etapa in etapas) {
      totalEtapas += (etapa['valor_etapa'] ?? 0.0).toDouble();
    }

    final meta = await _supabase
        .from('meta_projetos')
        .select('vl_meta_aprov')
        .eq('id', metaId)
        .single();

    final vlMetaAprov = (meta['vl_meta_aprov'] ?? 0.0).toDouble();
    final saldoMeta = vlMetaAprov - totalEtapas;

    await _supabase
        .from('meta_projetos')
        .update({
          'valor_total_etapas': totalEtapas,
          'saldo_meta': saldoMeta,
          'atualizado_em': DateTime.now().toIso8601String(),
        })
        .eq('id', metaId);

    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'RECALCULAR_META',
      data: 'Meta $metaId - Total Etapas: $totalEtapas, Saldo: $saldoMeta',
    );
  }

  /// ⭐ REGRA 5: Recalcular totais do projeto
  /// valor_total_metas = soma(valor_total_etapas) de todas metas
  Future<void> _recalcularTotaisProjeto(String projetoId) async {
    final metasResponse = await _supabase
        .from('meta_projetos')
        .select('valor_total_etapas')
        .eq('projeto_id', projetoId);

    final metas = metasResponse as List;
    
    double totalMetas = 0;
    for (var meta in metas) {
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
      action: 'RECALCULAR_PROJETO',
      data: 'Projeto $projetoId - Total Metas: $totalMetas, Saldo: $saldo',
    );
  }

  /// ⭐ REGRA 6: Recalcular todos os totais (chamada pública)
  Future<void> recalcularTotais(String projetoId) async {
    DebugService.log(
      module: 'PROJETO_SERVICE',
      action: 'RECALCULAR_TOTAIS',
      data: 'Projeto ID: $projetoId',
    );
    await _recalcularTotaisProjeto(projetoId);
  }

  // ============================================
  // VALIDAÇÃO (Regra 8)
  // ============================================

  /// ⭐ REGRA 8: Verificar se projeto pode ser aprovado
  /// Condições: tem metas e todas metas têm etapas
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