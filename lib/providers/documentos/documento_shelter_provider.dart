import 'package:flutter/material.dart';
import '../../models/documentos/documento_shelter_model.dart';
import '../../models/documentos/documento_tipo_model.dart';
import '../../services/documentos/documento_shelter_service.dart';

class DocumentoShelterProvider extends ChangeNotifier {
  final DocumentoShelterService _service = DocumentoShelterService();

  List<DocumentoShelter> _documentos = [];
  List<DocumentoTipo> _tiposDocumento = [];
  DocumentoShelter? _documentoSelecionado;
  bool _isLoading = false;
  String? _erro;

  // Getters
  List<DocumentoShelter> get documentos => _documentos;
  List<DocumentoTipo> get tiposDocumento => _tiposDocumento;
  DocumentoShelter? get documentoSelecionado => _documentoSelecionado;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  /// Carrega documentos por domínio
  Future<void> carregarDocumentosPorDominio(
    String dominioTipo,
    String dominioId,
  ) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _documentos = await _service.listarPorDominio(dominioTipo, dominioId);
      if (_documentos.isEmpty) {
        _erro = 'Nenhum documento encontrado.';
      }
    } catch (e) {
      _erro = e.toString();
      _documentos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega tipos de documento
  Future<void> carregarTiposDocumento({bool onlyActive = true}) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _tiposDocumento = await _service.listarTiposDocumento(onlyActive: onlyActive);
      if (_tiposDocumento.isEmpty) {
        _erro = 'Nenhum tipo de documento encontrado.';
      }
    } catch (e) {
      _erro = e.toString();
      _tiposDocumento = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seleciona um documento
  Future<void> selecionarDocumento(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _documentoSelecionado = await _service.getById(id);
      if (_documentoSelecionado == null) {
        _erro = 'Documento não encontrado.';
      }
    } catch (e) {
      _erro = e.toString();
      _documentoSelecionado = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva um documento
  Future<void> salvarDocumento(DocumentoShelter documento) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final salvo = await _service.salvar(documento);
      _documentoSelecionado = salvo;

      // Atualizar a lista
      final index = _documentos.indexWhere((d) => d.id == salvo.id);
      if (index != -1) {
        _documentos[index] = salvo;
      } else {
        _documentos.add(salvo);
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove um documento
  Future<void> removerDocumento(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _service.deletar(id);
      _documentos.removeWhere((d) => d.id == id);
      if (_documentoSelecionado?.id == id) {
        _documentoSelecionado = null;
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza o status de um documento
  Future<void> atualizarStatusDocumento(
    String id,
    String novoStatus, {
    String? observacao,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final atualizado = await _service.atualizarStatus(id, novoStatus, observacao);

      // Atualizar na lista
      final index = _documentos.indexWhere((d) => d.id == id);
      if (index != -1) {
        _documentos[index] = atualizado;
      }

      if (_documentoSelecionado?.id == id) {
        _documentoSelecionado = atualizado;
      }
    } catch (e) {
      _erro = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa os dados
  void limparTudo() {
    _documentos = [];
    _documentoSelecionado = null;
    _erro = null;
    notifyListeners();
  }
}