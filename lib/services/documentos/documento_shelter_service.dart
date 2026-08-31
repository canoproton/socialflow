import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/documentos/documento_shelter_model.dart';
import '../../models/documentos/documento_tipo_model.dart';

/// Service para operações com a tabela documento_shelter
class DocumentoShelterService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lista documentos por domínio (entidade)
  Future<List<DocumentoShelter>> listarPorDominio(
    String dominioTipo,
    String dominioId,
  ) async {
    try {
      print('📋 [DOCUMENTO_SHELTER_SERVICE] Listando documentos por domínio: $dominioTipo - $dominioId');

      final response = await _supabase
          .from('documento_shelter')
          .select('''
            *,
            tipo:documento_tipo(*)
          ''')
          .eq('dominio_tipo', dominioTipo)
          .eq('dominio_id', dominioId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => DocumentoShelter.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [DOCUMENTO_SHELTER_SERVICE] Erro ao listar por domínio: $e');
      return [];
    }
  }

  /// Busca um documento pelo ID
  Future<DocumentoShelter?> getById(String id) async {
    try {
      print('📋 [DOCUMENTO_SHELTER_SERVICE] Buscando documento por ID: $id');

      final response = await _supabase
          .from('documento_shelter')
          .select('''
            *,
            tipo:documento_tipo(*)
          ''')
          .eq('id', id)
          .single();

      return DocumentoShelter.fromJson(response);
    } catch (e) {
      print('❌ [DOCUMENTO_SHELTER_SERVICE] Erro ao buscar documento: $e');
      return null;
    }
  }

  /// Salva (cria ou atualiza) um documento
  Future<DocumentoShelter> salvar(DocumentoShelter documento) async {
    try {
      print('📋 [DOCUMENTO_SHELTER_SERVICE] Salvando documento...');
      print('📋 [DOCUMENTO_SHELTER_SERVICE] Dados: ${documento.toJson()}');

      // Buscar usuário atual
      final user = _supabase.auth.currentUser;
      final userId = user?.id;

      final data = documento.toJson();
      data['atualizado_por'] = userId;

      final response = await _supabase
          .from('documento_shelter')
          .upsert(data)
          .select()
          .single();

      print('✅ [DOCUMENTO_SHELTER_SERVICE] Documento salvo com sucesso');
      return DocumentoShelter.fromJson(response);
    } catch (e) {
      print('❌ [DOCUMENTO_SHELTER_SERVICE] Erro ao salvar: $e');
      throw e;
    }
  }

  /// Remove um documento
  Future<void> deletar(String id) async {
    try {
      print('📋 [DOCUMENTO_SHELTER_SERVICE] Removendo documento: $id');

      await _supabase
          .from('documento_shelter')
          .delete()
          .eq('id', id);

      print('✅ [DOCUMENTO_SHELTER_SERVICE] Documento removido com sucesso');
    } catch (e) {
      print('❌ [DOCUMENTO_SHELTER_SERVICE] Erro ao remover: $e');
      throw e;
    }
  }

  /// Atualiza o status de um documento
  Future<DocumentoShelter> atualizarStatus(
    String id,
    String novoStatus,
    String? observacao,
  ) async {
    try {
      print('📋 [DOCUMENTO_SHELTER_SERVICE] Atualizando status: $id → $novoStatus');

      final user = _supabase.auth.currentUser;
      final userId = user?.id;

      final data = {
        'status': novoStatus,
        'obs': observacao,
        'atualizado_por': userId,
        'atualizado_em': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('documento_shelter')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      print('✅ [DOCUMENTO_SHELTER_SERVICE] Status atualizado com sucesso');
      return DocumentoShelter.fromJson(response);
    } catch (e) {
      print('❌ [DOCUMENTO_SHELTER_SERVICE] Erro ao atualizar status: $e');
      throw e;
    }
  }

  /// Lista todos os tipos de documento disponíveis
  Future<List<DocumentoTipo>> listarTiposDocumento({bool onlyActive = true}) async {
    try {
      print('📋 [DOCUMENTO_SHELTER_SERVICE] Listando tipos de documento');

      var query = _supabase
          .from('documento_tipo')
          .select('*')
          .order('nome', ascending: true);

      if (onlyActive) {
        query = query.eq('ativo', true);
      }

      final response = await query;

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => DocumentoTipo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [DOCUMENTO_SHELTER_SERVICE] Erro ao listar tipos: $e');
      return [];
    }
  }

  /// Gera o caminho para armazenamento do arquivo
  String gerarCaminhoArquivo(String dominioTipo, String dominioId, String nomeOriginal) {
    final now = DateTime.now();
    final extension = nomeOriginal.split('.').last;
    final timestamp = now.millisecondsSinceEpoch;
    final randomId = DateTime.now().microsecondsSinceEpoch;

    return 'documentos/dominio_tipo/$dominioTipo/dominio_id/$dominioId/${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/$timestamp-$randomId.$extension';
  }

  /// Gera hash SHA-256 do arquivo
  String gerarHashArquivo(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }
}