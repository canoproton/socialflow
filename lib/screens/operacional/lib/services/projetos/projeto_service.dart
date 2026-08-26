/// ============================================
/// SERVIÇO: Projeto (CRUD + Metas + Etapas)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';

class ProjetoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // CRUD - PROJETO (COM METAS E ETAPAS)
  // ============================================

  /// Listar todos projetos com filtros (Regra 13)
  Future<List<ProjetoModel>> list({
    String? search,
    String? status,
    String? proponenteId,
    String? gerenteId,
    DateTime? dataInicio,
    DateTime? dataFim,
    double? valorMin,
    double? valorMax,
  }) async {
    try {
      var query = _supabase
          .from('projetos')
          .select()
          .order('created_at', ascending: false);

      // Filtros (Regra 13)
      if (search != null && search.isNotEmpty) {
        query = query.or(
          'descricao.ilike.%$search%,'
          'processo.ilike.%$search%,'
          'obs.ilike.%$search%'
        );
      }

      if (status != null && status.isNotEmpty) {
        query = query.eq('status_projeto', status);
      }

      if (proponenteId != null && proponenteId.isNotEmpty) {
        query = query.eq('proponente', proponenteId);
      }

      if (gerenteId != null && gerenteId.isNotEmpty) {
        query = query.eq('gerente_projeto', gerenteId);
      }

      if (dataInicio != null) {
        query = query.gte('data_entrega', dataInicio.toIso8601String());
      }

      if (dataFim != null) {
        query = query.lte('data_entrega', dataFim.toIso8601String());
      }

      if (valorMin != null) {
        query = query.gte('valor_aprovado', valorMin);
      }

      if (valorMax != null) {
        query = query.lte('valor_aprovado', valorMax);
      }

      final response = await query;

      return (response as List)
          .map((item) => ProjetoModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar projetos: $e');
    }
  }

  /// Buscar projeto por ID com todos relacionamentos
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

  /// Buscar projeto completo (com metas e etapas)
  Future<ProjetoModel> getCompleto(String id) async {
    try {
      // 1. Buscar projeto
      final projeto = await getById(id);
      if (projeto == null) throw Exception('Projeto não encontrado');

      // 2. Buscar metas
      final metasResponse = await _supabase
          .from('meta_projetos')
          .select()
          .eq('projeto_id', id)
          .order('sequencia', ascending: true);

      final metas = (metasResponse as List)
          .map((item) => MetaModel.fromJson(item))
          .toList();

      // 3. Buscar etapas para cada meta
      for (var i = 0; i < metas.length; i++) {
        final etapasResponse = await _supabase
            .from('etapas')
            .select()
            .eq('meta_projeto_id', metas[i].id)
            .order('sequencia', ascending: true);

        metas[i] = metas[i].copyWith(
          etapas: (etapasResponse as List)
              .map((item) => EtapaModel.fromJson(item))
              .toList(),
        );
      }

      // 4. Calcular totais (Regra 5)
      final totais = _calcularTotaisProjeto(metas);
      
      return projeto.copyWith(
        metas: metas,
        valorTotalMetas: totais['totalMetas'],
        saldoProjeto: (projeto.valorTotalAportado ?? 0) - totais['totalMetas']!,
      );
    } catch (e) {
      throw Exception('Erro ao buscar projeto completo: $e');
    }
  }

  /// CRIAR PROJETO COMPLETO (COM METAS E ETAPAS)
  Future<ProjetoModel> createCompleto(Map<String, dynamic> data) async {
    try {
      // 1. Validar processo (Regra 1)
      if (data['processo'] != null) {
        if (!ProjetoModel.validarProcesso(data['processo'])) {
          throw Exception('Formato de processo inválido. Use: XXXXX-XXXXXXXX/XXXX-XX');
        }
      }

      // 2. Extrair metas do payload
      final metasData = data.remove('metas') as List? ?? [];
      
      // 3. Criar projeto
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

      // 4. Criar metas e etapas
      List<MetaModel> metasCriadas = [];
      for (var i = 0; i < metasData.length; i++) {
        final metaPayload = metasData[i];
        
        // Extrair etapas da meta
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
        List<EtapaModel> etapasCriadas = [];

        // Criar etapas da meta
        for (var j = 0; j < etapasData.length; j++) {
          final etapaPayload = etapasData[j];
          
          // Calcular valor_etapa (Regra 4)
          final valorUnitario = (etapaPayload['valor_unitario'] ?? 0.0).toDouble();
          final quantidade = (etapaPayload['quantidade'] ?? 0.0).toDouble();
          final valorEtapa = valorUnitario * quantidade;

          final etapaResponse = await _supabase
              .from('etapas')
              .insert({
                ...etapaPayload,
                'meta_projeto_id': meta.id,
                'sequencia': j + 1,
                'valor_etapa': valorEtapa,
              })
              .select()
              .single();
          
          etapasCriadas.add(EtapaModel.fromJson(etapaResponse));
        }

        // Atualizar meta com etapas
        meta.etapas = etapasCriadas;
        
        // Recalcular total_etapas da meta (Regra 4)
        final totalEtapas = _calcularTotalEtapas(etapasCriadas);
        await _supabase
            .from('meta_projetos')
            .update({
              'valor_total_etapas': totalEtapas,
              'saldo_meta': (meta.vlMetaAprov ?? 0) - totalEtapas,
            })
            .eq('id', meta.id);

        metasCriadas.add(meta);
      }

      // 5. Recalcular totais do projeto (Regra 5)
      await _recalcularTotaisProjeto(projeto.id);

      // 6. Buscar projeto completo atualizado
      return await getCompleto(projeto.id);
      
    } catch (e) {
      throw Exception('Erro ao criar projeto completo: $e');
    }
  }

  /// ATUALIZAR PROJETO COMPLETO (COM METAS E ETAPAS)
  Future<ProjetoModel> updateCompleto(String id, Map<String, dynamic> data) async {
    try {
      // 1. Validar processo se foi alterado (Regra 1)
      if (data.containsKey('processo') && data['processo'] != null) {
        if (!ProjetoModel.validarProcesso(data['processo'])) {
          throw Exception('Formato de processo inválido. Use: XXXXX-XXXXXXXX/XXXX-XX');
        }
      }

      // 2. Extrair metas do payload
      final metasData = data.remove('metas') as List? ?? [];

      // 3. Atualizar dados básicos do projeto
      final response = await _supabase
          .from('projetos')
          .update({
            ...data,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      var projeto = ProjetoModel.fromJson(response);

      // 4. Buscar metas existentes
      final metasExistentes = await _supabase
          .from('meta_projetos')
          .select('id')
          .eq('projeto_id', id);

      final idsExistentes = (metasExistentes as List)
          .map((m) => m['id'].toString())
          .toList();

      final idsNovos = <String>[];

      // 5. Processar metas
      for (var i = 0; i < metasData.length; i++) {
        final metaPayload = metasData[i];
        final metaId = metaPayload['id'] as String?;
        
        // Extrair etapas
        final etapasData = metaPayload.remove('etapas') as List? ?? [];

        if (metaId != null && idsExistentes.contains(metaId)) {
          // Atualizar meta existente
          await _supabase
              .from('meta_projetos')
              .update({
                ...metaPayload,
                'atualizado_em': DateTime.now().toIso8601String(),
              })
              .eq('id', metaId);
          
          idsNovos.add(metaId);

          // Processar etapas da meta
          await _processarEtapas(metaId, etapasData);
          
        } else {
          // Criar nova meta
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

          // Criar etapas da nova meta
          for (var j = 0; j < etapasData.length; j++) {
            final etapaPayload = etapasData[j];
            
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

      // 6. Remover metas que não estão mais no payload
      for (var idExistente in idsExistentes) {
        if (!idsNovos.contains(idExistente)) {
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

      // 7. Recalcular totais (Regras 4, 5)
      await _recalcularTotaisProjeto(id);

      // 8. Buscar projeto completo atualizado
      return await getCompleto(id);
      
    } catch (e) {
      throw Exception('Erro ao atualizar projeto completo: $e');
    }
  }

  // ============================================
  // MÉTODOS AUXILIARES - ETAPAS
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

      // Calcular valor_etapa (Regra 4)
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
      }
    }

    // Remover etapas deletadas
    for (var idExistente in idsExistentes) {
      if (!idsNovos.contains(idExistente)) {
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

  double _calcularTotalEtapas(List<EtapaModel> etapas) {
    return etapas.fold(0, (sum, e) => sum + (e.valorEtapa ?? 0));
  }

  Map<String, double> _calcularTotaisProjeto(List<MetaModel> metas) {
    double totalMetas = 0;
    
    for (var meta in metas) {
      totalMetas += meta.valorTotalEtapas ?? 0;
    }

    return {
      'totalMetas': totalMetas,
    };
  }

  Future<void> _recalcularTotalMeta(String metaId) async {
    // Buscar todas etapas da meta
    final etapasResponse = await _supabase
        .from('etapas')
        .select('valor_etapa')
        .eq('meta_projeto_id', metaId);

    final etapas = etapasResponse as List;
    
    double totalEtapas = 0;
    for (var etapa in etapas) {
      totalEtapas += (etapa['valor_etapa'] ?? 0.0).toDouble();
    }

    // Buscar meta para pegar vl_meta_aprov
    final meta = await _supabase
        .from('meta_projetos')
        .select('vl_meta_aprov')
        .eq('id', metaId)
        .single();

    final vlMetaAprov = (meta['vl_meta_aprov'] ?? 0.0).toDouble();
    final saldoMeta = vlMetaAprov - totalEtapas;

    // Atualizar meta
    await _supabase
        .from('meta_projetos')
        .update({
          'valor_total_etapas': totalEtapas,
          'saldo_meta': saldoMeta,
          'atualizado_em': DateTime.now().toIso8601String(),
        })
        .eq('id', metaId);
  }

  Future<void> _recalcularTotaisProjeto(String projetoId) async {
    // Buscar todas metas do projeto
    final metasResponse = await _supabase
        .from('meta_projetos')
        .select('valor_total_etapas')
        .eq('projeto_id', projetoId);

    final metas = metasResponse as List;
    
    double totalMetas = 0;
    for (var meta in metas) {
      totalMetas += (meta['valor_total_etapas'] ?? 0.0).toDouble();
    }

    // Buscar projeto para pegar valor_total_aportado
    final projeto = await getById(projetoId);
    if (projeto == null) return;

    final saldo = (projeto.valorTotalAportado ?? 0) - totalMetas;

    // Atualizar projeto
    await _supabase
        .from('projetos')
        .update({
          'valor_total_metas': totalMetas,
          'saldo_projeto': saldo,
          'atualizado_em': DateTime.now().toIso8601String(),
        })
        .eq('id', projetoId);
  }

  /// Recalcular todos os totais (trigger manual)
  Future<void> recalcularTotais(String projetoId) async {
    await _recalcularTotaisProjeto(projetoId);
  }

  /// Verificar se projeto pode ser aprovado (Regra 8)
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

      final metas = metasResponse as List;

      // Deletar etapas de cada meta
      for (var meta in metas) {
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
}