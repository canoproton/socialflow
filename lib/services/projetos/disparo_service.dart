/// ============================================
/// SERVIÇO: Disparos para Ticket e ItemLancamento
/// REGRAS: 8, 9, 10
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/etapa_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/projeto_model.dart';

class DisparoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // REGRA 8: DISPARAR TODAS ETAPAS DO PROJETO
  // ============================================

  /// ⭐ REGRA 8: Quando projeto é aprovado, dispara todas as etapas
  /// - Cada etapa gera um Ticket (Regra 9)
  /// - Cada etapa gera um ItemLancamento (Regra 10)
  /// - Status do projeto muda para EXECUTANDO
  Future<void> dispararTodasEtapas(Projeto projeto) async {
    print('📋 [DISPARO_SERVICE] DISPARAR_TODAS_ETAPAS - Projeto: ${projeto.id}');

    try {
      // Verificar se o projeto tem metas e etapas
      if (projeto.metas.isEmpty) {
        throw Exception('Projeto não tem metas para disparar');
      }

      int totalEtapas = 0;
      for (var meta in projeto.metas) {
        totalEtapas += meta.etapas.length;
      }

      print('📋 [DISPARO_SERVICE] DISPARAR_TODAS_ETAPAS - Total de etapas: $totalEtapas');

      // ⭐ Disparar cada etapa
      for (var meta in projeto.metas) {
        for (var etapa in meta.etapas) {
          await _dispararEtapaIndividual(
            etapa: etapa,
            meta: meta,
            projeto: projeto,
          );
        }
      }

      // ⭐ Atualizar status do projeto para EXECUTANDO
      await _supabase
          .from('projetos')
          .update({
            'status_projeto': Projeto.STATUS_EXECUTANDO,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', projeto.id);

      print('✅ [DISPARO_SERVICE] DISPARAR_TODAS_ETAPAS - Projeto executado com sucesso');
    } catch (e) {
      print('❌ [DISPARO_SERVICE] DISPARAR_TODAS_ETAPAS - Erro: $e');
      throw Exception('Erro ao disparar todas etapas: $e');
    }
  }

  // ============================================
  // REGRA 8: DISPARAR ETAPA INDIVIDUAL
  // ============================================

  /// ⭐ REGRA 8: Dispara uma etapa individual
  /// - Gera Ticket (Regra 9)
  /// - Gera ItemLancamento (Regra 10)
  /// - Atualiza status da etapa para ACIONADO
  Future<void> _dispararEtapaIndividual({
    required EtapaModel etapa,
    required MetaModel meta,
    required Projeto projeto,
  }) async {
    print('📋 [DISPARO_SERVICE] DISPARAR_ETAPA - Etapa: ${etapa.id}');

    try {
      // ⭐ REGRA 9: Disparar para Ticket
      final ticketId = await _dispararParaTicket(etapa, meta, projeto);
      print('✅ [DISPARO_SERVICE] DISPARAR_ETAPA - Ticket criado: $ticketId');

      // ⭐ REGRA 10: Disparar para ItemLancamento
      final itemId = await _dispararParaItemLancamento(etapa, meta, projeto);
      print('✅ [DISPARO_SERVICE] DISPARAR_ETAPA - ItemLancamento criado: $itemId');

      // ⭐ Atualizar status da etapa para ACIONADO
      await _supabase
          .from('etapas')
          .update({
            'status': EtapaModel.STATUS_ACIONADO,
            'lancamento_etapa': itemId,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', etapa.id);

      print('✅ [DISPARO_SERVICE] DISPARAR_ETAPA - Etapa acionada: ${etapa.id}');
    } catch (e) {
      print('❌ [DISPARO_SERVICE] DISPARAR_ETAPA - Erro: $e');
      throw Exception('Erro ao disparar etapa: $e');
    }
  }

  // ============================================
  // REGRA 9: DISPARO PARA TICKET
  // ============================================

  /// ⭐ REGRA 9: Mapeamento Etapa → Ticket
  /// Campos da Etapa → Campos do Ticket:
  /// - id → projeto
  /// - rubrica → title
  /// - descricao → description
  /// - data_inicio → created_at
  /// - data_vencimento → due_date
  /// - executor → assignee
  /// - ACTIVE → status
  /// - usuario logado → atualizado_por
  /// - data atual → atualizado_em
  Future<String> _dispararParaTicket(
    EtapaModel etapa,
    MetaModel meta,
    Projeto projeto,
  ) async {
    try {
      final response = await _supabase
          .from('tickets')
          .insert({
            'projeto': projeto.id,
            'title': 'Etapa: ${etapa.descricao ?? 'Sem título'}',
            'description': '''
Projeto: ${projeto.descricao ?? 'Sem descrição'}
Meta: ${meta.descricao ?? 'Sem descrição'}
Etapa: ${etapa.descricao ?? 'Sem descrição'}
Executor: ${etapa.executorId ?? 'Não definido'}
            ''',
            'created_at': DateTime.now().toIso8601String(),
            'due_date': etapa.dataVencimento?.toIso8601String(),
            'assignee': etapa.executorId ?? projeto.gerenteProjetoId,
            'status': 'ACTIVE', // ⭐ Status ACTIVE (Regra 9)
            'priority': 'MÉDIA',
            'atualizado_por': etapa.atualizadoPor,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      print('✅ [DISPARO_SERVICE] TICKET - Criado com ID: ${response['id']}');
      return response['id'].toString();
    } catch (e) {
      print('❌ [DISPARO_SERVICE] TICKET - Erro: $e');
      throw Exception('Erro ao disparar para ticket: $e');
    }
  }

  // ============================================
  // REGRA 10: DISPARO PARA ITEMLANCAMENTO
  // ============================================

  /// ⭐ REGRA 10: Mapeamento Etapa → ItemLancamento
  /// Campos da Tabela Etapa/Projeto → Campos do ItemLancamento:
  /// - etapa.id → relacionamento_id
  /// - projeto.conta → conta_corrente
  /// - etapa.descricao → descricao
  /// - etapa.valor_etapa → valor_lancamento
  /// - etapa.data_inicio → data_lancamento
  /// - "False" → efetivado
  /// - etapa.area → centro_custo
  /// - projeto.recursos → fonte_recurso
  /// - etapa.rubrica → rubrica
  /// - "D" → natureza
  /// - etapa.executor → executor
  /// - usuario logado → atualizado_por
  /// - data atual → atualizado_em
  Future<String> _dispararParaItemLancamento(
    EtapaModel etapa,
    MetaModel meta,
    Projeto projeto,
  ) async {
    try {
      final response = await _supabase
          .from('itens_lancamento')
          .insert({
            'relacionamento_id': etapa.id,
            'conta_corrente': projeto.contaId,
            'descricao': '''
Etapa: ${etapa.descricao ?? 'Sem descrição'}
Meta: ${meta.descricao ?? 'Sem descrição'}
Projeto: ${projeto.descricao ?? 'Sem descrição'}
            ''',
            'valor_lancamento': etapa.valorEtapa ?? 0,
            'data_lancamento': etapa.dataInicio?.toIso8601String(),
            'efetivado': false, // ⭐ SEMPRE FALSE NA CRIAÇÃO (Regra 10)
            'centro_custo': etapa.areaId,
            'fonte_recurso': projeto.recursos?.firstOrNull,
            'rubrica': etapa.rubricaId,
            'natureza': 'D', // ⭐ SEMPRE DÉBITO (Regra 10)
            'executor': etapa.executorId,
            'atualizado_por': etapa.atualizadoPor,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      print('✅ [DISPARO_SERVICE] ITEMLANCAMENTO - Criado com ID: ${response['id']}');
      return response['id'].toString();
    } catch (e) {
      print('❌ [DISPARO_SERVICE] ITEMLANCAMENTO - Erro: $e');
      throw Exception('Erro ao disparar para item lançamento: $e');
    }
  }

  // ============================================
  // REGRA 8: CONCLUIR ETAPA (QUANDO TAREFA FINALIZADA)
  // ============================================

  /// ⭐ REGRA 8: Quando tarefa é concluída no módulo Tarefas
  /// - Atualiza ItemLancamento: efetivado = true
  /// - Atualiza status da etapa: CONCLUIDA
  Future<void> concluirEtapa(String etapaId) async {
    print('📋 [DISPARO_SERVICE] CONCLUIR_ETAPA - Etapa: $etapaId');

    try {
      // ⭐ Buscar ItemLancamento relacionado
      final response = await _supabase
          .from('itens_lancamento')
          .select()
          .eq('relacionamento_id', etapaId)
          .maybeSingle();

      if (response != null) {
        // ⭐ Atualizar efetivado para TRUE (Regra 8)
        await _supabase
            .from('itens_lancamento')
            .update({
              'efetivado': true,
              'data_efetivacao': DateTime.now().toIso8601String(),
              'atualizado_em': DateTime.now().toIso8601String(),
            })
            .eq('id', response['id']);

        print('✅ [DISPARO_SERVICE] CONCLUIR_ETAPA - ItemLancamento atualizado: ${response['id']}');
      }

      // ⭐ Atualizar status da etapa para CONCLUIDA
      await _supabase
          .from('etapas')
          .update({
            'status': EtapaModel.STATUS_CONCLUIDA,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', etapaId);

      print('✅ [DISPARO_SERVICE] CONCLUIR_ETAPA - Etapa concluída: $etapaId');
    } catch (e) {
      print('❌ [DISPARO_SERVICE] CONCLUIR_ETAPA - Erro: $e');
      throw Exception('Erro ao concluir etapa: $e');
    }
  }

  // ============================================
  // REGRA 8: VERIFICAR ETAPAS DISPARADAS
  // ============================================

  /// ⭐ Verifica se todas as etapas de um projeto foram disparadas
  Future<bool> verificarDisparos(String projetoId) async {
    print('📋 [DISPARO_SERVICE] VERIFICAR_DISPAROS - Projeto: $projetoId');

    try {
      // Buscar todas etapas do projeto
      final metasResponse = await _supabase
          .from('meta_projetos')
          .select('id')
          .eq('projeto_id', projetoId);

      for (var meta in metasResponse) {
        final etapasResponse = await _supabase
            .from('etapas')
            .select('status')
            .eq('meta_projeto_id', meta['id']);

        for (var etapa in etapasResponse) {
          if (etapa['status'] != EtapaModel.STATUS_ACIONADO &&
              etapa['status'] != EtapaModel.STATUS_CONCLUIDA) {
            print('⚠️ [DISPARO_SERVICE] VERIFICAR_DISPAROS - Etapa não disparada: ${etapa['id']}');
            return false;
          }
        }
      }

      print('✅ [DISPARO_SERVICE] VERIFICAR_DISPAROS - Todas as etapas foram disparadas');
      return true;
    } catch (e) {
      print('❌ [DISPARO_SERVICE] VERIFICAR_DISPAROS - Erro: $e');
      return false;
    }
  }
}