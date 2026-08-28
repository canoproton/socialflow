/// ============================================
/// TELA: Formulário de Alocação de Recurso
/// REGRA 7
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/fonte_alocacao_model.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../models/projetos/projeto_model.dart';
import '../../services/projetos/fontes_base_service.dart';
import '../../services/projetos/projeto_service.dart';
import '../../theme/app_theme.dart';
import 'fonte_alocacao_list_screen.dart';

class FonteAlocacaoFormScreen extends StatefulWidget {
  final String? alocacaoId;
  final String? fonteId;

  const FonteAlocacaoFormScreen({
    super.key,
    this.alocacaoId,
    this.fonteId,
  });

  @override
  State<FonteAlocacaoFormScreen> createState() => _FonteAlocacaoFormScreenState();
}

class _FonteAlocacaoFormScreenState extends State<FonteAlocacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataAlocacaoController = TextEditingController();
  final _obsController = TextEditingController();

  final FontesBaseService _service = FontesBaseService();
  final ProjetoService _projetoService = ProjetoService();
  
  List<FontesBaseModel> _fontes = [];
  List<ProjetoModel> _projetos = [];
  String? _fonteId;
  String? _destinoId;
  bool _isLoading = false;
  bool _isEditing = false;
  double _saldoDisponivel = 0;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.alocacaoId != null;
    _fonteId = widget.fonteId;
    _carregarDados();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataAlocacaoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      _fontes = await _service.list();
      _projetos = await _projetoService.list();

      if (widget.fonteId != null && _fontes.isNotEmpty) {
        _fonteId = widget.fonteId;
        await _calcularSaldo();
      }

      if (_isEditing) {
        // TODO: Carregar alocação para edição
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calcularSaldo() async {
    if (_fonteId == null) {
      setState(() => _saldoDisponivel = 0);
      return;
    }

    try {
      final fonte = await _service.getById(_fonteId!);
      if (fonte != null) {
        final alocacoes = await _service.getAlocacoes(_fonteId!);
        double totalAlocado = 0;
        for (var aloc in alocacoes) {
          totalAlocado += aloc.valorAlocado;
        }
        setState(() {
          _saldoDisponivel = fonte.valorRecurso - totalAlocado;
        });
      }
    } catch (e) {
      print('Erro ao calcular saldo: $e');
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'fonte_alocacao': _fonteId,
        'destino_alocacao': _destinoId,
        'descricao': _descricaoController.text,
        'valor_alocado': double.parse(_valorController.text),
        'data_alocacao': _dataAlocacaoController.text.isNotEmpty
            ? DateTime.parse(_dataAlocacaoController.text).toIso8601String()
            : null,
        'obs': _obsController.text.isNotEmpty ? _obsController.text : null,
      };

      if (_isEditing) {
        // TODO: Atualizar alocação
      } else {
        await _service.createAlocacao(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Alocação atualizada!' : 'Alocação criada!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // ⭐ VOLTAR PARA A LISTA
      Navigator.pop(context, true);
      
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
        title: Text(_isEditing ? 'Editar Alocação' : 'Nova Alocação'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                            // Fonte de Recurso
                            DropdownButtonFormField<String>(
                              value: _fonteId,
                              decoration: const InputDecoration(
                                labelText: 'Fonte de Recurso *',
                                border: OutlineInputBorder(),
                              ),
                              items: _fontes.map((fonte) {
                                return DropdownMenuItem(
                                  value: fonte.id,
                                  child: Text(fonte.descricao),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _fonteId = value;
                                  _calcularSaldo();
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione uma fonte';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Saldo Disponível
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _saldoDisponivel > 0
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _saldoDisponivel > 0
                                      ? Colors.green
                                      : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Saldo Disponível:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${_saldoDisponivel.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: _saldoDisponivel > 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Destino (Projeto)
                            DropdownButtonFormField<String>(
                              value: _destinoId,
                              decoration: const InputDecoration(
                                labelText: 'Destino (Projeto) *',
                                border: OutlineInputBorder(),
                              ),
                              items: _projetos.map((projeto) {
                                return DropdownMenuItem(
                                  value: projeto.id,
                                  child: Text(projeto.descricao ?? 'Projeto sem título'),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _destinoId = value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione um destino';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Descrição
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

                            // Valor Alocado
                            TextFormField(
                              controller: _valorController,
                              decoration: const InputDecoration(
                                labelText: 'Valor Alocado (R\$) *',
                                border: OutlineInputBorder(),
                                prefixText: 'R\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Valor é obrigatório';
                                }
                                final valor = double.tryParse(value);
                                if (valor == null) {
                                  return 'Valor inválido';
                                }
                                if (valor > _saldoDisponivel) {
                                  return 'Valor excede o saldo disponível';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Data de Alocação
                            TextFormField(
                              controller: _dataAlocacaoController,
                              decoration: const InputDecoration(
                                labelText: 'Data de Alocação',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, _dataAlocacaoController),
                            ),
                            const SizedBox(height: 16),

                            // Observações
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
                          onPressed: () => Navigator.pop(context),
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