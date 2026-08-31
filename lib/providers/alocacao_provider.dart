import 'package:flutter/material.dart';
import '../models/fonte_alocacao.dart';
import '../models/alocacao_pesquisa_filtro.dart';
import '../models/fontes_base.dart';
import '../services/alocacao_service.dart';

class AlocacaoProvider extends ChangeNotifier {
  final AlocacaoService _service = AlocacaoService();

  List<AlocacaoPesquisaResult> _resultados = [];
  List<FonteAlocacao> _extratoAtual = [];
  FonteAlocacao? _alocacaoSelecionada;
  bool _isLoading = false;
  String? _erro;
  String? _filtroPesquisa;

  // Getters
  List<AlocacaoPesquisaResult> get resultados => _resultados;
  List<FonteAlocacao> get extratoAtual => _extratoAtual;
  FonteAlocacao? get alocacaoSelecionada => _alocacaoSelecionada;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  String? get filtroPesquisa => _filtroPesquisa;

  /// Pesquisa fontes de recurso com os filtros
  Future<void> pesquisarFontes(
    String filtro, {
    bool apenasComSaldo = false,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? projetoId,
  }) async {
    _isLoading = true;
    _erro = null;
    _filtroPesquisa = filtro;
    notifyListeners();

    try {
      _resultados = await _service.pesquisarFontes(
        filtro,
        apenasComSaldo: apenasComSaldo,
        dataInicio: dataInicio,
        dataFim: dataFim,
        projetoId: projetoId,
      );

      if (_resultados.isEmpty) {
        _erro = 'Nenhum resultado encontrado. Ajuste os filtros e tente novamente.';
      }
    } catch (e) {
      _erro = e.toString();
      _resultados = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega o extrato de uma fonte específica
  Future<void> carregarExtrato(String fonteId) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _extratoAtual = await _service.getExtratoFonte(fonteId);

      if (_extratoAtual.isEmpty) {
        _erro = 'Nenhuma alocação encontrada para esta fonte.';
      }
    } catch (e) {
      _erro = e.toString();
      _extratoAtual = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva uma alocação (cria ou atualiza)
  Future<void> salvarAlocacao(FonteAlocacao alocacao) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final saved = await _service.saveAlocacao(alocacao);
      _alocacaoSelecionada = saved;

      // Atualiza a lista de resultados se estiver na mesma fonte
      final index = _resultados.indexWhere(
        (r) => r.fonte.id == saved.fonte_alocacao_id  // ✅ CORRIGIDO: fonte_alocacao_id
      );
      if (index != -1) {
        // Recarrega a pesquisa para atualizar os totais
        await pesquisarFontes(
          _filtroPesquisa ?? '',
          apenasComSaldo: true,
        );
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seleciona uma alocação para edição
  Future<void> selecionarAlocacao(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _alocacaoSelecionada = await _service.getAlocacaoById(id);
    } catch (e) {
      _erro = e.toString();
      _alocacaoSelecionada = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove uma alocação
  Future<void> removerAlocacao(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _service.deleteAlocacao(id);
      _alocacaoSelecionada = null;

      // Atualiza a lista de resultados
      if (_filtroPesquisa != null) {
        await pesquisarFontes(
          _filtroPesquisa!,
          apenasComSaldo: true,
        );
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa todos os resultados e estados
  void limparResultados() {
    _resultados = [];
    _extratoAtual = [];
    _alocacaoSelecionada = null;
    _erro = null;
    _filtroPesquisa = null;
    notifyListeners();
  }

  /// Limpa apenas o extrato
  void limparExtrato() {
    _extratoAtual = [];
    notifyListeners();
  }

  /// Obtém o total geral das fontes
  double get totalGeral {
    return _resultados.fold<double>(
      0, (sum, r) => sum + (r.fonte.valor_recurso ?? 0)
    );
  }

  /// Obtém o total alocado geral
  double get totalAlocadoGeral {
    return _resultados.fold<double>(
      0, (sum, r) => sum + r.totalAlocado
    );
  }

  /// Obtém o saldo geral
  double get saldoGeral {
    return _resultados.fold<double>(
      0, (sum, r) => sum + r.saldo
    );
  }

  /// Busca uma fonte base pelo ID
  Future<FontesBase?> getFonteBase(String id) async {
    return await _service.getFonteBaseById(id);
  }
}