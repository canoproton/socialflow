/// ============================================
/// SERVIÇO: Endereco
/// ============================================
/// Gerencia operações CRUD para a tabela endereco
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/endereco_model.dart';

class EnderecoService {
  final BaseService<EnderecoModel> _service = BaseService<EnderecoModel>(
    tableName: 'endereco',
    fromJson: (json) => EnderecoModel.fromJson(json),
  );

  /// Lista todos os endereços
  Future<List<EnderecoModel>> list() async {
    return _service.list();
  }

  /// Busca um endereço por ID
  Future<EnderecoModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria um novo endereço
  Future<EnderecoModel> create(Map<String, dynamic> data) async {
    return _service.create(data);
  }

  /// Atualiza um endereço
  Future<EnderecoModel> update(String id, Map<String, dynamic> data) async {
    return _service.update(id, data);
  }

  /// Deleta um endereço
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  /// Busca endereços por contato
  Future<List<EnderecoModel>> findByContato(String contatoId) async {
    return _service.findBy('contato_id', contatoId);
  }
}
