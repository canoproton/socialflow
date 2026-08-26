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
import '../../services/operacional/relacionamento_service.dart';

class ContatoProvider extends ChangeNotifier {
  final ContatoService _service = ContatoService();
  final RelacionamentoService _relService = RelacionamentoService();
  
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
      print('✅ Contatos carregados: ${_contatos.length}');
    } catch (e) {
      _error = e.toString();
      print('❌ Erro ao carregar contatos: $e');
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
        print('✅ Contato carregado: ${_selectedContato?.nome}');
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
      print('=== CRIANDO CONTATO ===');
      
      // ⭐ EXTRAIR E CASTAR CORRETAMENTE
      final telefones = (data['telefones'] as List?)?.cast<TelefoneModel>() ?? [];
      final emails = (data['emails'] as List?)?.cast<EmailModel>() ?? [];
      final enderecos = (data['enderecos'] as List?)?.cast<EnderecoModel>() ?? [];
      final midias = (data['midias'] as List?)?.cast<MidiasModel>() ?? [];
      
      data.remove('telefones');
      data.remove('emails');
      data.remove('enderecos');
      data.remove('midias');

      final contato = await _service.create(data);
      print('✅ Contato criado: ${contato.id} - ${contato.nome}');
      
      final telefonesSalvos = await _relService.saveTelefones(contato.id, telefones);
      final emailsSalvos = await _relService.saveEmails(contato.id, emails);
      final enderecosSalvos = await _relService.saveEnderecos(contato.id, enderecos);
      final midiasSalvas = await _relService.saveMidias(contato.id, midias);
      
      _selectedContato = contato.copyWith(
        telefones: telefonesSalvos,
        emails: emailsSalvos,
        enderecos: enderecosSalvos,
        midias: midiasSalvas,
      );
      
      await loadContatos();
      
      print('✅ Contato criado e listas atualizadas');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erro ao criar contato: $e');
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
      print('=== ATUALIZANDO CONTATO ===');
      
      // ⭐ EXTRAIR E CASTAR CORRETAMENTE
      final telefones = (data['telefones'] as List?)?.cast<TelefoneModel>() ?? [];
      final emails = (data['emails'] as List?)?.cast<EmailModel>() ?? [];
      final enderecos = (data['enderecos'] as List?)?.cast<EnderecoModel>() ?? [];
      final midias = (data['midias'] as List?)?.cast<MidiasModel>() ?? [];
      
      data.remove('telefones');
      data.remove('emails');
      data.remove('enderecos');
      data.remove('midias');

      final contato = await _service.update(id, data);
      print('✅ Contato atualizado: ${contato.id}');
      
      final telefonesSalvos = await _relService.saveTelefones(id, telefones);
      final emailsSalvos = await _relService.saveEmails(id, emails);
      final enderecosSalvos = await _relService.saveEnderecos(id, enderecos);
      final midiasSalvas = await _relService.saveMidias(id, midias);
      
      _selectedContato = contato.copyWith(
        telefones: telefonesSalvos,
        emails: emailsSalvos,
        enderecos: enderecosSalvos,
        midias: midiasSalvas,
      );
      
      await loadContatos();
      
      print('✅ Contato atualizado e listas atualizadas');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erro ao atualizar contato: $e');
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
      await loadContatos();
      if (_selectedContato?.id == id) _selectedContato = null;
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
