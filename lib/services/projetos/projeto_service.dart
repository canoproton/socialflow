/// ============================================
/// SERVIÇO: Projeto (CRUD + Cálculos + Metas + Etapas)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';

class ProjetoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // LISTAR TODOS OS PROJETOS (SEM FILTROS)
  // ============================================

  Future<List<ProjetoModel>> list() async {
    print('📋 [PROJETO_SERVICE] LIST - Listando todos os projetos');

    try {
      final response = await _supabase
          .from('projetos')
          .select()
          .order('created_at', ascending: false);

      final result = (response as List)
          .map((item) => ProjetoModel.fromJson(item))
          .toList();

      print('✅ [PROJETO_SERVICE] LIST - Encontrados ${result.length} projetos');
      return result;
    } catch (e) {
      print('❌ [PROJETO_SERVICE] LIST - Erro: $e');
      throw Exception('Erro ao listar projetos: $e');
    }
  }

  // ============================================
  // BUSCAR PROJETO POR ID
  // ============================================

  Future<ProjetoModel?> getById(String id) async {
    print('📋 [PROJETO_SERVICE] GET_BY_ID - Buscando projeto ID: $id');

    try {
      final response = await _supabase
          .from('projetos')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        print('⚠️ [PROJETO_SERVICE] GET_BY_ID - Projeto não encontrado');
        return null;
      }

      print('✅ [PROJETO_SERVICE] GET_BY_ID - Projeto encontrado: ${response['descricao']}');
      return ProjetoModel.fromJson(response);
    } catch (e) {
      print('❌ [PROJETO_SERVICE] GET_BY_ID - Erro: $e');
      throw Exception('Erro ao buscar projeto: $e');
    }
  }

  // ============================================
  // BUSCAR PROJETO COMPLETO (COM METAS E ETAPAS)
  // ============================================

  Future<ProjetoModel> getCompleto(String id) async {
    print('📋 [PROJETO_SERVICE] GET_COMPLETO - Buscando projeto completo ID: $id');

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

      print('✅ [PROJETO_SERVICE] GET_COMPLETO - Projeto: ${projeto.descricao}, Metas: ${metas.length}, Total: $totalMetas');

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
      print('❌ [PROJETO_SERVICE] GET_COMPLETO - Erro: $e');
      throw Exception('Erro ao buscar projeto completo: $e');
    }
  }

  // ============================================
  // CRIAR PROJETO (APENAS PROJETO, SEM METAS)
  // ============================================

  Future<ProjetoModel> create(Map<String, dynamic> data) async {
    print('📋 [PROJETO_SERVICE] CREATE - Criando projeto');

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

      print('✅ [PROJETO_SERVICE] CREATE - Projeto criado: ${response['id']}');
      return ProjetoModel.fromJson(response);
    } catch (e) {
      print('❌ [PROJETO_SERVICE] CREATE - Erro: $e');
      throw Exception('Erro ao criar projeto: $e');
    }
  }

  // ============================================
  // CRIAR PROJETO COMPLETO (COM METAS E ETAPAS) ⭐ REGRA 2
  // ============================================

  Future<ProjetoModel> createCompleto(Map<String, dynamic> data) async {
    print('📋 [PROJETO_SERVICE] CREATE_COMPLETO - Criando projeto com metas e etapas');

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
      print('✅ [PROJETO_SERVICE] CREATE_COMPLETO - Projeto criado: ${projeto.id}');

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
        print('✅ [PROJETO_SERVICE] CREATE_COMPLETO - Meta criada: ${meta.id} - ${meta.descricao}');

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

          print('✅ [PROJETO_SERVICE] CREATE_COMPLETO - Etapa criada: ${etapaPayload['descricao']} - Valor: $valorEtapa');
        }

        // ⭐ REGRA 4: Recalcular total da meta
        await _recalcularTotalMeta(meta.id);
      }

      // ⭐ REGRA 5: Recalcular totais do projeto
      await _recalcularTotaisProjeto(projeto.id);

      // Buscar projeto completo atualizado
      return await getCompleto(projeto.id);
    } catch (e) {
      print('❌ [PROJETO_SERVICE] CREATE_COMPLETO - Erro: $e');
      throw Exception('Erro ao criar projeto completo: $e');
    }
  }

  // ============================================
  // ATUALIZAR PROJETO (APENAS PROJETO)
  // ============================================

  Future<ProjetoModel> update(String id, Map<String, dynamic> data) async {
    print('📋 [PROJETO_SERVICE] UPDATE - Atualizando projeto ID: $id');

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

      print('✅ [PROJETO_SERVICE] UPDATE - Projeto atualizado: $id');
      return ProjetoModel.fromJson(response);
    } catch (e) {
      print('❌ [PROJETO_SERVICE] UPDATE - Erro: $e');
      throw Exception('Erro ao atualizar projeto: $e');
    }
  }

  // ============================================
  // ATUALIZAR PROJETO COMPLETO (COM METAS E ETAPAS) ⭐ REGRA 2
  // ============================================

  Future<ProjetoModel> updateCompleto(String id, Map<String, dynamic> data) async {
    print('📋 [PROJETO_SERVICE] UPDATE_COMPLETO - Atualizando projeto completo ID: $id');

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

      // 4. Atualizar dados do projeto
      await _supabase
          .from('projetos')
          .update({
            ...data,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      print('✅ [PROJETO_SERVICE] UPDATE_COMPLETO - Projeto atualizado: $id');

      // 5. Buscar metas existentes
      final metasExistentes = await _supabase
          .from('meta_projetos')
          .select('id')
          .eq('projeto_id', id);

      final idsExistentes = (metasExistentes as List)
          .map((m) => m['id'].toString())
          .toList();

      final idsNovos = <String>[];

      // 6. Processar metas
      for (var i = 0; i < metasData.length; i++) {
        final metaPayload = metasData[i];
        final metaId = metaPayload['id'] as String?;
        final etapasData = metaPayload.remove('etapas') as List? ?? [];

        if (metaId != null && idsExistentes.contains(metaId)) {
          // 6a. Atualizar meta existente
          await _supabase
              .from('meta_projetos')
              .update({
                ...metaPayload,
                'atualizado_em': DateTime.now().toIso8601String(),
              })
              .eq('id', metaId);

          idsNovos.add(metaId);
          print('✅ [PROJETO_SERVICE] UPDATE_COMPLETO - Meta atualizada: $metaId');

          // Atualizar etapas da meta
          await _processarEtapas(metaId, etapasData);
        } else {
          // 6b. Criar nova meta
          final metaResponse = await _supabase
              .from('meta_projetos')
              .insert({
                ...metaPayload,
                'projeto_id': id,
                'sequencia': i + 1,
                'valor_total_etapas': 0,
                'saldo_meta': 0,
              })
              .select()
              .single();

          final novaMeta = MetaModel.fromJson(metaResponse);
          idsNovos.add(novaMeta.id);
          print('✅ [PROJETO_SERVICE] UPDATE_COMPLETO - Nova meta criada: ${novaMeta.id}');

          // Criar etapas da nova meta
          for (var j = 0; j < etapasData.length; j++) {
            final etapaPayload = etapasData[j];

            // ⭐ REGRA 4: Calcular valor_etapa
            final valorUnitario = (etapaPayload['valor_unitario'] ?? 0.0).toDouble();
            final quantidade = (etapaPayload['quantidade'] ?? 0.0).toDouble();
            final valorEtapa = valorUnitario * quantidade;

            await _supabase
                .from('etapas')
                .insert({
                  ...etapaPayload,
                  'meta_projeto_id': novaMeta.id,
                  'sequencia': j + 1,
                  'valor_etapa': valorEtapa,
                });
          }

          // Recalcular total da nova meta
          await _recalcularTotalMeta(novaMeta.id);
        }
      }

      // 7. Remover metas que não estão mais no payload
      for (var idExistente in idsExistentes) {
        if (!idsNovos.contains(idExistente)) {
          print('🗑️ [PROJETO_SERVICE] UPDATE_COMPLETO - Removendo meta: $idExistente');
          // Deletar etapas da meta
          await _supabase
              .from('etapas')
              .delete()
              .eq('meta_projeto_id', idExistente);

          // Deletar meta
          await _supabase
              .from('meta_projetos')
              .delete()
              .eq('id', idExistente);
        }
      }

      // 8. Recalcular totais (Regras 4, 5)
      await _recalcularTotaisProjeto(id);

      // 9. Buscar projeto completo atualizado
      return await getCompleto(id);
    } catch (e) {
      print('❌ [PROJETO_SERVICE] UPDATE_COMPLETO - Erro: $e');
      throw Exception('Erro ao atualizar projeto completo: $e');
    }
  }

  // ============================================
  // DELETAR PROJETO (CASCATA)
  // ============================================

  Future<void> delete(String id) async {
    print('🗑️ [PROJETO_SERVICE] DELETE - Deletando projeto ID: $id');

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

      print('✅ [PROJETO_SERVICE] DELETE - Projeto deletado: $id');
    } catch (e) {
      print('❌ [PROJETO_SERVICE] DELETE - Erro: $e');
      throw Exception('Erro ao deletar projeto: $e');
    }
  }

  // ============================================
  // PROCESSAR ETAPAS (AUXILIAR)
  // ============================================

  Future<void> _processarEtapas(String metaId, List<dynamic> etapasData) async {
    // Buscar etapas existentes
    final etapasExistentes = await _supabase
        .from('etapas')
        .select('id')
        .eq('meta_projeto_id', metaId);

    final idsExistentes = (etapasExistentes as List)
        .map((e) => e['id'].toString())
        .toList();

    final idsNovos = <String>[];

    for (var i = 0; i < etapasData.length; i++) {
      final etapaPayload = etapasData[i];
      final etapaId = etapaPayload['id'] as String?;

      // ⭐ REGRA 4: Calcular valor_etapa
      final valorUnitario = (etapaPayload['valor_unitario'] ?? 0.0).toDouble();
      final quantidade = (etapaPayload['quantidade'] ?? 0.0).toDouble();
      final valorEtapa = valorUnitario * quantidade;

      if (etapaId != null && idsExistentes.contains(etapaId)) {
        // Atualizar etapa existente
        await _supabase
            .from('etapas')
            .update({
              ...etapaPayload,
              'valor_etapa': valorEtapa,
              'atualizado_em': DateTime.now().toIso8601String(),
            })
            .eq('id', etapaId);

        idsNovos.add(etapaId);
        print('✅ [PROJETO_SERVICE] PROCESSAR_ETAPAS - Etapa atualizada: $etapaId');
      } else {
        // Criar nova etapa
        final etapaResponse = await _supabase
            .from('etapas')
            .insert({
              ...etapaPayload,
              'meta_projeto_id': metaId,
              'sequencia': i + 1,
              'valor_etapa': valorEtapa,
            })
            .select()
            .single();

        idsNovos.add(etapaResponse['id'].toString());
        print('✅ [PROJETO_SERVICE] PROCESSAR_ETAPAS - Nova etapa criada: ${etapaResponse['id']}');
      }
    }

    // Remover etapas deletadas
    for (var idExistente in idsExistentes) {
      if (!idsNovos.contains(idExistente)) {
        print('🗑️ [PROJETO_SERVICE] PROCESSAR_ETAPAS - Removendo etapa: $idExistente');
        await _supabase
            .from('etapas')
            .delete()
            .eq('id', idExistente);
      }
    }

    // Recalcular total da meta
    await _recalcularTotalMeta(metaId);
  }

  // ============================================
  // CÁLCULOS AUTOMÁTICOS (Regras 4, 5, 6)
  // ============================================

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

    print('📊 [PROJETO_SERVICE] RECALCULAR_META - Meta $metaId - Total Etapas: $totalEtapas, Saldo: $saldoMeta');
  }

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

    print('📊 [PROJETO_SERVICE] RECALCULAR_PROJETO - Projeto $projetoId - Total Metas: $totalMetas, Saldo: $saldo');
  }

  Future<void> recalcularTotais(String projetoId) async {
    print('📋 [PROJETO_SERVICE] RECALCULAR_TOTAIS - Projeto ID: $projetoId');
    await _recalcularTotaisProjeto(projetoId);
  }

  // ============================================
  // VALIDAÇÃO (Regra 8)
  // ============================================

  Future<bool> podeAprovar(String projetoId) async {
    print('📋 [PROJETO_SERVICE] PODE_APROVAR - Verificando projeto ID: $projetoId');

    try {
      final projeto = await getCompleto(projetoId);

      if (projeto.metas.isEmpty) {
        print('⚠️ [PROJETO_SERVICE] PODE_APROVAR - Projeto sem metas');
        throw Exception('Projeto não pode ser aprovado sem metas');
      }

      for (var meta in projeto.metas) {
        if (meta.etapas.isEmpty) {
          print('⚠️ [PROJETO_SERVICE] PODE_APROVAR - Meta sem etapas: ${meta.descricao}');
          throw Exception('Meta "${meta.descricao}" não tem etapas');
        }
      }

      print('✅ [PROJETO_SERVICE] PODE_APROVAR - Projeto pode ser aprovado');
      return true;
    } catch (e) {
      print('❌ [PROJETO_SERVICE] PODE_APROVAR - Erro: $e');
      rethrow;
    }
  }
}