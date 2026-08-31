import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fontes/fontes_alocacao_model.dart';
import '../../models/enums/destino_tipo_enum.dart';

/// Service para operações com a tabela fontes_alocacao
class FontesAlocacaoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lista todas as alocações
  Future<List<FontesAlocacao>> listarTodos() async {
    try {
      print('📋 [FONTES_ALOCACAO_SERVICE] Listando todas as alocações');

      final response = await _supabase
          .from('fontes_alocacao')
          .select('*')
          .order('data_alocacao', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => FontesAlocacao.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [FONTES_ALOCACAO_SERVICE] Erro ao listar: $e');
      return [];
    }
  }

  /// Lista alocações por fonte
  Future<List<FontesAlocacao>> listarPorFonte(String fonteId) async {
    try {
      print('📋 [FONTES_ALOCACAO_SERVICE] Listando alocações da fonte: $fonteId');

      final response = await _supabase
          .from('fontes_alocacao')
          .select('*')
          .eq('fonte_alocacao_id', fonteId)
          .order('data_alocacao', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => FontesAlocacao.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [FONTES_ALOCACAO_SERVICE] Erro ao listar por fonte: $e');
      return [];
    }
  }

  /// Busca uma alocação pelo ID
  Future<FontesAlocacao?> getById(String id) async {
    try {
      print('📋 [FONTES_ALOCACAO_SERVICE] Buscando alocação por ID: $id');

      final response = await _supabase
          .from('fontes_alocacao')
          .select('*')
          .eq('id', id)
          .single();

      return FontesAlocacao.fromJson(response);
    } catch (e) {
      print('❌ [FONTES_ALOCACAO_SERVICE] Erro ao buscar alocação: $e');
      return null;
    }
  }

  /// Salva (cria ou atualiza) uma alocação
  Future<FontesAlocacao> salvar(FontesAlocacao alocacao) async {
    try {
      print('📋 [FONTES_ALOCACAO_SERVICE] Salvando alocação...');
      print('📋 [FONTES_ALOCACAO_SERVICE] Dados: ${alocacao.toJson()}');

      // Validar saldo antes de salvar
      await _validarSaldo(alocacao);

      // Buscar usuário atual
      final user = _supabase.auth.currentUser;
      final userId = user?.id;

      final data = alocacao.toJson();
      data['atualizado_por'] = userId;

      final response = await _supabase
          .from('fontes_alocacao')
          .upsert(data)
          .select()
          .single();

      print('✅ [FONTES_ALOCACAO_SERVICE] Alocação salva com sucesso');
      return FontesAlocacao.fromJson(response);
    } catch (e) {
      print('❌ [FONTES_ALOCACAO_SERVICE] Erro ao salvar: $e');
      throw e;
    }
  }

  /// Remove uma alocação
  Future<void> deletar(String id) async {
    try {
      print('📋 [FONTES_ALOCACAO_SERVICE] Removendo alocação: $id');

      await _supabase
          .from('fontes_alocacao')
          .delete()
          .eq('id', id);

      print('✅ [FONTES_ALOCACAO_SERVICE] Alocação removida com sucesso');
    } catch (e) {
      print('❌ [FONTES_ALOCACAO_SERVICE] Erro ao remover: $e');
      throw e;
    }
  }

  /// Valida se o saldo é suficiente para a alocação
  Future<void> _validarSaldo(FontesAlocacao alocacao) async {
    // Buscar o saldo atual da fonte
    final response = await _supabase
        .from('fontes_alocacao')
        .select('saldo_recurso')
        .eq('fonte_alocacao_id', alocacao.fonte_alocacao_id)
        .order('data_alocacao', ascending: false)
        .limit(1);

    double saldoAtual;

    if (response.isNotEmpty) {
      saldoAtual = (response.first['saldo_recurso'] as double?) ?? 0;
    } else {
      // Se não houver alocações, buscar o valor_recurso da fonte
      final fonteResponse = await _supabase
          .from('fontes_base')
          .select('valor_recurso')
          .eq('id', alocacao.fonte_alocacao_id)
          .single();

      saldoAtual = (fonteResponse['valor_recurso'] as double?) ?? 0;
    }

    // Verificar se o saldo é suficiente
    if (saldoAtual < alocacao.valor_alocado) {
      throw Exception(
        'Saldo insuficiente para alocação. Disponível: R\$ ${saldoAtual.toStringAsFixed(2)}, '
        'Solicitado: R\$ ${alocacao.valor_alocado.toStringAsFixed(2)}'
      );
    }

    // Verificar se o saldo é zero ou negativo
    if (saldoAtual <= 0) {
      throw Exception('Saldo indisponível para alocação. Saldo atual: R\$ 0,00');
    }
  }

  /// Obtém o último saldo de uma fonte
  Future<double> getUltimoSaldo(String fonteId) async {
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
      final fonteResponse = await _supabase
          .from('fontes_base')
          .select('valor_recurso')
          .eq('id', fonteId)
          .single();

      return (fonteResponse['valor_recurso'] as double?) ?? 0;
    } catch (e) {
      print('❌ [FONTES_ALOCACAO_SERVICE] Erro ao buscar último saldo: $e');
      return 0;
    }
  }

  /// Obtém o extrato completo de uma fonte
  Future<List<FontesAlocacao>> getExtrato(String fonteId) async {
    try {
      print('📋 [FONTES_ALOCACAO_SERVICE] Gerando extrato para fonte: $fonteId');

      final response = await _supabase
          .from('fontes_alocacao')
          .select('''
            *,
            destino:destino_id(*)
          ''')
          .eq('fonte_alocacao_id', fonteId)
          .order('data_alocacao', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      final alocacoes = data
          .map((e) => FontesAlocacao.fromJson(e as Map<String, dynamic>))
          .toList();

      print('✅ [FONTES_ALOCACAO_SERVICE] Extrato gerado: ${alocacoes.length} alocações');
      return alocacoes;
    } catch (e) {
      print('❌ [FONTES_ALOCACAO_SERVICE] Erro ao gerar extrato: $e');
      return [];
    }
  }

  /// Busca alocações de um destino específico (projeto ou rubrica)
  Future<List<FontesAlocacao>> listarPorDestino(
    DestinoTipo tipo,
    String destinoId,
  ) async {
    try {
      print('📋 [FONTES_ALOCACAO_SERVICE] Buscando alocações por destino: $tipo - $destinoId');

      final response = await _supabase
          .from('fontes_alocacao')
          .select('*')
          .eq('destino_tipo', tipo.toJson())
          .eq('destino_id', destinoId)
          .order('data_alocacao', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => FontesAlocacao.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [FONTES_ALOCACAO_SERVICE] Erro ao buscar por destino: $e');
      return [];
    }
  }
}