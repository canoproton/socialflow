/// ============================================
/// PROVIDER: Projeto (Estado Global)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/projeto_model.dart';
import '../../services/projetos/projeto_service.dart';
import '../../services/projetos/disparo_service.dart';

class ProjetoProvider extends ChangeNotifier {
  final ProjetoService _projetoService = ProjetoService();

  List<Projeto> _projetos = [];
  Projeto? _selectedProjeto;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _filters = {};

  List<Projeto> get projetos => _projetos;
  Projeto? get selectedProjeto => _selectedProjeto;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get filters => _filters;

  // ============================================
  // LISTAR PROJETOS (SEM FILTROS)
  // ============================================
Future<void> loadProjetos({
  String? search,
  String? status,
}) async {
  print('📋 [PROJETO_PROVIDER] LOAD_PROJETOS - Filtros: search=$search, status=$status');

  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // ⭐ CARREGAR TODOS OS PROJETOS
    _projetos = await _projetoService.list();
    
    // ⭐ APLICAR FILTROS NO LADO DO CLIENTE (FLUTTER)
    if (search != null && search.isNotEmpty) {
      _projetos = _projetos.where((p) =>
        p.descricao?.toLowerCase().contains(search.toLowerCase()) ?? false
      ).toList();
    }
    
    if (status != null && status.isNotEmpty) {
      _projetos = _projetos.where((p) => p.statusProjeto == status).toList();
    }
    
    print('✅ [PROJETO_PROVIDER] LOAD_PROJETOS - Carregados ${_projetos.length} projetos após filtros');
  } catch (e) {
    _error = e.toString();
    print('❌ [PROJETO_PROVIDER] LOAD_PROJETOS - Erro: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}  
// ============================================
  // CARREGAR PROJETO POR ID
  // ============================================

  Future<void> loadProjetoById(String id) async {
    print('📋 [PROJETO_PROVIDER] LOAD_PROJETO_BY_ID - ID: $id');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProjeto = await _projetoService.getById(id);
      print('✅ [PROJETO_PROVIDER] LOAD_PROJETO_BY_ID - Projeto: ${_selectedProjeto?.descricao}');
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] LOAD_PROJETO_BY_ID - Erro: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARREGAR PROJETO COMPLETO
  // ============================================

  Future<void> loadProjetoCompleto(String id) async {
    print('📋 [PROJETO_PROVIDER] LOAD_PROJETO_COMPLETO - ID: $id');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProjeto = await _projetoService.getCompleto(id);
      print('✅ [PROJETO_PROVIDER] LOAD_PROJETO_COMPLETO - Projeto: ${_selectedProjeto?.descricao}, Metas: ${_selectedProjeto?.metas.length}');
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] LOAD_PROJETO_COMPLETO - Erro: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CRUD - PROJETO
  // ============================================

  Future<bool> createProjeto(Map<String, dynamic> data) async {
    print('📋 [PROJETO_PROVIDER] CREATE_PROJETO - Criando projeto');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projeto = await _projetoService.create(data);
      _projetos.insert(0, projeto);
      _selectedProjeto = projeto;
      notifyListeners();
      print('✅ [PROJETO_PROVIDER] CREATE_PROJETO - Projeto criado: ${projeto.id}');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] CREATE_PROJETO - Erro: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProjetoCompleto(Map<String, dynamic> data) async {
    print('📋 [PROJETO_PROVIDER] CREATE_PROJETO_COMPLETO - Criando projeto completo');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projeto = await _projetoService.createCompleto(data);
      _projetos.insert(0, projeto);
      _selectedProjeto = projeto;
      notifyListeners();
      print('✅ [PROJETO_PROVIDER] CREATE_PROJETO_COMPLETO - Projeto criado: ${projeto.id} com ${projeto.metas.length} metas');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] CREATE_PROJETO_COMPLETO - Erro: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProjeto(String id, Map<String, dynamic> data) async {
    print('📋 [PROJETO_PROVIDER] UPDATE_PROJETO - ID: $id');

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
      print('✅ [PROJETO_PROVIDER] UPDATE_PROJETO - Projeto atualizado: $id');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] UPDATE_PROJETO - Erro: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProjetoCompleto(String id, Map<String, dynamic> data) async {
    print('📋 [PROJETO_PROVIDER] UPDATE_PROJETO_COMPLETO - ID: $id');

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
      print('✅ [PROJETO_PROVIDER] UPDATE_PROJETO_COMPLETO - Projeto atualizado: $id com ${projeto.metas.length} metas');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] UPDATE_PROJETO_COMPLETO - Erro: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProjeto(String id) async {
    print('🗑️ [PROJETO_PROVIDER] DELETE_PROJETO - ID: $id');

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
      print('✅ [PROJETO_PROVIDER] DELETE_PROJETO - Projeto deletado: $id');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] DELETE_PROJETO - Erro: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // REGRA 8: APROVAR E EXECUTAR PROJETO
  // ============================================

  Future<bool> aprovarProjeto(String projetoId) async {
    print('📋 [PROJETO_PROVIDER] APROVAR_PROJETO - Projeto: $projetoId');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final podeAprovar = await _projetoService.podeAprovar(projetoId);
      if (!podeAprovar) {
        throw Exception('Projeto não pode ser aprovado');
      }

      final projeto = await _projetoService.getCompleto(projetoId);

      final disparoService = DisparoService();
      await disparoService.dispararTodasEtapas(projeto);

      await loadProjetoCompleto(projetoId);

      notifyListeners();
      print('✅ [PROJETO_PROVIDER] APROVAR_PROJETO - Projeto aprovado: $projetoId');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] APROVAR_PROJETO - Erro: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // REGRA 8: CONCLUIR ETAPA
  // ============================================

  Future<bool> concluirEtapa(String etapaId) async {
    print('📋 [PROJETO_PROVIDER] CONCLUIR_ETAPA - Etapa: $etapaId');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final disparoService = DisparoService();
      await disparoService.concluirEtapa(etapaId);

      if (_selectedProjeto != null) {
        await loadProjetoCompleto(_selectedProjeto!.id);
      }

      notifyListeners();
      print('✅ [PROJETO_PROVIDER] CONCLUIR_ETAPA - Etapa concluída: $etapaId');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] CONCLUIR_ETAPA - Erro: $e');
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
    print('📋 [PROJETO_PROVIDER] RECALCULAR_TOTAIS - Projeto ID: $projetoId');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _projetoService.recalcularTotais(projetoId);

      if (_selectedProjeto?.id == projetoId) {
        await loadProjetoCompleto(projetoId);
      }

      notifyListeners();
      print('✅ [PROJETO_PROVIDER] RECALCULAR_TOTAIS - Totais recalculados para: $projetoId');
    } catch (e) {
      _error = e.toString();
      print('❌ [PROJETO_PROVIDER] RECALCULAR_TOTAIS - Erro: $e');
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
    print('🔄 [PROJETO_PROVIDER] REFRESH - Recarregando projetos');
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