import 'package:flutter/material.dart';
import '../../models/fontes/fontes_base_model.dart';
import '../../services/fontes/fontes_base_service.dart';

class FontesBaseProvider extends ChangeNotifier {
  final FontesBaseService _service = FontesBaseService();

  List<FontesBase> _fontes = [];
  FontesBase? _fonteSelecionada;
  bool _isLoading = false;
  String? _erro;
  String? _filtroPesquisa;

  // Getters
  List<FontesBase> get fontes => _fontes;
  FontesBase? get fonteSelecionada => _fonteSelecionada;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  String? get filtroPesquisa => _filtroPesquisa;

  // Propriedades calculadas
  double get totalGeral {
    return _fontes.fold<double>(
      0, (sum, f) => sum + f.valor_recurso
    );
  }

  double get saldoGeral {
    return _fontes.fold<double>(
      0, (sum, f) => sum + (f.saldo_total ?? 0)
    );
  }

  double get totalAlocadoGeral {
    return totalGeral - saldoGeral;
  }

  /// Carrega todas as fontes
  Future<void> carregarFontes() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _fontes = await _service.listarTodos();
      if (_fontes.isEmpty) {
        _erro = 'Nenhuma fonte de recurso encontrada.';
      }
    } catch (e) {
      _erro = e.toString();
      _fontes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seleciona uma fonte pelo ID
  Future<void> selecionarFonte(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _fonteSelecionada = await _service.getById(id);
      if (_fonteSelecionada == null) {
        _erro = 'Fonte não encontrada.';
      }
    } catch (e) {
      _erro = e.toString();
      _fonteSelecionada = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva uma fonte (cria ou atualiza)
  Future<void> salvarFonte(FontesBase fonte) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final salva = await _service.salvar(fonte);
      _fonteSelecionada = salva;

      // Atualizar a lista
      final index = _fontes.indexWhere((f) => f.id == salva.id);
      if (index != -1) {
        _fontes[index] = salva;
      } else {
        _fontes.insert(0, salva);
      }

      // Se tiver filtro de pesquisa, recarregar
      if (_filtroPesquisa != null && _filtroPesquisa!.isNotEmpty) {
        await pesquisarFontes(_filtroPesquisa!);
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove uma fonte
  Future<void> removerFonte(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _service.deletar(id);
      _fontes.removeWhere((f) => f.id == id);
      if (_fonteSelecionada?.id == id) {
        _fonteSelecionada = null;
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pesquisa fontes por filtros
  Future<void> pesquisarFontes(
    String termo, {
    DateTime? dataInicio,
    DateTime? dataFim,
    double? valorMinimo,
    double? valorMaximo,
    bool? comSaldo,
  }) async {
    _isLoading = true;
    _erro = null;
    _filtroPesquisa = termo;
    notifyListeners();

    try {
      _fontes = await _service.pesquisar(
        entidade: termo.isNotEmpty ? termo : null,
        descricao: termo.isNotEmpty ? termo : null,
        dataInicio: dataInicio,
        dataFim: dataFim,
        valorMinimo: valorMinimo,
        valorMaximo: valorMaximo,
        comSaldo: comSaldo,
      );

      if (_fontes.isEmpty) {
        _erro = 'Nenhuma fonte encontrada com os filtros aplicados.';
      }
    } catch (e) {
      _erro = e.toString();
      _fontes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa a seleção e resultados
  void limparSelecao() {
    _fonteSelecionada = null;
    _filtroPesquisa = null;
    notifyListeners();
  }

  /// Limpa todos os dados
  void limparTudo() {
    _fontes = [];
    _fonteSelecionada = null;
    _erro = null;
    _filtroPesquisa = null;
    notifyListeners();
  }
}