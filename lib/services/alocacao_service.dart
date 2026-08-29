import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fontes_base.dart';
import '../models/fonte_alocacao.dart';
import '../models/alocacao_pesquisa_filtro.dart';

class AlocacaoService {
  final supabase = Supabase.instance.client;

  /// Pesquisa fontes de recurso com base nos filtros
  Future<List<Map<String, dynamic>>> pesquisarFontes(
    AlocacaoPesquisaFiltro filtro
  ) async {
    try {
      var query = supabase
          .from('fontes_base')
          .select('*');
      
      if (filtro.entidade != null && filtro.entidade!.isNotEmpty) {
        query = query.ilike('entidade', '%${filtro.entidade}%');
      }

      if (filtro.dataInicio != null) {
        query = query.gte('data_aprovacao', filtro.dataInicio!.toIso8601String());
      }
      if (filtro.dataFim != null) {
        query = query.lte('data_aprovacao', filtro.dataFim!.toIso8601String());
      }

      final fontesResult = await query;
      final fontes = fontesResult.map((data) => FontesBase.fromJson(data)).toList();

      if (fontes.isEmpty) {
        return [];
      }

      final alocacoesResult = await supabase
          .from('fonte_alocacao')
          .select('*')
          .inFilter('fonte_alocacao_id', fontes.map((f) => f.id).toList());

      final alocacoes = alocacoesResult.map((data) => FonteAlocacao.fromJson(data)).toList();

      List<Map<String, dynamic>> resultado = [];

      for (var fonte in fontes) {
        final alocacoesFonte = alocacoes
            .where((a) => a.fonte_alocacao_id == fonte.id)
            .toList();
        
        final totalAlocado = alocacoesFonte.fold(0.0, (sum, a) => sum + a.valor_alocado);
        final saldo = fonte.valor_recurso - totalAlocado;

        if (filtro.comSaldo == true && saldo <= 0) {
          continue;
        }

        if (filtro.projetoId != null && filtro.projetoId!.isNotEmpty) {
          final temProjeto = alocacoesFonte.any((a) => a.destino_alocao_id == filtro.projetoId);
          if (!temProjeto) {
            continue;
          }
        }

        resultado.add({
          'fonte': fonte,
          'total_alocado': totalAlocado,
          'saldo': saldo,
          'alocacoes': alocacoesFonte,
        });
      }

      return resultado;

    } catch (e) {
      print('Erro ao pesquisar fontes: $e');
      rethrow;
    }
  }

  /// Busca o extrato completo de uma fonte
  Future<Map<String, dynamic>> getExtratoFonte(String fonteId) async {
    try {
      final fonteResult = await supabase
          .from('fontes_base')
          .select('*')
          .eq('id', fonteId)
          .single();
      
      final fonte = FontesBase.fromJson(fonteResult);

      final alocacoesResult = await supabase
          .from('fonte_alocacao')
          .select('''
            *,
            projeto:projeto!destino_alocao_id(*)
          ''')
          .eq('fonte_alocacao_id', fonteId)
          .order('data_alocacao', ascending: true);

      final alocacoes = alocacoesResult.map((data) => FonteAlocacao.fromJson(data)).toList();

      final saldoInicial = fonte.valor_recurso;
      double saldoAcumulado = saldoInicial;

      List<Map<String, dynamic>> extrato = [];

      extrato.add({
        'tipo': 'SALDO_INICIAL',
        'data': fonte.data_aprovacao,
        'destino': 'Entrada do recurso na fonte',
        'valor': saldoInicial,
        'saldo': saldoInicial,
        'isSaldoInicial': true,
      });

      for (var alocacao in alocacoes) {
        saldoAcumulado -= alocacao.valor_alocado;
        extrato.add({
          'tipo': 'ALOCACAO',
          'data': alocacao.data_alocacao,
          'destino': alocacao.projeto?.descricao ?? alocacao.destino_alocao_id,
          'valor': alocacao.valor_alocado,
          'saldo': saldoAcumulado,
          'descricao': alocacao.descricao,
          'isSaldoInicial': false,
          'alocacao': alocacao,
        });
      }

      return {
        'fonte': fonte,
        'extrato': extrato,
        'total_alocado': saldoInicial - saldoAcumulado,
        'saldo_atual': saldoAcumulado,
        'saldo_inicial': saldoInicial,
      };

    } catch (e) {
      print('Erro ao buscar extrato: $e');
      rethrow;
    }
  }

  /// ✅ NOVO: Salva uma alocação
  Future<void> saveAlocacao(FonteAlocacao alocacao) async {
    try {
      // Busca o saldo atual da fonte
      final extrato = await getExtratoFonte(alocacao.fonte_alocacao_id);
      final saldoAtual = extrato['saldo_atual'] as double;

      // Valida se há saldo suficiente
      if (alocacao.valor_alocado > saldoAtual) {
        throw Exception('Saldo insuficiente. Disponível: $saldoAtual');
      }

      // Insere a alocação
      await supabase
          .from('fonte_alocacao')
          .insert(alocacao.toJson());

      // Atualiza o campo saldo_recurso no projeto (opcional)
      await _atualizarAporteProjeto(alocacao.destino_alocao_id);

    } catch (e) {
      print('Erro ao salvar alocação: $e');
      rethrow;
    }
  }

  Future<void> _atualizarAporteProjeto(String projetoId) async {
    final alocacoesResult = await supabase
        .from('fonte_alocacao')
        .select('valor_alocado')
        .eq('destino_alocao_id', projetoId);

    double total = 0;
    for (var item in alocacoesResult) {
      total += (item['valor_alocado'] ?? 0).toDouble();
    }

    await supabase
        .from('projeto')
        .update({'valor_total_aportado': total})
        .eq('id', projetoId);
  }
}