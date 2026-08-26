/// ============================================
/// SERVIÇO: Midias
/// ============================================
/// Gerencia operações CRUD para a tabela midias
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/midias_model.dart';

class MidiasService {
  final BaseService<MidiasModel> _service = BaseService<MidiasModel>(
    tableName: 'midias',
    fromJson: (json) => MidiasModel.fromJson(json),
  );

  /// Lista todas as mídias
  Future<List<MidiasModel>> list() async {
    return _service.list();
  }

  /// Busca uma mídia por ID
  Future<MidiasModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria uma nova mídia
  Future<MidiasModel> create(Map<String, dynamic> data) async {
    return _service.create(data);
  }

  /// Atualiza uma mídia
  Future<MidiasModel> update(String id, Map<String, dynamic> data) async {
    return _service.update(id, data);
  }

  /// Deleta uma mídia
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  /// Busca mídias por contato
  Future<List<MidiasModel>> findByContato(String contatoId) async {
    return _service.findBy('contato_id', contatoId);
  }
}
