import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fontes/fontes_base_provider.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/fontes/fontes_base_model.dart';
import '../../models/enums/destino_tipo_enum.dart';

/// Tela de Registro/Edição de Fonte de Recurso
class FontesBaseFormScreen extends StatefulWidget {
  final FontesBase? fonte;

  const FontesBaseFormScreen({Key? key, this.fonte}) : super(key: key);

  @override
  State<FontesBaseFormScreen> createState() => _FontesBaseFormScreenState();
}

class _FontesBaseFormScreenState extends State<FontesBaseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descricaoController = TextEditingController();
  final _entidadeController = TextEditingController();
  final _valorController = TextEditingController();
  final _remanejamentoController = TextEditingController();
  final _obsController = TextEditingController();

  DateTime? _dataAprovacao;
  String? _destinoTipo = 'projeto';
  String? _destinoId;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.fonte != null;

    if (widget.fonte != null) {
      _descricaoController.text = widget.fonte!.descricao;
      _entidadeController.text = widget.fonte!.entidade;
      _valorController.text = widget.fonte!.valor_recurso.toString();
      _remanejamentoController.text = widget.fonte!.remanejamento?.toString() ?? '';
      _obsController.text = widget.fonte!.obs ?? '';
      _dataAprovacao = widget.fonte!.data_aprovacao;
    }

    // Carregar projetos para o dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjetoProvider>().loadProjetos();
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _entidadeController.dispose();
    _valorController.dispose();
    _remanejamentoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar destino
    if (_destinoId == null || _destinoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um Projeto para vincular'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;

    final fonte = FontesBase(
      id: widget.fonte?.id,
      descricao: _descricaoController.text,
      entidade: _entidadeController.text,
      valor_recurso: valor,
      remanejamento: double.tryParse(_remanejamentoController.text.replaceAll(',', '.')) ?? 0,
      data_aprovacao: _dataAprovacao,
      obs: _obsController.text.isNotEmpty ? _obsController.text : null,
    );

    try {
      await context.read<FontesBaseProvider>().salvarFonte(fonte);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Fonte atualizada com sucesso!' : 'Fonte registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FontesBaseProvider>();
    final projetos = context.watch<ProjetoProvider>().projetos;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Fonte de Recursos' : 'Registrar Fonte de Recursos'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _salvar,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ✅ Entidade
                    TextFormField(
                      controller: _entidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Entidade *',
                        hintText: 'Nome da entidade financiadora',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a entidade';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Descrição
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição *',
                        hintText: 'Descritivo da fonte de recursos',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Valor do Recurso
                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor do Recurso *',
                        hintText: '0,00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o valor';
                        }
                        final valor = double.tryParse(value.replaceAll(',', '.'));
                        if (valor == null || valor <= 0) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Percentual de Remanejamento
                    TextFormField(
                      controller: _remanejamentoController,
                      decoration: const InputDecoration(
                        labelText: 'Percentual de Remanejamento *',
                        hintText: '0,00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o percentual';
                        }
                        final valor = double.tryParse(value.replaceAll(',', '.'));
                        if (valor == null || valor < 0 || valor > 100) {
                          return 'Percentual inválido (0-100)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Data de Liberação
                    InkWell(
                      onTap: _selecionarData,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de Liberação *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dataAprovacao != null
                                    ? DateFormat('dd/MM/yyyy').format(_dataAprovacao!)
                                    : 'Selecione a data',
                              ),
                            ),
                            if (_dataAprovacao != null)
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => setState(() => _dataAprovacao = null),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Projeto Vinculado (Destino)
                    DropdownButtonFormField<String>(
                      value: _destinoId,
                      decoration: const InputDecoration(
                        labelText: 'Projeto Vinculado *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Selecione um projeto'),
                        ),
                        ...projetos.map((projeto) {
                          return DropdownMenuItem(
                            value: projeto.id,
                            child: Text(projeto.descricao ?? 'Sem descrição'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _destinoId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um projeto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Observações
                    TextFormField(
                      controller: _obsController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        hintText: 'Informações adicionais',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.comment),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // ✅ Botões
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Voltar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _salvar,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selecionarData() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dataAprovacao ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _dataAprovacao = date);
    }
  }
}