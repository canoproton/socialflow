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
  // MÉTODO PÚBLICO PARA VERIFICAR CNPJ
  // ============================================
  Future<EmpresaModel?> checkCnpj(String cnpj) async {
    try {
      final cleanCnpj = cnpj.replaceAll(RegExp(r'\D'), '');
      if (cleanCnpj.isEmpty) return null;
      return await _service.findByCnpj(cleanCnpj);
    } catch (e) {
      print('Erro ao verificar CNPJ: $e');
      return null;
    }
  }

  Future<void> loadEmpresas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _empresas = await _service.list();
      
      for (var i = 0; i < _empresas.length; i++) {
        final contatos = await _service.getContatosVinculados(_empresas[i].id);
        final telefones = await _service.getTelefones(_empresas[i].id);
        final emails = await _service.getEmails(_empresas[i].id);
        final enderecos = await _service.getEnderecos(_empresas[i].id);
        final midias = await _service.getMidias(_empresas[i].id);
        
        _empresas[i] = _empresas[i].copyWith(
          contatos: contatos,
          telefones: telefones,
          emails: emails,
          enderecos: enderecos,
          midias: midias,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEmpresaById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final empresa = await _service.getById(id);
      if (empresa != null) {
        final contatos = await _service.getContatosVinculados(id);
        final telefones = await _service.getTelefones(id);
        final emails = await _service.getEmails(id);
        final enderecos = await _service.getEnderecos(id);
        final midias = await _service.getMidias(id);
        
        _selectedEmpresa = empresa.copyWith(
          contatos: contatos,
          telefones: telefones,
          emails: emails,
          enderecos: enderecos,
          midias: midias,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEmpresa(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Extrair o CNPJ e limpar
      final cnpj = data['cnpj']?.toString() ?? '';
      final cleanCnpj = cnpj.replaceAll(RegExp(r'\D'), '');
      
      // Verificar se o CNPJ já existe
      if (cleanCnpj.isNotEmpty) {
        try {
          final existing = await _service.findByCnpj(cleanCnpj);
          if (existing != null) {
            _error = 'CNPJ ${_formatCnpj(cleanCnpj)} já cadastrado para a empresa "${existing.nome}"';
            notifyListeners();
            _isLoading = false;
            return false;
          }
        } catch (e) {
          print('Erro ao verificar CNPJ: $e');
        }
      }
      
      // Extrair relacionamentos
      final contatos = data['contatos'] as List? ?? [];
      final telefones = data['telefones'] as List? ?? [];
      final emails = data['emails'] as List? ?? [];
      final enderecos = data['enderecos'] as List? ?? [];
      final midias = data['midias'] as List? ?? [];
      
      data.remove('contatos');
      data.remove('telefones');
      data.remove('emails');
      data.remove('enderecos');
      data.remove('midias');

      // Atualizar o CNPJ limpo no data
      if (cleanCnpj.isNotEmpty) {
        data['cnpj'] = cleanCnpj;
      }

      final empresa = await _service.create(data);
      
      await _service.saveRelacionamentos(
        empresa.id,
        contatos: contatos,
        telefones: telefones,
        emails: emails,
        enderecos: enderecos,
        midias: midias,
      );
      
      await loadEmpresaById(empresa.id);
      
      if (_selectedEmpresa != null) {
        _empresas.insert(0, _selectedEmpresa!);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('duplicate key value') || e.toString().contains('cnpj')) {
        _error = 'CNPJ já cadastrado. Verifique e tente novamente.';
      } else {
        _error = e.toString();
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmpresa(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Extrair o CNPJ e limpar
      final cnpj = data['cnpj']?.toString() ?? '';
      final cleanCnpj = cnpj.replaceAll(RegExp(r'\D'), '');
      
      // Verificar se o CNPJ já existe (exceto para a própria empresa)
      if (cleanCnpj.isNotEmpty) {
        try {
          final existing = await _service.findByCnpj(cleanCnpj);
          if (existing != null && existing.id != id) {
            _error = 'CNPJ ${_formatCnpj(cleanCnpj)} já cadastrado para a empresa "${existing.nome}"';
            notifyListeners();
            _isLoading = false;
            return false;
          }
        } catch (e) {
          print('Erro ao verificar CNPJ: $e');
        }
      }
      
      // Extrair relacionamentos
      final contatos = data['contatos'] as List? ?? [];
      final telefones = data['telefones'] as List? ?? [];
      final emails = data['emails'] as List? ?? [];
      final enderecos = data['enderecos'] as List? ?? [];
      final midias = data['midias'] as List? ?? [];
      
      data.remove('contatos');
      data.remove('telefones');
      data.remove('emails');
      data.remove('enderecos');
      data.remove('midias');

      // Atualizar o CNPJ limpo no data
      if (cleanCnpj.isNotEmpty) {
        data['cnpj'] = cleanCnpj;
      }

      await _service.update(id, data);
      
      await _service.saveRelacionamentos(
        id,
        contatos: contatos,
        telefones: telefones,
        emails: emails,
        enderecos: enderecos,
        midias: midias,
      );
      
      await loadEmpresaById(id);
      
      final index = _empresas.indexWhere((e) => e.id == id);
      if (index != -1 && _selectedEmpresa != null) {
        _empresas[index] = _selectedEmpresa!;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('duplicate key value') || e.toString().contains('cnpj')) {
        _error = 'CNPJ já cadastrado. Verifique e tente novamente.';
      } else {
        _error = e.toString();
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEmpresa(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      _empresas.removeWhere((e) => e.id == id);
      if (_selectedEmpresa?.id == id) _selectedEmpresa = null;
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

  void clearSelected() {
    _selectedEmpresa = null;
    notifyListeners();
  }

  String _formatCnpj(String cnpj) {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0,2)}.${cnpj.substring(2,5)}.${cnpj.substring(5,8)}/${cnpj.substring(8,12)}-${cnpj.substring(12,14)}';
  }
}
