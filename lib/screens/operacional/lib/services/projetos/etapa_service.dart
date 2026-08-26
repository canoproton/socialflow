/// ============================================
/// SERVIÇO: Etapa da Meta (CRUD + Cálculos + Disparos)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/projetos/etapa_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/projeto_model.dart';
import 'meta_service.dart';
import 'projeto_service.dart';
import 'disparo_service.dart';

class EtapaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final MetaService _metaService = MetaService();
  final ProjetoService _projetoService = ProjetoService();
  final DisparoService _disparoService = DisparoService();

  // ============================================
  // CRUD - ETAPA
  // ============================================

  /// Listar etapas por meta
  Future<List<EtapaModel>> getByMeta(String metaId) async {
    try {
      final response = await _supabase
          .from('etapas')
          .select()
          .eq('meta_projeto_id', metaId)
          .order('sequencia', ascending: true);

      return (response as List)
          .map((item) => EtapaModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar etapas da meta: $e');
    }
  }

  /// Buscar etapa por ID
  Future<EtapaModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('etapas')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return EtapaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar etapa: $e');
    }
  }

  /// Criar etapa (Regra 4 - calcula valor_etapa automaticamente)
  Future<EtapaModel> create(Map<String, dynamic> data) async {
    try {
      // Buscar última sequência
      final metaId = data['meta_projeto_id'];
      final etapasExistentes = await getByMeta(metaId);
      final proximaSequencia = etapasExistentes.length + 1;

      // Calcular valor_etapa (Regra 4)
      final valorUnitario = (data['valor_unitario'] ?? 0.0).toDouble();
      final quantidade = (data['quantidade'] ?? 0.0).toDouble();
      final valorEtapa = valorUnitario * quantidade;

      final response = await _supabase
          .from('etapas')
          .insert({
            ...data,
            'sequencia': proximaSequencia,
            'valor_etapa': valorEtapa,
          })
          .select()
          .single();

      final etapa = EtapaModel.fromJson(response);

      // Recalcular total da meta (Regra 4)
      await _metaService.recalcularTotalEtapas(etapa.metaId);

      return etapa;
    } catch (e) {
      throw Exception('Erro ao criar etapa: $e');
    }
  }

  /// Atualizar etapa (Regra 4 - recalcula valor_etapa)
  Future<EtapaModel> update(String id, Map<String, dynamic> data) async {
    try {
      // Buscar etapa atual para recálculo
      final etapaAtual = await getById(id);
      if (etapaAtual == null) throw Exception('Etapa não encontrada');

      // Atualizar valores
      final valorUnitario = data['valor_unitario'] ?? etapaAtual.valorUnitario ?? 0;
      final quantidade = data['quantidade'] ?? etapaAtual.quantidade ?? 0;
      final valorEtapa = (valorUnitario as double) * (quantidade as double);

      final response = await _supabase
          .from('etapas')
          .update({
            ...data,
            'valor_etapa': valorEtapa,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final etapa = EtapaModel.fromJson(response);

      // Recalcular total da meta (Regra 4)
      await _metaService.recalcularTotalEtapas(etapa.metaId);

      return etapa;
    } catch (e) {
      throw Exception('Erro ao atualizar etapa: $e');
    }
  }

  /// Deletar etapa
  Future<void> delete(String id) async {
    try {
      // Buscar etapa para pegar meta_id
      final etapa = await getById(id);
      if (etapa == null) return;

      await _supabase
          .from('etapas')
          .delete()
          .eq('id', id);

      // Recalcular total da meta (Regra 4)
      await _metaService.recalcularTotalEtapas(etapa.metaId);
    } catch (e) {
      throw Exception('Erro ao deletar etapa: $e');
    }
  }

  // ============================================
  // CÁLCULOS AUTOMÁTICOS (Regra 4)
  // ============================================

  /// Calcular valor_etapa (Regra 4)
  double calcularValorEtapa(double valorUnitario, double quantidade) {
    return valorUnitario * quantidade;
  }

  /// Reordenar etapas (após exclusão/inserção)
  Future<void> reordenarEtapas(String metaId) async {
    try {
      final etapas = await getByMeta(metaId);
      
      for (var i = 0; i < etapas.length; i++) {
        await _supabase
            .from('etapas')
            .update({'sequencia': i + 1})
            .eq('id', etapas[i].id);
      }
    } catch (e) {
      throw Exception('Erro ao reordenar etapas: $e');
    }
  }

  // ============================================
  // DISPAROS AUTOMÁTICOS (Regras 8, 9, 10)
  // ============================================

  /// Disparar etapa para Ticket e ItemLancamento (Regra 8)
  Future<void> dispararEtapa(String etapaId) async {
    try {
      // Buscar etapa completa
      final etapa = await getById(etapaId);
      if (etapa == null) throw Exception('Etapa não encontrada');

      // Buscar meta
      final meta = await _metaService.getById(etapa.metaId);
      if (meta == null) throw Exception('Meta não encontrada');

      // Buscar projeto
      final projeto = await _projetoService.getById(meta.projetoId);
      if (projeto == null) throw Exception('Projeto não encontrado');

      // Disparar para Ticket (Regra 9)
      await _disparoService.dispararParaTicket(
        etapa: etapa,
        projeto: projeto,
        meta: meta,
      );

      // Disparar para ItemLancamento (Regra 10)
      await _disparoService.dispararParaItemLancamento(
        etapa: etapa,
        projeto: projeto,
        meta: meta,
        efetivado: false,
      );

      // Atualizar status da etapa
      await _supabase
          .from('etapas')
          .update({
            'status': EtapaModel.STATUS_ACIONADO,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', etapaId);

    } catch (e) {
      throw Exception('Erro ao disparar etapa: $e');
    }
  }

  /// Disparar todas etapas de um projeto (Regra 8)
  Future<void> dispararTodasEtapas(String projetoId) async {
    try {
      // Buscar projeto completo
      final projeto = await _projetoService.getCompleto(projetoId);
      
      // Verificar se pode aprovar (Regra 8)
      await _projetoService.podeAprovar(projetoId);

      // Disparar cada etapa
      for (var meta in projeto.metas) {
        for (var etapa in meta.etapas) {
          await dispararEtapa(etapa.id);
        }
      }

      // Atualizar status do projeto
      await _supabase
          .from('projetos')
          .update({
            'status_projeto': ProjetoModel.STATUS_EXECUTANDO,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', projetoId);

    } catch (e) {
      throw Exception('Erro ao disparar todas etapas: $e');
    }
  }

  /// Concluir etapa (quando tarefa finalizada) (Regra 8)
  Future<void> concluirEtapa(String etapaId) async {
    try {
      // Buscar etapa
      final etapa = await getById(etapaId);
      if (etapa == null) throw Exception('Etapa não encontrada');

      // Atualizar ItemLancamento (efetivado = true) (Regra 8)
      await _disparoService.concluirItemLancamento(etapaId);

      // Atualizar status da etapa
      await _supabase
          .from('etapas')
          .update({
            'status': EtapaModel.STATUS_CONCLUIDA,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', etapaId);

      // Recalcular totais
      await _metaService.recalcularTotalEtapas(etapa.metaId);

    } catch (e) {
      throw Exception('Erro ao concluir etapa: $e');
    }
  }
}