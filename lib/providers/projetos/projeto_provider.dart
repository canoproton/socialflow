/// ============================================
/// PROVIDER: Projeto (Estado Global)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/projeto_model.dart';
import '../../services/projetos/projeto_service.dart';
import '../../services/projetos/disparo_service.dart';

class ProjetoProvider extends ChangeNotifier {
  final ProjetoService _projetoService = ProjetoService();
  final DisparoService _disparoService = DisparoService();

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
  // LISTAR PROJETOS (SIMPLIFICADO)
  // ============================================

  Future<void> loadProjetos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projetos = await _projetoService.list();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARREGAR PROJETO POR ID (Regra 3)
  // ============================================

  Future<void> loadProjetoById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProjeto = await _projetoService.getById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARREGAR PROJETO COMPLETO (COM METAS E ETAPAS)
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
  // CRUD - PROJETO
  // ============================================

  Future<bool> createProjeto(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projeto = await _projetoService.create(data);
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
      final projeto = await _projetoService.update(id, data);

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
  // APROVAR PROJETO (Regra 8)
  // ============================================

  Future<bool> aprovarProjeto(String projetoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Buscar projeto completo
      final projeto = await _projetoService.getCompleto(projetoId);

      // Verificar se tem metas e etapas
      if (projeto.metas.isEmpty) {
        throw Exception('Projeto não pode ser aprovado sem metas');
      }

      for (var meta in projeto.metas) {
        if (meta.etapas.isEmpty) {
          throw Exception('Meta "${meta.descricao}" não tem etapas');
        }
      }

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

  // ============================================
  // CONCLUIR ETAPA (Regra 8)
  // ============================================

  Future<bool> concluirEtapa(String etapaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _disparoService.concluirItemLancamento(etapaId);

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
  // RECALCULAR TOTAIS (Regras 4, 5, 6)
  // ============================================

  Future<void> recalcularTotais(String projetoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _projetoService.recalcularTotais(projetoId);
      
      if (_selectedProjeto?.id == projetoId) {
        await loadProjetoCompleto(projetoId);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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