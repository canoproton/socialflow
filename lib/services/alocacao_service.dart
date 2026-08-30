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
      print('🔍 [ALOCACAO_SERVICE] PESQUISAR_FONTES - Filtro: ${filtro.toJson()}');
      
      // Constrói a query base
      var query = supabase.from('fontes_base').select('*');
      
      // Filtro por entidade
      if (filtro.entidade != null && filtro.entidade!.isNotEmpty) {
        query = query.ilike('entidade', '%${filtro.entidade}%');
        print('🔍 [ALOCACAO_SERVICE] Filtro entidade: ${filtro.entidade}');
      }

      // Filtro por data de aprovação
      if (filtro.dataInicio != null) {
        query = query.gte('data_aprovacao', filtro.dataInicio!.toIso8601String());
        print('🔍 [ALOCACAO_SERVICE] Filtro dataInicio: ${filtro.dataInicio}');
      }
      if (filtro.dataFim != null) {
        query = query.lte('data_aprovacao', filtro.dataFim!.toIso8601String());
        print('🔍 [ALOCACAO_SERVICE] Filtro dataFim: ${filtro.dataFim}');
      }

      final fontesResult = await query;
      final fontes = fontesResult.map((data) => FontesBase.fromJson(data)).toList();
      
      print('📋 [ALOCACAO_SERVICE] Encontradas ${fontes.length} fontes');

      if (fontes.isEmpty) {
        return [];
      }

      // Busca todas as alocações das fontes
      final alocacoesResult = await supabase
          .from('fonte_alocacao')
          .select('*')
          .filter('fonte_alocacao_id', 'in', '(${fontes.map((f) => "'${f.id}'").join(',')})');

      final alocacoes = alocacoesResult.map((data) => FonteAlocacao.fromJson(data)).toList();
      
      print('📋 [ALOCACAO_SERVICE] Encontradas ${alocacoes.length} alocações');

      List<Map<String, dynamic>> resultado = [];

      for (var fonte in fontes) {
        final alocacoesFonte = alocacoes
            .where((a) => a.fonte_alocacao_id == fonte.id)
            .toList();
        
        final totalAlocado = alocacoesFonte.fold(0.0, (sum, a) => sum + a.valor_alocado);
        final saldo = fonte.valor_recurso - totalAlocado;

        print('📋 [ALOCACAO_SERVICE] Fonte: ${fonte.descricao}, Total: ${fonte.valor_recurso}, Alocado: $totalAlocado, Saldo: $saldo');

        // Filtro: com saldo
        if (filtro.comSaldo == true && saldo <= 0) {
          print('📋 [ALOCACAO_SERVICE] Fonte ${fonte.descricao} excluída por saldo <= 0');
          continue;
        }

        // Filtro: por projeto
        if (filtro.projetoId != null && filtro.projetoId!.isNotEmpty) {
          final temProjeto = alocacoesFonte.any((a) => a.destino_alocao_id == filtro.projetoId);
          if (!temProjeto) {
            print('📋 [ALOCACAO_SERVICE] Fonte ${fonte.descricao} excluída por não ter o projeto');
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

      print('✅ [ALOCACAO_SERVICE] Retornando ${resultado.length} resultados');
      return resultado;

    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao pesquisar fontes: $e');
      rethrow;
    }
  }

  /// Busca o extrato completo de uma fonte
  Future<Map<String, dynamic>> getExtratoFonte(String fonteId) async {
    try {
      print('📋 [ALOCACAO_SERVICE] GET_EXTRATO - Fonte: $fonteId');
      
      // Busca a fonte
      final fonteResult = await supabase
          .from('fontes_base')
          .select('*')
          .eq('id', fonteId)
          .single();
      
      final fonte = FontesBase.fromJson(fonteResult);
      print('📋 [ALOCACAO_SERVICE] Fonte encontrada: ${fonte.descricao}');

      // Busca alocações com dados do projeto
      final alocacoesResult = await supabase
          .from('fonte_alocacao')
          .select('''
            *,
            projeto:projeto!destino_alocao_id(*)
          ''')
          .eq('fonte_alocacao_id', fonteId)
          .order('data_alocacao', ascending: true);

      final alocacoes = alocacoesResult.map((data) => FonteAlocacao.fromJson(data)).toList();
      print('📋 [ALOCACAO_SERVICE] Encontradas ${alocacoes.length} alocações');

      // Calcula extrato
      final saldoInicial = fonte.valor_recurso;
      double saldoAcumulado = saldoInicial;

      List<Map<String, dynamic>> extrato = [];

      // Linha de saldo inicial
      extrato.add({
        'tipo': 'SALDO_INICIAL',
        'data': fonte.data_aprovacao,
        'destino': 'Entrada do recurso na fonte',
        'valor': saldoInicial,
        'saldo': saldoInicial,
        'isSaldoInicial': true,
      });

      // Linhas de alocações
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
        print('📋 [ALOCACAO_SERVICE] Alocação: ${alocacao.descricao}, Valor: ${alocacao.valor_alocado}, Saldo: $saldoAcumulado');
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

  /// Salva uma nova alocação
  Future<void> saveAlocacao(FonteAlocacao alocacao) async {
    try {
      print('📋 [ALOCACAO_SERVICE] SAVE_ALOCACAO - Fonte: ${alocacao.fonte_alocacao_id}');
      print('📋 [ALOCACAO_SERVICE] Valor: ${alocacao.valor_alocado}, Destino: ${alocacao.destino_alocao_id}');
      
      // Busca o extrato para saber o saldo atual
      final extrato = await getExtratoFonte(alocacao.fonte_alocacao_id);
      final saldoAtual = extrato['saldo_atual'] as double;
      
      print('📋 [ALOCACAO_SERVICE] Saldo atual: $saldoAtual');

      // Valida saldo
      if (alocacao.valor_alocado > saldoAtual) {
        throw Exception('Saldo insuficiente. Disponível: $saldoAtual');
      }

      // Calcula o saldo_recurso
      final novoSaldo = saldoAtual - alocacao.valor_alocado;
      print('📋 [ALOCACAO_SERVICE] Novo saldo: $novoSaldo');

      // Cria a alocação com saldo_recurso calculado
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
      
      print('✅ [ALOCACAO_SERVICE] Alocação salva com sucesso');

      // Atualiza o aporte do projeto
      await _atualizarAporteProjeto(alocacao.destino_alocao_id);
      print('✅ [ALOCACAO_SERVICE] Aporte do projeto atualizado');

    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao salvar alocação: $e');
      rethrow;
    }
  }

  /// Atualiza o valor_total_aportado do projeto
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