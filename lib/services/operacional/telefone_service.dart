/// ============================================
/// SERVIÇO: Telefone
/// ============================================
/// Gerencia operações CRUD para a tabela telefone
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/telefone_model.dart';

class TelefoneService {
  final BaseService<TelefoneModel> _service = BaseService<TelefoneModel>(
    tableName: 'telefone',
    fromJson: (json) => TelefoneModel.fromJson(json),
  );

  /// Lista todos os telefones
  Future<List<TelefoneModel>> list() async {
    return _service.list();
  }

  /// Busca um telefone por ID
  Future<TelefoneModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria um novo telefone
  Future<TelefoneModel> create(Map<String, dynamic> data) async {
    return _service.create(data);
  }

  /// Atualiza um telefone
  Future<TelefoneModel> update(String id, Map<String, dynamic> data) async {
    return _service.update(id, data);
  }

  /// Deleta um telefone
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  /// Busca telefones por contato
  Future<List<TelefoneModel>> findByContato(String contatoId) async {
    return _service.findBy('contato_id', contatoId);
  }
}
