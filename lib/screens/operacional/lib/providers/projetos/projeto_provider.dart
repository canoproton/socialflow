/// ============================================
/// PROVIDER: Projeto (Estado Global - Único)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/projeto_model.dart';
import '../../services/projetos/projeto_service.dart';
import '../../services/projetos/disparo_service.dart';

class ProjetoProvider extends ChangeNotifier {
  final ProjetoService _projetoService = ProjetoService();
  final DisparoService _disparoService = DisparoService();

  // Estado
  List<ProjetoModel> _projetos = [];
  ProjetoModel? _selectedProjeto;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _filters = {};

  // Getters
  List<ProjetoModel> get projetos => _projetos;
  ProjetoModel? get selectedProjeto => _selectedProjeto;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get filters => _filters;

  // ============================================
  // LISTAR PROJETOS (Regra 13)
  // ============================================

  Future<void> loadProjetos({
    String? search,
    String? status,
    String? proponenteId,
    String? gerenteId,
    DateTime? dataInicio,
    DateTime? dataFim,
    double? valorMin,
    double? valorMax,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _filters = {
        if (search != null) 'search': search,
        if (status != null) 'status': status,
        if (proponenteId != null) 'proponenteId': proponenteId,
        if (gerenteId != null) 'gerenteId': gerenteId,
        if (dataInicio != null) 'dataInicio': dataInicio,
        if (dataFim != null) 'dataFim': dataFim,
        if (valorMin != null) 'valorMin': valorMin,
        if (valorMax != null) 'valorMax': valorMax,
      };

      _projetos = await _projetoService.list(
        search: search,
        status: status,
        proponenteId: proponenteId,
        gerenteId: gerenteId,
        dataInicio: dataInicio,
        dataFim: dataFim,
        valorMin: valorMin,
        valorMax: valorMax,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARREGAR PROJETO COMPLETO
  // ============================================

  Future<void> loadProjetoCompleto(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProjeto = await _projetoService.getCompleto(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CRUD - PROJETO (COM METAS E ETAPAS)
  // ============================================

  Future<bool> createProjeto(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projeto = await _projetoService.createCompleto(data);
      _projetos.insert(0, projeto);
      _selectedProjeto = projeto;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProjeto(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projeto = await _projetoService.updateCompleto(id, data);

      final index = _projetos.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projetos[index] = projeto;
      }

      if (_selectedProjeto?.id == id) {
        _selectedProjeto = projeto;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProjeto(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _projetoService.delete(id);
      _projetos.removeWhere((p) => p.id == id);
      if (_selectedProjeto?.id == id) {
        _selectedProjeto = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // DISPAROS (Regra 8)
  // ============================================

  Future<bool> aprovarProjeto(String projetoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar se pode aprovar
      await _projetoService.podeAprovar(projetoId);

      // Buscar projeto completo
      final projeto = await _projetoService.getCompleto(projetoId);

      // Disparar todas etapas (Regra 8)
      await _disparoService.dispararTodasEtapas(projeto);

      // Recarregar projeto
      await loadProjetoCompleto(projetoId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> concluirEtapa(String etapaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _disparoService.concluirItemLancamento(etapaId);

      // Recarregar projeto selecionado
      if (_selectedProjeto != null) {
        await loadProjetoCompleto(_selectedProjeto!.id);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // UTILITÁRIOS
  // ============================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelected() {
    _selectedProjeto = null;
    notifyListeners();
  }

  void refresh() {
    loadProjetos();
  }

  void setFilter(String key, dynamic value) {
    _filters[key] = value;
    notifyListeners();
  }

  void clearFilters() {
    _filters = {};
    notifyListeners();
  }
}