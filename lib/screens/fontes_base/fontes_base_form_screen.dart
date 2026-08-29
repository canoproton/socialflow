import 'package:flutter/material.dart';
import '../../models/fontes_base.dart';
import '../../services/fontes_base_service.dart';

class FontesBaseFormScreen extends StatefulWidget {
  final FontesBase? fonte;

  const FontesBaseFormScreen({Key? key, this.fonte}) : super(key: key);

  @override
  State<FontesBaseFormScreen> createState() => _FontesBaseFormScreenState();
}

class _FontesBaseFormScreenState extends State<FontesBaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FontesBaseService();
  
  late TextEditingController _descricaoController;
  late TextEditingController _entidadeController;
  late TextEditingController _valorController;
  late TextEditingController _remanejamentoController;
  late TextEditingController _obsController;
  
  DateTime? _dataAprovacao;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.fonte?.descricao ?? '');
    _entidadeController = TextEditingController(text: widget.fonte?.entidade ?? '');
    _valorController = TextEditingController(
      text: widget.fonte?.valor_recurso.toString() ?? '',
    );
    _remanejamentoController = TextEditingController(
      text: widget.fonte?.remanejamento.toString() ?? '15', // Default 15%
    );
    _obsController = TextEditingController(text: widget.fonte?.obs ?? '');
    _dataAprovacao = widget.fonte?.data_aprovacao ?? DateTime.now();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataAprovacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de aprovação')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fonte = FontesBase(
        id: widget.fonte?.id ?? '',
        descricao: _descricaoController.text,
        entidade: _entidadeController.text,
        valor_recurso: double.parse(_valorController.text),
        remanejamento: double.parse(_remanejamentoController.text),
        data_aprovacao: _dataAprovacao!,
        obs: _obsController.text.isNotEmpty ? _obsController.text : null,
        atualizado_por: 'sistema', // Será preenchido pelo backend
      );

      if (widget.fonte == null) {
        // ✅ NOVO: Validação de criação
        final saldo = await _service.getSaldoFonte(fonte.id);
        if (saldo < 0) {
          throw Exception('O valor do recurso não pode ser negativo');
        }
        await _service.create(fonte);
      } else {
        await _service.update(fonte);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.fonte == null 
                ? 'Fonte de recurso criada com sucesso!' 
                : 'Fonte de recurso atualizada com sucesso!'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fonte == null ? 'Nova Fonte de Recurso' : 'Editar Fonte de Recurso'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Descrição
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição da Fonte',
                    hintText: 'Ex: Edital 001/2024 - Lei Rouanet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite a descrição da fonte';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Entidade Financiadora
                TextFormField(
                  controller: _entidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Entidade Financiadora',
                    hintText: 'Ex: Ministério da Cultura',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite a entidade financiadora';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Valor do Recurso
                TextFormField(
                  controller: _valorController,
                  decoration: const InputDecoration(
                    labelText: 'Valor do Recurso (R$)',
                    hintText: 'Ex: 100000.00',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o valor do recurso';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Digite um valor válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Percentual de Remanejamento
                TextFormField(
                  controller: _remanejamentoController,
                  decoration: const InputDecoration(
                    labelText: 'Percentual de Remanejamento (%)',
                    hintText: 'Ex: 15',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                    helperText: 'Percentual que pode ser realocado para outros projetos',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o percentual de remanejamento';
                    }
                    final percent = double.tryParse(value);
                    if (percent == null || percent < 0 || percent > 100) {
                      return 'Digite um percentual entre 0 e 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Data de Aprovação
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dataAprovacao ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => _dataAprovacao = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de Aprovação/Liberação',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _dataAprovacao != null
                          ? '${_dataAprovacao!.day.toString().padLeft(2, '0')}/${_dataAprovacao!.month.toString().padLeft(2, '0')}/${_dataAprovacao!.year}'
                          : 'Selecione uma data',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Observações
                TextFormField(
                  controller: _obsController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    hintText: 'Informações adicionais sobre a fonte de recurso',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.comment),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(widget.fonte == null ? 'Criar' : 'Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}