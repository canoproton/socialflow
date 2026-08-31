import '../../models/enums/destino_tipo_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fontes/fontes_base_model.dart';
import '../../models/fontes/fontes_alocacao_model.dart';
import 'fontes_alocacao_service.dart';

/// Service para operações com a tabela fontes_base
class FontesBaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lista todas as fontes de recursos
  Future<List<FontesBase>> listarTodos() async {
    try {
      print('📋 [FONTES_BASE_SERVICE] Listando todas as fontes');

      final response = await _supabase
          .from('fontes_base')
          .select('*')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      final List<FontesBase> fontes = data
          .map((e) => FontesBase.fromJson(e as Map<String, dynamic>))
          .toList();

      // Buscar saldo para cada fonte
      for (var fonte in fontes) {
        final saldo = await getSaldoFonte(fonte.id!);
        fonte = fonte.copyWith(saldo_total: saldo);
      }

      print('✅ [FONTES_BASE_SERVICE] Encontradas ${fontes.length} fontes');
      return fontes;
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] Erro ao listar: $e');
      return [];
    }
  }

  /// Busca uma fonte pelo ID
  Future<FontesBase?> getById(String id) async {
    try {
      print('📋 [FONTES_BASE_SERVICE] Buscando fonte por ID: $id');

      final response = await _supabase
          .from('fontes_base')
          .select('*')
          .eq('id', id)
          .single();

      final fonte = FontesBase.fromJson(response);
      final saldo = await getSaldoFonte(id);
      return fonte.copyWith(saldo_total: saldo);
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] Erro ao buscar fonte: $e');
      return null;
    }
  }

  /// Salva (cria ou atualiza) uma fonte
  Future<FontesBase> salvar(FontesBase fonte) async {
    try {
      print('📋 [FONTES_BASE_SERVICE] Salvando fonte...');
      print('📋 [FONTES_BASE_SERVICE] Dados: ${fonte.toJson()}');

      // Buscar usuário atual
      final user = _supabase.auth.currentUser;
      final userId = user?.id;

      final data = fonte.toJson();
      data['atualizado_por'] = userId;

      final response = await _supabase
          .from('fontes_base')
          .upsert(data)
          .select()
          .single();

      final saved = FontesBase.fromJson(response);

      // Se for um novo registro, criar a primeira alocação
      if (fonte.id == null) {
        await _criarAlocacaoInicial(saved);
      }

      print('✅ [FONTES_BASE_SERVICE] Fonte salva com sucesso');
      return saved;
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] Erro ao salvar: $e');
      throw e;
    }
  }

  /// Remove uma fonte
  Future<void> deletar(String id) async {
    try {
      print('📋 [FONTES_BASE_SERVICE] Removendo fonte: $id');

      // Verificar se existem alocações
      final alocacoesService = FontesAlocacaoService();
      final alocacoes = await alocacoesService.listarPorFonte(id);

      if (alocacoes.isNotEmpty) {
        throw Exception('Não é possível excluir a fonte: existem alocações vinculadas');
      }

      await _supabase
          .from('fontes_base')
          .delete()
          .eq('id', id);

      print('✅ [FONTES_BASE_SERVICE] Fonte removida com sucesso');
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] Erro ao remover: $e');
      throw e;
    }
  }

  /// Pesquisa fontes por filtros
  Future<List<FontesBase>> pesquisar({
    String? entidade,
    String? descricao,
    DateTime? dataInicio,
    DateTime? dataFim,
    double? valorMinimo,
    double? valorMaximo,
    bool? comSaldo,
  }) async {
    try {
      print('🔍 [FONTES_BASE_SERVICE] Pesquisando fontes...');
      print('🔍 [FONTES_BASE_SERVICE] Entidade: $entidade');
      print('🔍 [FONTES_BASE_SERVICE] Descrição: $descricao');
      print('🔍 [FONTES_BASE_SERVICE] Data Início: $dataInicio');
      print('🔍 [FONTES_BASE_SERVICE] Data Fim: $dataFim');
      print('🔍 [FONTES_BASE_SERVICE] Valor Min: $valorMinimo');
      print('🔍 [FONTES_BASE_SERVICE] Valor Max: $valorMaximo');
      print('🔍 [FONTES_BASE_SERVICE] Com Saldo: $comSaldo');

      var query = _supabase
          .from('fontes_base')
          .select('*');

      // Aplicar filtros
      if (entidade != null && entidade.isNotEmpty) {
        query = query.ilike('entidade', '%$entidade%');
      }

      if (descricao != null && descricao.isNotEmpty) {
        query = query.ilike('descricao', '%$descricao%');
      }

      if (dataInicio != null) {
        query = query.gte('data_aprovacao', dataInicio.toIso8601String());
      }

      if (dataFim != null) {
        query = query.lte('data_aprovacao', dataFim.toIso8601String());
      }

      if (valorMinimo != null) {
        query = query.gte('valor_recurso', valorMinimo);
      }

      if (valorMaximo != null) {
        query = query.lte('valor_recurso', valorMaximo);
      }

      final response = await query.order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      List<FontesBase> fontes = data
          .map((e) => FontesBase.fromJson(e as Map<String, dynamic>))
          .toList();

      // Filtrar por saldo (se necessário)
      if (comSaldo == true) {
        final fontesComSaldo = <FontesBase>[];
        for (var fonte in fontes) {
          final saldo = await getSaldoFonte(fonte.id!);
          if (saldo > 0) {
            fontesComSaldo.add(fonte.copyWith(saldo_total: saldo));
          }
        }
        fontes = fontesComSaldo;
      } else {
        // Buscar saldo para todas
        for (var i = 0; i < fontes.length; i++) {
          final saldo = await getSaldoFonte(fontes[i].id!);
          fontes[i] = fontes[i].copyWith(saldo_total: saldo);
        }
      }

      print('✅ [FONTES_BASE_SERVICE] Encontradas ${fontes.length} fontes');
      return fontes;
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] Erro ao pesquisar: $e');
      return [];
    }
  }

  /// Calcula o saldo atual de uma fonte
  Future<double> getSaldoFonte(String fonteId) async {
    try {
      final response = await _supabase
          .from('fontes_alocacao')
          .select('saldo_recurso')
          .eq('fonte_alocacao_id', fonteId)
          .order('data_alocacao', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return (response.first['saldo_recurso'] as double?) ?? 0;
      }

      // Se não houver alocações, buscar o valor_recurso da fonte
      final fonte = await getById(fonteId);
      return fonte?.valor_recurso ?? 0;
    } catch (e) {
      print('❌ [FONTES_BASE_SERVICE] Erro ao calcular saldo: $e');
      return 0;
    }
  }

  /// Verifica se uma fonte tem saldo disponível
  Future<bool> temSaldoDisponivel(String fonteId, double valor) async {
    final saldo = await getSaldoFonte(fonteId);
    return saldo >= valor;
  }

  /// Cria a primeira alocação (lançamento inicial) de uma fonte
  Future<void> _criarAlocacaoInicial(FontesBase fonte) async {
    try {
      print('📋 [FONTES_BASE_SERVICE] Criando alocação inicial para: ${fonte.id}');

      final alocacao = FontesAlocacao(
        fonte_alocacao_id: fonte.id!,
        destino_tipo: DestinoTipo.projeto,
        destino_id: '', // Será preenchido posteriormente
        descricao: 'Lançamento inicial - ${fonte.descricao}',
        valor_alocado: fonte.valor_recurso,
        saldo_recurso: 0, // Será calculado pelo trigger
        data_alocacao: fonte.data_aprovacao ?? DateTime.now(),
        obs: 'Lançamento automático da fonte de recurso',
      );

      final alocacaoService = FontesAlocacaoService();
      await alocacaoService.salvar(alocacao);
    } catch (e) {
      print('⚠️ [FONTES_BASE_SERVICE] Erro ao criar alocação inicial: $e');
      // Não lançar erro para não interromper o fluxo
    }
  }
}