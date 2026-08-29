import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fontes_base.dart';
import '../models/fonte_alocacao.dart';

class FontesBaseService {
  final supabase = Supabase.instance.client;

  Future<List<FontesBase>> list() async {
    final response = await supabase
        .from('fontes_base')
        .select('*')
        .order('descricao');

    return response.map((data) => FontesBase.fromJson(data)).toList();
  }

  Future<FontesBase> getById(String id) async {
    final response = await supabase
        .from('fontes_base')
        .select('*')
        .eq('id', id)
        .single();

    return FontesBase.fromJson(response);
  }

  Future<List<FonteAlocacao>> getAllAlocacoes() async {
    final response = await supabase
        .from('fonte_alocacao')
        .select('''
          *,
          fonte:fontes_base!fonte_alocacao_id(*),
          projeto:projeto!destino_alocao_id(*)
        ''')
        .order('data_alocacao', ascending: false);

    return response.map((data) => FonteAlocacao.fromJson(data)).toList();
  }

  Future<List<FonteAlocacao>> getAlocacoesByFonte(String fonteId) async {
    final response = await supabase
        .from('fonte_alocacao')
        .select('''
          *,
          fonte:fontes_base!fonte_alocacao_id(*),
          projeto:projeto!destino_alocao_id(*)
        ''')
        .eq('fonte_alocacao_id', fonteId)
        .order('data_alocacao', ascending: true);

    return response.map((data) => FonteAlocacao.fromJson(data)).toList();
  }

  Future<List<FonteAlocacao>> getAlocacoesByProjeto(String projetoId) async {
    final response = await supabase
        .from('fonte_alocacao')
        .select('''
          *,
          fonte:fontes_base!fonte_alocacao_id(*)
        ''')
        .eq('destino_alocao_id', projetoId)
        .order('data_alocacao', ascending: true);

    return response.map((data) => FonteAlocacao.fromJson(data)).toList();
  }

  Future<FonteAlocacao> createAlocacao(FonteAlocacao alocacao) async {
    final fonte = await getById(alocacao.fonte_alocacao_id);
    
    final alocacoesExistentes = await getAlocacoesByFonte(fonte.id);
    final totalAlocadoAtual = alocacoesExistentes.fold(0.0, (sum, a) => sum + a.valor_alocado);
    
    final totalAlocadoNovo = totalAlocadoAtual + alocacao.valor_alocado;
    if (totalAlocadoNovo > fonte.valor_recurso) {
      throw Exception(
        'Valor excede o limite da fonte. '
        'Disponível: ${fonte.valor_recurso - totalAlocadoAtual}'
      );
    }

    if (alocacoesExistentes.isNotEmpty) {
      final projetoPrincipal = alocacoesExistentes.first.destino_alocao_id;
      if (alocacao.destino_alocao_id != projetoPrincipal) {
        final totalRemanejado = alocacoesExistentes
            .where((a) => a.destino_alocao_id != projetoPrincipal)
            .fold(0.0, (sum, a) => sum + a.valor_alocado);
        
        final totalRemanejadoNovo = totalRemanejado + alocacao.valor_alocado;
        final limiteRemanejamento = fonte.valor_recurso * (fonte.remanejamento / 100);
        
        if (totalRemanejadoNovo > limiteRemanejamento) {
          throw Exception(
            'Valor excede o limite de remanejamento de ${fonte.remanejamento}%. '
            'Disponível para remanejamento: ${limiteRemanejamento - totalRemanejado}'
          );
        }
      }
    }

    final response = await supabase
        .from('fonte_alocacao')
        .insert(alocacao.toJson())
        .select()
        .single();

    await _atualizarAporteProjeto(alocacao.destino_alocao_id);

    return FonteAlocacao.fromJson(response);
  }

  Future<void> _atualizarAporteProjeto(String projetoId) async {
    final alocacoes = await getAlocacoesByProjeto(projetoId);
    final totalAportado = alocacoes.fold(0.0, (sum, a) => sum + a.valor_alocado);
    
    await supabase
        .from('projeto')
        .update({'valor_total_aportado': totalAportado})
        .eq('id', projetoId);
  }

  Future<Map<String, dynamic>> getExtratoFonte(String fonteId) async {
    final fonte = await getById(fonteId);
    final alocacoes = await getAlocacoesByFonte(fonteId);
    
    double saldoAcumulado = 0;
    List<Map<String, dynamic>> extrato = [];
    
    for (var alocacao in alocacoes) {
      saldoAcumulado += alocacao.valor_alocado;
      extrato.add({
        'data': alocacao.data_alocacao,
        'projeto': alocacao.projeto?.descricao ?? alocacao.destino_alocao_id,
        'valor': alocacao.valor_alocado,
        'saldo_acumulado': saldoAcumulado,
        'descricao': alocacao.descricao,
      });
    }
    
    final totalAlocado = alocacoes.fold(0.0, (sum, a) => sum + a.valor_alocado);
    final saldoDisponivel = fonte.valor_recurso - totalAlocado;
    
    return {
      'fonte': fonte,
      'extrato': extrato,
      'total_alocado': totalAlocado,
      'saldo_disponivel': saldoDisponivel,
      'percentual_utilizado': (totalAlocado / fonte.valor_recurso) * 100,
      'limite_remanejamento': fonte.valor_recurso * (fonte.remanejamento / 100),
      'total_remanejado': alocacoes
          .skip(1)
          .fold(0.0, (sum, a) => sum + a.valor_alocado),
    };
  }

  Future<void> deleteAlocacao(String id) async {
    final alocacao = await supabase
        .from('fonte_alocacao')
        .select('destino_alocao_id')
        .eq('id', id)
        .single();
    
    await supabase
        .from('fonte_alocacao')
        .delete()
        .eq('id', id);
    
    await _atualizarAporteProjeto(alocacao['destino_alocao_id']);
  }

  Future<double> getSaldoFonte(String fonteId) async {
    final fonte = await getById(fonteId);
    final alocacoes = await getAlocacoesByFonte(fonteId);
    final totalAlocado = alocacoes.fold(0.0, (sum, a) => sum + a.valor_alocado);
    return fonte.valor_recurso - totalAlocado;
  }
}