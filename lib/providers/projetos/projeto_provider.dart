/// ============================================
/// PROVIDER: Projeto
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/projeto_model.dart';
import '../../services/projetos/projeto_service.dart';

class ProjetoProvider extends ChangeNotifier {
  final ProjetoService _service = ProjetoService();

  List<ProjetoModel> _projetos = [];
  ProjetoModel? _selectedProjeto;
  bool _isLoading = false;
  String? _error;

  List<ProjetoModel> get projetos => _projetos;
  ProjetoModel? get selectedProjeto => _selectedProjeto;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProjetos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projetos = await _service.list();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjetoById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProjeto = await _service.getById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProjeto(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projeto = await _service.create(data);
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
      final projeto = await _service.update(id, data);

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
      await _service.delete(id);
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    loadProjetos();
  }
}