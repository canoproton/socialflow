/// ============================================
/// PROVIDER: Empresa
/// ============================================

import 'package:flutter/material.dart';
import '../../models/operacional/empresa_model.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';
import '../../services/operacional/empresa_service.dart';

class EmpresaProvider extends ChangeNotifier {
  final EmpresaService _service = EmpresaService();

  List<EmpresaModel> _empresas = [];
  EmpresaModel? _selectedEmpresa;
  bool _isLoading = false;
  String? _error;

  List<EmpresaModel> get empresas => _empresas;
  EmpresaModel? get selectedEmpresa => _selectedEmpresa;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================
  // LISTAR EMPRESAS
  // ============================================

  Future<void> loadEmpresas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _empresas = await _service.list();

      for (var i = 0; i < _empresas.length; i++) {
        final contatos = await _service.getContatos(_empresas[i].id);
        final contatoPrincipalId = _empresas[i].contatoPrincipalId;

        if (contatoPrincipalId != null) {
          final telefones = await _service.getTelefones(contatoPrincipalId);
          final emails = await _service.getEmails(contatoPrincipalId);
          final enderecos = await _service.getEnderecos(contatoPrincipalId);
          final midias = await _service.getMidias(contatoPrincipalId);

          _empresas[i] = _empresas[i].copyWith(
            contatos: contatos,
            telefones: telefones,
            emails: emails,
            enderecos: enderecos,
            midias: midias,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARREGAR EMPRESA POR ID
  // ============================================

  Future<void> loadEmpresaById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final empresa = await _service.getById(id);
      if (empresa != null) {
        final contatos = await _service.getContatos(id);
        final contatoPrincipalId = empresa.contatoPrincipalId;

        if (contatoPrincipalId != null) {
          final telefones = await _service.getTelefones(contatoPrincipalId);
          final emails = await _service.getEmails(contatoPrincipalId);
          final enderecos = await _service.getEnderecos(contatoPrincipalId);
          final midias = await _service.getMidias(contatoPrincipalId);

          _selectedEmpresa = empresa.copyWith(
            contatos: contatos,
            telefones: telefones,
            emails: emails,
            enderecos: enderecos,
            midias: midias,
          );
        } else {
          _selectedEmpresa = empresa.copyWith(
            contatos: contatos,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CRIAR EMPRESA
  // ============================================

  Future<EmpresaModel?> createEmpresa(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final empresa = await _service.create(data);
      _empresas.insert(0, empresa);
      _selectedEmpresa = empresa;
      notifyListeners();
      return empresa;  // ⭐ RETORNA EmpresaModel
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;  // ⭐ RETORNA NULL EM CASO DE ERRO
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // ATUALIZAR EMPRESA
  // ============================================

  Future<bool> updateEmpresa(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final empresa = await _service.update(id, data);

      final index = _empresas.indexWhere((e) => e.id == id);
      if (index != -1) {
        _empresas[index] = empresa;
      }

      if (_selectedEmpresa?.id == id) {
        _selectedEmpresa = empresa;
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
  // DELETAR EMPRESA
  // ============================================

  Future<bool> deleteEmpresa(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      _empresas.removeWhere((e) => e.id == id);
      if (_selectedEmpresa?.id == id) {
        _selectedEmpresa = null;
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
  // VINCULAR CONTATO
  // ============================================

  Future<bool> vincularContato(String empresaId, String contatoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.vincularContato(empresaId, contatoId);
      await loadEmpresaById(empresaId);
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
  // DESVINCULAR CONTATO
  // ============================================

  Future<bool> desvincularContato(String empresaId, String contatoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.desvincularContato(empresaId, contatoId);
      await loadEmpresaById(empresaId);
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
    _selectedEmpresa = null;
    notifyListeners();
  }
}