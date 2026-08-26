/// ============================================
/// SERVIÇO: Email
/// ============================================
/// Gerencia operações CRUD para a tabela email
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/email_model.dart';

class EmailService {
  final BaseService<EmailModel> _service = BaseService<EmailModel>(
    tableName: 'email',
    fromJson: (json) => EmailModel.fromJson(json),
  );

  /// Lista todos os emails
  Future<List<EmailModel>> list() async {
    return _service.list();
  }

  /// Busca um email por ID
  Future<EmailModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria um novo email
  Future<EmailModel> create(Map<String, dynamic> data) async {
    return _service.create(data);
  }

  /// Atualiza um email
  Future<EmailModel> update(String id, Map<String, dynamic> data) async {
    return _service.update(id, data);
  }

  /// Deleta um email
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  /// Busca emails por contato
  Future<List<EmailModel>> findByContato(String contatoId) async {
    return _service.findBy('contato_id', contatoId);
  }
}
