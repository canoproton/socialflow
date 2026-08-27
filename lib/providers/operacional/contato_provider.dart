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

  // ============================================
  // LISTAR CONTATOS
  // ============================================

  Future<void> loadContatos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contatos = await _service.list();

      // Carregar relacionamentos de cada contato
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
      print('Erro ao carregar contatos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARREGAR CONTATO POR ID
  // ============================================

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
      print('Erro ao carregar contato: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CRIAR CONTATO
  // ============================================

  Future<ContatoModel?> createContato(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Extrair relacionamentos
      final telefonesData = data.remove('telefones') as List? ?? [];
      final emailsData = data.remove('emails') as List? ?? [];
      final enderecosData = data.remove('enderecos') as List? ?? [];
      final midiasData = data.remove('midias') as List? ?? [];

      // ⭐ CRIAR CONTATO E PEGAR O ID
      final contato = await _service.create(data);
      
      // ⭐ VERIFICAR SE O ID FOI GERADO
      if (contato.id.isEmpty) {
        throw Exception('Contato criado sem ID válido');
      }

      final contatoId = contato.id;
      
      // Adicionar relacionamentos
      for (var telefone in telefonesData) {
        await _service.adicionarRelacionamento(contatoId, 'telefone', telefone);
      }
      for (var email in emailsData) {
        await _service.adicionarRelacionamento(contatoId, 'email', email);
      }
      for (var endereco in enderecosData) {
        await _service.adicionarRelacionamento(contatoId, 'endereco', endereco);
      }
      for (var midia in midiasData) {
        await _service.adicionarRelacionamento(contatoId, 'midias', midia);
      }

      await loadContatos();
      
      _selectedContato = contato;
      notifyListeners();
      
      return contato;
    } catch (e) {
      _error = e.toString();
      print('Erro ao criar contato: $e');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // ATUALIZAR CONTATO
  // ============================================

  Future<bool> updateContato(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Extrair relacionamentos
      final telefonesData = data.remove('telefones') as List? ?? [];
      final emailsData = data.remove('emails') as List? ?? [];
      final enderecosData = data.remove('enderecos') as List? ?? [];
      final midiasData = data.remove('midias') as List? ?? [];

      // Atualizar contato
      final contato = await _service.update(id, data);
      
      // Atualizar relacionamentos
      await _salvarRelacionamentos(id, {
        'telefones': telefonesData,
        'emails': emailsData,
        'enderecos': enderecosData,
        'midias': midiasData,
      });

      // Recarregar lista
      await loadContatos();
      
      _selectedContato = contato;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Erro ao atualizar contato: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // SALVAR RELACIONAMENTOS (GENÉRICO)
  // ============================================

  Future<void> _salvarRelacionamentos(String contatoId, Map<String, dynamic> dados) async {
    try {
      final telefones = dados['telefones'] as List? ?? [];
      final emails = dados['emails'] as List? ?? [];
      final enderecos = dados['enderecos'] as List? ?? [];
      final midias = dados['midias'] as List? ?? [];

      // Telefones
      if (telefones.isNotEmpty) {
        // Limpar existentes
        await _service.limparRelacionamentos(contatoId, 'telefone');
        // Adicionar novos
        for (var telefone in telefones) {
          await _service.adicionarRelacionamento(contatoId, 'telefone', telefone);
        }
      }

      // Emails
      if (emails.isNotEmpty) {
        await _service.limparRelacionamentos(contatoId, 'email');
        for (var email in emails) {
          await _service.adicionarRelacionamento(contatoId, 'email', email);
        }
      }

      // Endereços
      if (enderecos.isNotEmpty) {
        await _service.limparRelacionamentos(contatoId, 'endereco');
        for (var endereco in enderecos) {
          await _service.adicionarRelacionamento(contatoId, 'endereco', endereco);
        }
      }

      // Mídias
      if (midias.isNotEmpty) {
        await _service.limparRelacionamentos(contatoId, 'midias');
        for (var midia in midias) {
          await _service.adicionarRelacionamento(contatoId, 'midias', midia);
        }
      }
    } catch (e) {
      print('Erro ao salvar relacionamentos: $e');
    }
  }

  // ============================================
  // DELETAR CONTATO
  // ============================================

  Future<bool> deleteContato(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      await loadContatos();
      if (_selectedContato?.id == id) {
        _selectedContato = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Erro ao deletar contato: $e');
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
    _selectedContato = null;
    notifyListeners();
  }

  void refresh() {
    loadContatos();
  }
}