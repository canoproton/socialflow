import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fontes_base.dart';
import '../models/fonte_alocacao.dart';
import '../models/alocacao_pesquisa_filtro.dart';

class AlocacaoService {
  // 🔧 OBTENÇÃO DO CLIENTE SUPABASE - CORRIGIDO
  final SupabaseClient supabase = Supabase.instance.client;
  
  // 🔧 CONSTRUTOR (opcional, mas recomendado para testabilidade)
  AlocacaoService();

  Future<List<AlocacaoPesquisaResult>> pesquisarFontes(
    String filtro,
    bool apenasComSaldo,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? projetoId,
  ) async {
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
      
      // 2. Buscar alocações - ✅ CORREÇÃO AQUI
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
            '($ids)'  // ✅ SEM aspas simples
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
          // Lógica de filtro de data (implementar conforme necessidade)
        }
        
        resultados.add(
          AlocacaoPesquisaResult(
            fonte: fonte,
            alocacoes: alocacoes,
            totalAlocado: totalAlocado,
            saldo: saldo,
          )
        );
      }
      
      print('✅ [PESQUISA] Resultados: ${resultados.length}');
      return resultados;
      
    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao pesquisar fontes: $e');
      return [];
    }
  }

  Future<List<FonteAlocacao>> getAlocacoesByFonteId(String fonteId) async {
    try {
      final result = await supabase
          .from('fonte_alocacao')
          .select('''
            *,
            destino:projeto!destino_alocao_id(*)
          ''')
          .eq('fonte_alocacao_id', fonteId)
          .order('data_alocacao', ascending: true);
      
      return (result as List).map((e) => FonteAlocacao.fromJson(e)).toList();
      
    } catch (e) {
      print('❌ [ALOCACAO_SERVICE] Erro ao buscar alocações: $e');
      return [];
    }
  }
}

// 📦 Modelo de resultado da pesquisa
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
}