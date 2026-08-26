/// ============================================
/// SERVIÇO: Funcao
/// ============================================
/// Gerencia operações CRUD para a tabela funcao
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/funcao_model.dart';

class FuncaoService {
  final BaseService<FuncaoModel> _service = BaseService<FuncaoModel>(
    tableName: 'funcao',
    fromJson: (json) => FuncaoModel.fromJson(json),
  );

  /// Lista todas as funções
  Future<List<FuncaoModel>> list() async {
    return _service.list();
  }

  /// Busca uma função por ID
  Future<FuncaoModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria uma nova função
  Future<FuncaoModel> create(String descricao) async {
    return _service.create({'descricao': descricao});
  }

  /// Atualiza uma função
  Future<FuncaoModel> update(String id, String descricao) async {
    return _service.update(id, {'descricao': descricao});
  }

  /// Deleta uma função
  Future<void> delete(String id) async {
    await _service.delete(id);
  }
}
