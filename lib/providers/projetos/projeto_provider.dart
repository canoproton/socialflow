/// ============================================
/// PROVIDER: Projeto (Estado Global)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/projeto_model.dart';
import '../../services/projetos/projeto_service.dart';
import '../../services/debug_service.dart';

class ProjetoProvider extends ChangeNotifier {
  final ProjetoService _projetoService = ProjetoService();

  List<ProjetoModel> _projetos = [];
  ProjetoModel? _selectedProjeto;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _filters = {};

  List<ProjetoModel> get projetos => _projetos;
  ProjetoModel? get selectedProjeto => _selectedProjeto;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get filters => _filters;

  // ============================================
  // LISTAR PROJETOS (COM FILTROS)
  // ============================================

  Future<void> loadProjetos() async {
    DebugService.log(
      module: 'PROJETO_PROVIDER',
      action: 'LOAD_PROJETOS',
      data: 'Carregando projetos',
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projetos = await _projetoService.list();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'LOAD_PROJETOS',
        data: 'Carregados ${_projetos.length} projetos',
      );
    } catch (e) {
      _error = e.toString();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'LOAD_PROJETOS',
        error: e.toString(),
        isError: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARREGAR PROJETO POR ID
  // ============================================

  Future<void> loadProjetoById(String id) async {
    DebugService.log(
      module: 'PROJETO_PROVIDER',
      action: 'LOAD_PROJETO_BY_ID',
      data: 'ID: $id',
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProjeto = await _projetoService.getById(id);
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'LOAD_PROJETO_BY_ID',
        data: 'Projeto: ${_selectedProjeto?.descricao}',
      );
    } catch (e) {
      _error = e.toString();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'LOAD_PROJETO_BY_ID',
        error: e.toString(),
        isError: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARREGAR PROJETO COMPLETO
  // ============================================

  Future<void> loadProjetoCompleto(String id) async {
    DebugService.log(
      module: 'PROJETO_PROVIDER',
      action: 'LOAD_PROJETO_COMPLETO',
      data: 'ID: $id',
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProjeto = await _projetoService.getCompleto(id);
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'LOAD_PROJETO_COMPLETO',
        data: 'Projeto: ${_selectedProjeto?.descricao}, Metas: ${_selectedProjeto?.metas.length}',
      );
    } catch (e) {
      _error = e.toString();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'LOAD_PROJETO_COMPLETO',
        error: e.toString(),
        isError: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CRUD - PROJETO
  // ============================================

  Future<bool> createProjeto(Map<String, dynamic> data) async {
    DebugService.log(
      module: 'PROJETO_PROVIDER',
      action: 'CREATE_PROJETO',
      data: data,
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projeto = await _projetoService.create(data);
      _projetos.insert(0, projeto);
      _selectedProjeto = projeto;
      notifyListeners();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'CREATE_PROJETO',
        data: 'Projeto criado: ${projeto.id}',
      );
      return true;
    } catch (e) {
      _error = e.toString();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'CREATE_PROJETO',
        error: e.toString(),
        isError: true,
      );
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProjeto(String id, Map<String, dynamic> data) async {
    DebugService.log(
      module: 'PROJETO_PROVIDER',
      action: 'UPDATE_PROJETO',
      data: 'ID: $id',
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projeto = await _projetoService.update(id, data);

      final index = _projetos.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projetos[index] = projeto;
      }

      if (_selectedProjeto?.id == id) {
        _selectedProjeto = projeto;
      }

      notifyListeners();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'UPDATE_PROJETO',
        data: 'Projeto atualizado: $id',
      );
      return true;
    } catch (e) {
      _error = e.toString();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'UPDATE_PROJETO',
        error: e.toString(),
        isError: true,
      );
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProjeto(String id) async {
    DebugService.log(
      module: 'PROJETO_PROVIDER',
      action: 'DELETE_PROJETO',
      data: 'ID: $id',
    );

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
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'DELETE_PROJETO',
        data: 'Projeto deletado: $id',
      );
      return true;
    } catch (e) {
      _error = e.toString();
      DebugService.log(
        module: 'PROJETO_PROVIDER',
        action: 'DELETE_PROJETO',
        error: e.toString(),
        isError: true,
      );
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
    DebugService.log(
      module: 'PROJETO_PROVIDER',
      action: 'REFRESH',
      data: 'Recarregando projetos',
    );
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