/// ============================================
/// SERVIÇO: Disparos (Ticket e ItemLancamento)
/// Regras: 8, 9, 10
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/etapa_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/projeto_model.dart';
import '../../utils/projetos/constants.dart';

class DisparoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Disparar TODAS etapas do projeto (Regra 8)
  Future<void> dispararTodasEtapas(ProjetoModel projeto) async {
    try {
      for (var meta in projeto.metas) {
        for (var etapa in meta.etapas) {
          await _dispararEtapaIndividual(etapa, meta, projeto);
        }
      }

      // Atualizar status do projeto
      await _supabase
          .from('projetos')
          .update({
            'status_projeto': ProjetoModel.STATUS_EXECUTANDO,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', projeto.id);

    } catch (e) {
      throw Exception('Erro ao disparar todas etapas: $e');
    }
  }

  /// Disparar etapa individual (Regra 9 e 10)
  Future<void> _dispararEtapaIndividual(
    EtapaModel etapa,
    MetaModel meta,
    ProjetoModel projeto,
  ) async {
    // Disparar para Ticket (Regra 9)
    await _dispararParaTicket(etapa, meta, projeto);

    // Disparar para ItemLancamento (Regra 10)
    await _dispararParaItemLancamento(etapa, meta, projeto);

    // Atualizar status da etapa
    await _supabase
        .from('etapas')
        .update({
          'status': EtapaModel.STATUS_ACIONADO,
          'atualizado_em': DateTime.now().toIso8601String(),
        })
        .eq('id', etapa.id);
  }

  /// Disparo para Ticket (Regra 9)
  Future<void> _dispararParaTicket(
    EtapaModel etapa,
    MetaModel meta,
    ProjetoModel projeto,
  ) async {
    try {
      await _supabase
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
            'status': ProjetoConstants.TICKET_STATUS_ACTIVE,
            'priority': ProjetoConstants.PRIORIDADE_MEDIA,
            'atualizado_por': etapa.atualizadoPor,
            'atualizado_em': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Erro ao disparar para ticket: $e');
    }
  }

  /// Disparo para ItemLancamento (Regra 10)
  Future<void> _dispararParaItemLancamento(
    EtapaModel etapa,
    MetaModel meta,
    ProjetoModel projeto,
  ) async {
    try {
      await _supabase
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
            'efetivado': false,
            'centro_custo': etapa.areaId,
            'fonte_recurso': projeto.recursos?.firstOrNull,
            'rubrica': etapa.rubricaId,
            'natureza': ProjetoConstants.NATUREZA_DEBITO,
            'executor': etapa.executorId,
            'atualizado_por': etapa.atualizadoPor,
            'atualizado_em': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Erro ao disparar para item lançamento: $e');
    }
  }

  /// Concluir ItemLancamento (Regra 8 - quando tarefa finalizada)
  Future<void> concluirItemLancamento(String etapaId) async {
    try {
      // Buscar item lançamento relacionado
      final response = await _supabase
          .from('itens_lancamento')
          .select()
          .eq('relacionamento_id', etapaId)
          .maybeSingle();

      if (response != null) {
        // Atualizar efetivado para true
        await _supabase
            .from('itens_lancamento')
            .update({
              'efetivado': true,
              'data_efetivacao': DateTime.now().toIso8601String(),
              'atualizado_em': DateTime.now().toIso8601String(),
            })
            .eq('id', response['id']);
      }

      // Atualizar status da etapa
      await _supabase
          .from('etapas')
          .update({
            'status': EtapaModel.STATUS_CONCLUIDA,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', etapaId);

    } catch (e) {
      throw Exception('Erro ao concluir item lançamento: $e');
    }
  }
}