import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fontes_base.dart';
import '../models/fonte_alocacao.dart';
import '../models/alocacao_pesquisa_filtro.dart';

class AlocacaoService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> pesquisarFontes(
    AlocacaoPesquisaFiltro filtro
  ) async {
    try {
      var query = supabase.from('fontes_base').select('*');
      
      // Filtro por entidade
      if (filtro.entidade != null && filtro.entidade!.isNotEmpty) {
        query = query.or('descricao.ilike.%${filtro.entidade}%,entidade.ilike.%${filtro.entidade}%');
        print('🔍 [ALOCACAO_SERVICE] Filtro entidade: ${filtro.entidade}');
      }

      // Filtro por data
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

      // Busca alocações
      final alocacoesResult = await supabase
          .from('fonte_alocacao')
          .select('*')
          .filter('fonte_alocacao', 'in', '(${fontes.map((f) => "'${f.id}'").join(',')})');

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
      print('❌ [ALOCACAO_SERVICE] Erro ao pesquisar fontes: $e');
      rethrow;
    }
  }

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
      print('❌ [ALOCACAO_SERVICE] Erro ao buscar extrato: $e');
      rethrow;
    }
  }

  Future<void> saveAlocacao(FonteAlocacao alocacao) async {
    try {
      final extrato = await getExtratoFonte(alocacao.fonte_alocacao_id);
      final saldoAtual = extrato['saldo_atual'] as double;

      if (alocacao.valor_alocado > saldoAtual) {
        throw Exception('Saldo insuficiente. Disponível: $saldoAtual');
      }

      final novoSaldo = saldoAtual - alocacao.valor_alocado;

      final alocacaoComSaldo = FonteAlocacao(
        id: alocacao.id,
        fonte_alocacao_id: alocacao.fonte_alocacao_id,
        destino_alocao_id: alocacao.destino_alocao_id,
        descricao: alocacao.descricao,
        valor_alocado: alocacao.valor_alocado,
        saldo_recurso: novoSaldo,
        data_alocacao: alocacao.data_alocacao,
        obs: alocacao.obs,
      );

      await supabase
          .from('fonte_alocacao')
          .insert(alocacaoComSaldo.toJson());

      await _atualizarAporteProjeto(alocacao.destino_alocao_id);

    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao salvar alocação: $e');
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

  Future<double> getSaldoFonte(String fonteId) async {
    final fonte = await getById(fonteId);
    final alocacoes = await getAlocacoesByFonte(fonteId);
    final totalAlocado = alocacoes.fold(0.0, (sum, a) => sum + a.valor_alocado);
    return fonte.valor_recurso - totalAlocado;
  }

  // Método auxiliar getById
  Future<FontesBase> getById(String id) async {
    final response = await supabase
        .from('fontes_base')
        .select('*')
        .eq('id', id)
        .single();
    return FontesBase.fromJson(response);
  }

  // Método auxiliar getAlocacoesByFonte
  Future<List<FonteAlocacao>> getAlocacoesByFonte(String fonteId) async {
    final response = await supabase
        .from('fonte_alocacao')
        .select('*')
        .eq('fonte_alocacao_id', fonteId)
        .order('data_alocacao', ascending: true);
    return response.map((data) => FonteAlocacao.fromJson(data)).toList();
  }
}