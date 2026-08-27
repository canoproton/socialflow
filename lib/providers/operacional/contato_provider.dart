/// ============================================
/// PROVIDER: Contato
/// ============================================

import 'package:flutter/material.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';
import '../../services/operacional/contato_service.dart';

class ContatoProvider extends ChangeNotifier {
  final ContatoService _service = ContatoService();

  List<ContatoModel> _contatos = [];
  ContatoModel? _selectedContato;
  bool _isLoading = false;
  String? _error;

  List<ContatoModel> get contatos => _contatos;
  ContatoModel? get selectedContato => _selectedContato;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadContatos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contatos = await _service.list();

      for (var i = 0; i < _contatos.length; i++) {
        final telefones = await _service.getTelefones(_contatos[i].id);
        final emails = await _service.getEmails(_contatos[i].id);
        final enderecos = await _service.getEnderecos(_contatos[i].id);
        final midias = await _service.getMidias(_contatos[i].id);

        _contatos[i] = _contatos[i].copyWith(
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

  Future<void> loadContatoById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final contato = await _service.getById(id);
      if (contato != null) {
        final telefones = await _service.getTelefones(id);
        final emails = await _service.getEmails(id);
        final enderecos = await _service.getEnderecos(id);
        final midias = await _service.getMidias(id);

        _selectedContato = contato.copyWith(
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

  Future<bool> createContato(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final contato = await _service.create(data);
      _contatos.insert(0, contato);
      _selectedContato = contato;
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

  Future<bool> updateContato(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final contato = await _service.update(id, data);

      final index = _contatos.indexWhere((c) => c.id == id);
      if (index != -1) {
        _contatos[index] = contato;
      }

      if (_selectedContato?.id == id) {
        _selectedContato = contato;
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

  Future<bool> deleteContato(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      _contatos.removeWhere((c) => c.id == id);
      if (_selectedContato?.id == id) {
        _selectedContato = null;
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

  void clearSelected() {
    _selectedContato = null;
    notifyListeners();
  }
}