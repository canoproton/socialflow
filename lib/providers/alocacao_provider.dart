import 'package:flutter/material.dart';
import '../models/fonte_alocacao.dart';
import '../models/alocacao_pesquisa_filtro.dart';
import '../services/alocacao_service.dart';

class AlocacaoProvider extends ChangeNotifier {
  final AlocacaoService _service = AlocacaoService();
  
  List<Map<String, dynamic>> _resultados = [];
  Map<String, dynamic>? _extratoAtual;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get resultados => _resultados;
  Map<String, dynamic>? get extratoAtual => _extratoAtual;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> pesquisarFontes(AlocacaoPesquisaFiltro filtro) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _resultados = await _service.pesquisarFontes(filtro);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getExtrato(String fonteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _extratoAtual = await _service.getExtratoFonte(fonteId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createAlocacao(FonteAlocacao alocacao) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.saveAlocacao(alocacao);
      await getExtrato(alocacao.fonte_alocacao_id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void limparResultados() {
    _resultados = [];
    _extratoAtual = null;
    notifyListeners();
  }
}