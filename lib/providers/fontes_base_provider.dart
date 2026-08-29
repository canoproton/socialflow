import 'package:flutter/material.dart';
import '../models/fontes_base.dart';
import '../models/fonte_alocacao.dart';
import '../services/fontes_base_service.dart';

class FontesBaseProvider extends ChangeNotifier {
  final FontesBaseService _service = FontesBaseService();
  
  List<FontesBase> _fontes = [];
  List<FonteAlocacao> _alocacoes = [];
  bool _isLoading = false;
  String? _error;

  List<FontesBase> get fontes => _fontes;
  List<FonteAlocacao> get alocacoes => _alocacoes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FontesBase? getFonteById(String id) {
    try {
      return _fontes.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  List<FonteAlocacao> getAlocacoesByFonteId(String fonteId) {
    return _alocacoes.where((a) => a.fonte_alocacao_id == fonteId).toList();
  }

  Future<void> loadFontes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fontes = await _service.list();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAlocacoes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alocacoes = await _service.getAllAlocacoes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAlocacoesByFonte(String fonteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final alocacoesFonte = await _service.getAlocacoesByFonte(fonteId);
      
      final outrasAlocacoes = _alocacoes
          .where((a) => a.fonte_alocacao_id != fonteId)
          .toList();
      _alocacoes = [...outrasAlocacoes, ...alocacoesFonte];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<FonteAlocacao> createAlocacao(FonteAlocacao alocacao) async {
    try {
      final nova = await _service.createAlocacao(alocacao);
      await loadAlocacoes();
      await loadFontes();
      return nova;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAlocacao(String id) async {
    try {
      await _service.deleteAlocacao(id);
      await loadAlocacoes();
      await loadFontes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<double> getSaldoFonte(String fonteId) async {
    try {
      return await _service.getSaldoFonte(fonteId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}