import 'package:flutter/material.dart';
import '../../models/fontes/fontes_alocacao_model.dart';
import '../../models/enums/destino_tipo_enum.dart';
import '../../services/fontes/fontes_alocacao_service.dart';

class FontesAlocacaoProvider extends ChangeNotifier {
  final FontesAlocacaoService _service = FontesAlocacaoService();

  List<FontesAlocacao> _alocacoes = [];
  FontesAlocacao? _alocacaoSelecionada;
  List<FontesAlocacao> _extrato = [];
  bool _isLoading = false;
  String? _erro;
  double? _saldoAtual;

  // Getters
  List<FontesAlocacao> get alocacoes => _alocacoes;
  FontesAlocacao? get alocacaoSelecionada => _alocacaoSelecionada;
  List<FontesAlocacao> get extrato => _extrato;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  double? get saldoAtual => _saldoAtual;

  /// Carrega alocações de uma fonte específica
  Future<void> carregarAlocacoesPorFonte(String fonteId) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _alocacoes = await _service.listarPorFonte(fonteId);
      _saldoAtual = await _service.getUltimoSaldo(fonteId);
    } catch (e) {
      _erro = e.toString();
      _alocacoes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega o extrato de uma fonte
  Future<void> carregarExtrato(String fonteId) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _extrato = await _service.getExtrato(fonteId);
      _saldoAtual = await _service.getUltimoSaldo(fonteId);

      if (_extrato.isEmpty) {
        _erro = 'Nenhum lançamento encontrado para esta fonte.';
      }
    } catch (e) {
      _erro = e.toString();
      _extrato = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seleciona uma alocação pelo ID
  Future<void> selecionarAlocacao(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _alocacaoSelecionada = await _service.getById(id);
      if (_alocacaoSelecionada == null) {
        _erro = 'Alocação não encontrada.';
      }
    } catch (e) {
      _erro = e.toString();
      _alocacaoSelecionada = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva uma alocação (cria ou atualiza)
  Future<void> salvarAlocacao(FontesAlocacao alocacao) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final salva = await _service.salvar(alocacao);
      _alocacaoSelecionada = salva;
      _saldoAtual = salva.saldo_recurso;

      // Atualizar a lista
      final index = _alocacoes.indexWhere((a) => a.id == salva.id);
      if (index != -1) {
        _alocacoes[index] = salva;
      } else {
        _alocacoes.add(salva);
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
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
      await _service.deletar(id);
      _alocacoes.removeWhere((a) => a.id == id);
      _extrato.removeWhere((a) => a.id == id);
      if (_alocacaoSelecionada?.id == id) {
        _alocacaoSelecionada = null;
      }

      // Atualizar saldo
      if (_extrato.isNotEmpty) {
        _saldoAtual = _extrato.last.saldo_recurso;
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca alocações por destino (projeto ou rubrica)
  Future<List<FontesAlocacao>> buscarPorDestino(
    DestinoTipo tipo,
    String destinoId,
  ) async {
    try {
      return await _service.listarPorDestino(tipo, destinoId);
    } catch (e) {
      _erro = e.toString();
      return [];
    }
  }

  /// Limpa os dados
  void limparTudo() {
    _alocacoes = [];
    _alocacaoSelecionada = null;
    _extrato = [];
    _saldoAtual = null;
    _erro = null;
    notifyListeners();
  }

  /// Limpa o extrato
  void limparExtrato() {
    _extrato = [];
    notifyListeners();
  }

  /// Calcula o percentual alocado
  double calcularPercentualAlocado(double valorTotal, double valorAlocado) {
    if (valorTotal <= 0) return 0;
    return (valorAlocado / valorTotal) * 100;
  }

  /// Verifica se pode fazer uma nova alocação
  bool podeAlocar(double valor) {
    if (_saldoAtual == null) return false;
    return _saldoAtual! >= valor && _saldoAtual! > 0;
  }
}