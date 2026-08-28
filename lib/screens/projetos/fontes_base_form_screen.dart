/// ============================================
/// TELA: Formulário de Fonte de Recurso
/// REGRA 7
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../services/projetos/fontes_base_service.dart';
import '../../theme/app_theme.dart';

class FontesBaseFormScreen extends StatefulWidget {
  final String? fonteId;

  const FontesBaseFormScreen({super.key, this.fonteId});

  @override
  State<FontesBaseFormScreen> createState() => _FontesBaseFormScreenState();
}

class _FontesBaseFormScreenState extends State<FontesBaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _entidadeController = TextEditingController();
  final _valorController = TextEditingController();
  final _remanejamentoController = TextEditingController();
  final _dataAprovacaoController = TextEditingController();
  final _obsController = TextEditingController();

  final FontesBaseService _service = FontesBaseService();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.fonteId != null;
    if (_isEditing) {
      _carregarFonte();
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _entidadeController.dispose();
    _valorController.dispose();
    _remanejamentoController.dispose();
    _dataAprovacaoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _carregarFonte() async {
    setState(() => _isLoading = true);

    try {
      final fonte = await _service.getById(widget.fonteId!);
      if (fonte != null) {
        _descricaoController.text = fonte.descricao;
        _entidadeController.text = fonte.entidade;
        _valorController.text = fonte.valorRecurso.toString();
        _remanejamentoController.text = fonte.remanejamento?.toString() ?? '';
        _dataAprovacaoController.text = fonte.dataAprovacao != null
            ? DateFormat('yyyy-MM-dd').format(fonte.dataAprovacao!)
            : '';
        _obsController.text = fonte.obs ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar fonte: ${e.toString()}'),
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
        'entidade': _entidadeController.text,
        'valor_recurso': double.parse(_valorController.text),
        'remanejamento': _remanejamentoController.text.isNotEmpty
            ? double.parse(_remanejamentoController.text)
            : null,
        'data_aprovacao': _dataAprovacaoController.text.isNotEmpty
            ? DateTime.parse(_dataAprovacaoController.text).toIso8601String()
            : null,
        'obs': _obsController.text.isNotEmpty ? _obsController.text : null,
      };

      if (_isEditing) {
        await _service.update(widget.fonteId!, data);
      } else {
        await _service.create(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Fonte atualizada!' : 'Fonte criada!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/projetos/fontes');
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
        title: Text(_isEditing ? 'Editar Fonte de Recurso' : 'Nova Fonte de Recurso'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/projetos/fontes'),
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
                            TextFormField(
                              controller: _entidadeController,
                              decoration: const InputDecoration(
                                labelText: 'Entidade Financiadora *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entidade é obrigatória';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _valorController,
                              decoration: const InputDecoration(
                                labelText: 'Valor do Recurso (R\$) *',
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
                              controller: _remanejamentoController,
                              decoration: const InputDecoration(
                                labelText: 'Percentual de Remanejamento (%)',
                                border: OutlineInputBorder(),
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _dataAprovacaoController,
                              decoration: const InputDecoration(
                                labelText: 'Data de Aprovação',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, _dataAprovacaoController),
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
                          onPressed: () => context.go('/projetos/fontes'),
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