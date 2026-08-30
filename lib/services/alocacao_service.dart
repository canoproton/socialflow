import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fontes_base.dart';
import '../models/fonte_alocacao.dart';
import '../models/alocacao_pesquisa_filtro.dart';

class AlocacaoService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Pesquisa fontes de recurso com filtros
  Future<List<AlocacaoPesquisaResult>> pesquisarFontes(
    String filtro, {
    bool apenasComSaldo = false,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? projetoId,
  }) async {
    try {
      print('🔍 [ALOCACAO_SERVICE] Filtro entidade: $filtro');
      print('🔍 [ALOCACAO_SERVICE] apenasComSaldo: $apenasComSaldo');
      print('🔍 [ALOCACAO_SERVICE] dataInicio: $dataInicio');
      print('🔍 [ALOCACAO_SERVICE] dataFim: $dataFim');
      print('🔍 [ALOCACAO_SERVICE] projetoId: $projetoId');

      // 1. Buscar fontes base pelo filtro
      var query = supabase.from('fontes_base').select('*');

      if (filtro.isNotEmpty) {
        query = query.or(
          'descricao.ilike.%$filtro%,entidade.ilike.%$filtro%'
        );
      }

      final response = await query;
      final List<dynamic> fontes = response as List<dynamic>;

      print('🔍 [ALOCACAO_SERVICE] Fontes encontradas: ${fontes.length}');

      if (fontes.isEmpty) {
        return [];
      }

      // 2. Buscar alocações - ✅ CORREÇÃO: sem aspas simples nos UUIDs
      final ids = fontes.map((f) => f['id']).join(',');
      print('🔍 [ALOCACAO_SERVICE] IDs das fontes: $ids');

      final alocacoesResult = await supabase
          .from('fonte_alocacao')
          .select('''
            *,
            fonte:fontes_base!fonte_alocacao_id(*),
            destino:projeto!destino_alocao_id(*)
          ''')
          .filter(
            'fonte_alocacao_id',
            'in',
            '($ids)' // ✅ SEM aspas simples
          );

      // 3. Processar e agrupar resultados
      final Map<String, List<FonteAlocacao>> alocacoesPorFonte = {};

      for (var alocacao in alocacoesResult) {
        final fonteId = alocacao['fonte_alocacao_id'] as String;
        if (!alocacoesPorFonte.containsKey(fonteId)) {
          alocacoesPorFonte[fonteId] = [];
        }
        alocacoesPorFonte[fonteId]!.add(FonteAlocacao.fromJson(alocacao));
      }

      // 4. Montar resultados
      final List<AlocacaoPesquisaResult> resultados = [];

      for (var fonteJson in fontes) {
        final fonte = FontesBase.fromJson(fonteJson);
        final alocacoes = alocacoesPorFonte[fonte.id] ?? [];

        // Calcular totais
        final totalAlocado = alocacoes.fold<double>(
          0, (sum, a) => sum + (a.valor_alocado ?? 0)
        );
        final saldo = (fonte.valor_recurso ?? 0) - totalAlocado;

        // Aplicar filtro de saldo
        if (apenasComSaldo && saldo <= 0) {
          continue;
        }

        // Aplicar filtro de projeto (se necessário)
        if (projetoId != null && projetoId.isNotEmpty) {
          final temAlocacaoNoProjeto = alocacoes.any(
            (a) => a.destino_alocao_id == projetoId
          );
          if (!temAlocacaoNoProjeto) {
            continue;
          }
        }

        // Aplicar filtro de data (se necessário)
        if (dataInicio != null || dataFim != null) {
          final alocacoesFiltradas = alocacoes.where((a) {
            bool atendeData = true;
            if (dataInicio != null && a.data_alocacao != null) {
              if (a.data_alocacao!.isBefore(dataInicio!)) {
                atendeData = false;
              }
            }
            if (dataFim != null && a.data_alocacao != null) {
              if (a.data_alocacao!.isAfter(dataFim!)) {
                atendeData = false;
              }
            }
            return atendeData;
          }).toList();

          if (alocacoesFiltradas.isEmpty) {
            continue;
          }

          final totalAlocadoFiltrado = alocacoesFiltradas.fold<double>(
            0, (sum, a) => sum + (a.valor_alocado ?? 0)
          );
          final saldoFiltrado = (fonte.valor_recurso ?? 0) - totalAlocadoFiltrado;

          resultados.add(
            AlocacaoPesquisaResult(
              fonte: fonte,
              alocacoes: alocacoesFiltradas,
              totalAlocado: totalAlocadoFiltrado,
              saldo: saldoFiltrado,
            )
          );
        } else {
          resultados.add(
            AlocacaoPesquisaResult(
              fonte: fonte,
              alocacoes: alocacoes,
              totalAlocado: totalAlocado,
              saldo: saldo,
            )
          );
        }
      }

      print('✅ [PESQUISA] Resultados: ${resultados.length}');
      return resultados;
    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao pesquisar fontes: $e');
      return [];
    }
  }

  /// Busca extrato de alocações de uma fonte específica
  Future<List<FonteAlocacao>> getExtratoFonte(String fonteId) async {
    try {
      print('📋 [ALOCACAO_SERVICE] Buscando extrato da fonte: $fonteId');

      final result = await supabase
          .from('fonte_alocacao')
          .select('''
            *,
            destino:projeto!destino_alocao_id(*)
          ''')
          .eq('fonte_alocacao_id', fonteId)
          .order('data_alocacao', ascending: true);

      final alocacoes = (result as List)
          .map((e) => FonteAlocacao.fromJson(e))
          .toList();

      print('✅ [ALOCACAO_SERVICE] Extrato encontrado: ${alocacoes.length} alocações');
      return alocacoes;
    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao buscar extrato: $e');
      return [];
    }
  }

  /// Salva (cria ou atualiza) uma alocação
  Future<FonteAlocacao> saveAlocacao(FonteAlocacao alocacao) async {
    try {
      print('📋 [ALOCACAO_SERVICE] Salvando alocação...');
      print('📋 [ALOCACAO_SERVICE] Dados: ${alocacao.toJson()}');

      final result = await supabase
          .from('fonte_alocacao')
          .upsert(alocacao.toJson())
          .select()
          .single();

      print('✅ [ALOCACAO_SERVICE] Alocação salva com sucesso');
      return FonteAlocacao.fromJson(result);
    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao salvar alocação: $e');
      throw e;
    }
  }

  /// Busca uma alocação pelo ID
  Future<FonteAlocacao?> getAlocacaoById(String id) async {
    try {
      print('📋 [ALOCACAO_SERVICE] Buscando alocação por ID: $id');

      final result = await supabase
          .from('fonte_alocacao')
          .select('''
            *,
            fonte:fontes_base!fonte_alocacao_id(*),
            destino:projeto!destino_alocao_id(*)
          ''')
          .eq('id', id)
          .single();

      return FonteAlocacao.fromJson(result);
    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao buscar alocação: $e');
      return null;
    }
  }

  /// Remove uma alocação
  Future<void> deleteAlocacao(String id) async {
    try {
      print('📋 [ALOCACAO_SERVICE] Removendo alocação: $id');

      await supabase
          .from('fonte_alocacao')
          .delete()
          .eq('id', id);

      print('✅ [ALOCACAO_SERVICE] Alocação removida com sucesso');
    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao remover alocação: $e');
      throw e;
    }
  }

  /// Busca uma fonte base pelo ID
  Future<FontesBase?> getFonteBaseById(String id) async {
    try {
      final result = await supabase
          .from('fontes_base')
          .select('*')
          .eq('id', id)
          .single();

      return FontesBase.fromJson(result);
    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao buscar fonte base: $e');
      return null;
    }
  }
}

/// Modelo de resultado da pesquisa
class AlocacaoPesquisaResult {
  final FontesBase fonte;
  final List<FonteAlocacao> alocacoes;
  final double totalAlocado;
  final double saldo;

  AlocacaoPesquisaResult({
    required this.fonte,
    required this.alocacoes,
    required this.totalAlocado,
    required this.saldo,
  });

  double get percentualAlocado {
    if (fonte.valor_recurso == null || fonte.valor_recurso == 0) {
      return 0;
    }
    return (totalAlocado / fonte.valor_recurso!) * 100;
  }

  String get statusDescricao {
    if (saldo <= 0) {
      return 'Total alocado';
    }
    return 'Com saldo disponível';
  }

  Map<String, dynamic> toJson() {
    return {
      'fonte': fonte.toJson(),
      'alocacoes': alocacoes.map((e) => e.toJson()).toList(),
      'totalAlocado': totalAlocado,
      'saldo': saldo,
    };
  }
}