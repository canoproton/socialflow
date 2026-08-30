import 'package:flutter/material.dart';
import '../models/projetos/projeto_model.dart';
import '../models/fonte_alocacao.dart';
import '../services/projetos/projeto_service.dart';
import '../services/fontes_base_service.dart';

class ProjetoProvider extends ChangeNotifier {
  final ProjetoService _projetoService = ProjetoService();
  final FontesBaseService _fontesBaseService = FontesBaseService();
  
  List<Projeto> _projetos = [];
  bool _isLoading = false;
  String? _error;

  List<Projeto> get projetos => _projetos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProjetos({String? search, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Busca todos os projetos
      final projetos = await _projetoService.list();
      
      // Para cada projeto, busca as alocações e recalcula valor_total_aportado
      for (var projeto in projetos) {
        final alocacoes = await _fontesBaseService.getAlocacoesByProjeto(projeto.id);
        final totalAportado = alocacoes.fold(0.0, (sum, a) => sum + a.valor_alocado);
        
        // ✅ CORRETO: Atualiza o projeto com o valor calculado
        projeto.valorTotalAportado = totalAportado;
        projeto.saldoProjeto = totalAportado - (projeto.valorTotalMetas ?? 0);
      }

      // Aplica filtros
      var filtered = projetos;
      if (search != null && search.isNotEmpty) {
        filtered = filtered.where((p) =>
          p.descricao.toLowerCase().contains(search.toLowerCase()) ||
          p.processo.toLowerCase().contains(search.toLowerCase()) ||
          p.proponente.nome.toLowerCase().contains(search.toLowerCase())
        ).toList();
      }
      if (status != null && status.isNotEmpty) {
        filtered = filtered.where((p) => p.statusProjeto == status).toList();
      }

      _projetos = filtered;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProjeto(Projeto projeto) async {
    try {
      await _projetoService.update(projeto.id, projeto.toJson());
      await loadProjetos();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}