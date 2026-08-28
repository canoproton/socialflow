/// ============================================
/// TELA: Formulário de Contra Partida
/// REGRA 11
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/contra_partida_model.dart';
import '../../models/projetos/tipo_ct_partida_model.dart';
import '../../services/projetos/contra_partida_service.dart';
import '../../theme/app_theme.dart';

class ContraPartidaFormScreen extends StatefulWidget {
  final String? contraPartidaId;

  const ContraPartidaFormScreen({super.key, this.contraPartidaId});

  @override
  State<ContraPartidaFormScreen> createState() => _ContraPartidaFormScreenState();
}

class _ContraPartidaFormScreenState extends State<ContraPartidaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _dataEntregaController = TextEditingController();
  final _obsController = TextEditingController();

  final ContraPartidaService _service = ContraPartidaService();
  List<TipoCtPartidaModel> _tipos = [];
  String? _tipoId;
  String _status = ContraPartidaModel.STATUS_PENDENTE;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.contraPartidaId != null;
    _carregarTipos();
    if (_isEditing) {
      _carregarContraPartida();
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _quantidadeController.dispose();
    _dataEntregaController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _carregarTipos() async {
    try {
      _tipos = await _service.listTipos();
      if (_tipos.isNotEmpty) {
        _tipoId = _tipos[0].id;
      }
    } catch (e) {
      print('Erro ao carregar tipos: $e');
    }
  }

  Future<void> _carregarContraPartida() async {
    setState(() => _isLoading = true);

    try {
      final cp = await _service.getById(widget.contraPartidaId!);
      if (cp != null) {
        _descricaoController.text = cp.descricao;
        _valorController.text = cp.valor.toString();
        _quantidadeController.text = cp.quantidade?.toString() ?? '';
        _dataEntregaController.text = cp.dataEntrega != null
            ? DateFormat('yyyy-MM-dd').format(cp.dataEntrega!)
            : '';
        _obsController.text = cp.obs ?? '';
        _tipoId = cp.tipoId;
        _status = cp.status;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'descricao': _descricaoController.text,
        'tipo': _tipoId,
        'valor': double.parse(_valorController.text),
        'quantidade': _quantidadeController.text.isNotEmpty
            ? double.parse(_quantidadeController.text)
            : null,
        'dataentrega': _dataEntregaController.text.isNotEmpty
            ? DateTime.parse(_dataEntregaController.text).toIso8601String()
            : null,
        'status': _status,
        'obs': _obsController.text.isNotEmpty ? _obsController.text : null,
      };

      if (_isEditing) {
        await _service.update(widget.contraPartidaId!, data);
      } else {
        await _service.create(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Contra partida atualizada!' : 'Contra partida criada!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/projetos/contra-partidas');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Contra Partida' : 'Nova Contra Partida'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/projetos/contra-partidas'),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _salvar,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _descricaoController,
                              decoration: const InputDecoration(
                                labelText: 'Descrição *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Descrição é obrigatória';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _tipoId,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de Contra Partida *',
                                border: OutlineInputBorder(),
                              ),
                              items: _tipos.map((tipo) {
                                return DropdownMenuItem(
                                  value: tipo.id,
                                  child: Text(tipo.descricao),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _tipoId = value),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _valorController,
                              decoration: const InputDecoration(
                                labelText: 'Valor (R\$) *',
                                border: OutlineInputBorder(),
                                prefixText: 'R\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Valor é obrigatório';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _quantidadeController,
                              decoration: const InputDecoration(
                                labelText: 'Quantidade',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _dataEntregaController,
                              decoration: const InputDecoration(
                                labelText: 'Data de Entrega',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, _dataEntregaController),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: ContraPartidaModel.statusOptions.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(ContraPartidaModel.statusLabels[status] ?? status),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _status = value!),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _obsController,
                              decoration: const InputDecoration(
                                labelText: 'Observações',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go('/projetos/contra-partidas'),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _salvar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_isLoading ? 'Salvando...' : 'Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
}