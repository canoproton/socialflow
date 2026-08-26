/// ============================================
/// WIDGET: Lista de Endereços (com Edição)
/// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/operacional/endereco_model.dart';
import '../../theme/app_theme.dart';

class EnderecoListWidget extends StatefulWidget {
  final List<EnderecoModel> enderecos;
  final Function(List<EnderecoModel>) onChanged;
  final bool isEditing;

  const EnderecoListWidget({
    super.key,
    required this.enderecos,
    required this.onChanged,
    this.isEditing = true,
  });

  @override
  State<EnderecoListWidget> createState() => _EnderecoListWidgetState();
}

class _EnderecoListWidgetState extends State<EnderecoListWidget> {
  final _formKey = GlobalKey<FormState>();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _cepController = TextEditingController();
  String _estado = 'SP';
  int? _editingIndex;

  void _abrirDialog({int? index}) {
    if (index != null) {
      final item = widget.enderecos[index];
      _logradouroController.text = item.logradouro;
      _bairroController.text = item.bairro ?? '';
      _cidadeController.text = item.cidade;
      _estado = item.estado;
      _cepController.text = item.cep ?? '';
      _editingIndex = index;
    } else {
      _logradouroController.clear();
      _bairroController.clear();
      _cidadeController.clear();
      _cepController.clear();
      _estado = 'SP';
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_editingIndex != null ? 'Editar Endereço' : 'Adicionar Endereço'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _logradouroController,
                  decoration: const InputDecoration(
                    labelText: 'Logradouro *',
                    hintText: 'Rua, número, complemento',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Logradouro é obrigatório';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    hintText: 'Bairro (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(labelText: 'Cidade *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Cidade é obrigatória';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _estado,
                  decoration: const InputDecoration(labelText: 'Estado *'),
                  items: EnderecoModel.estados.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text('${entry.key} - ${entry.value}'),
                    );
                  }).toList(),
                  onChanged: (value) => _estado = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Estado é obrigatório';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cepController,
                  decoration: const InputDecoration(
                    labelText: 'CEP',
                    hintText: '00000-000 (opcional)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_CepInputFormatter()],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _salvarEndereco();
                Navigator.pop(context);
              }
            },
            child: Text(_editingIndex != null ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  void _salvarEndereco() {
    final endereco = EnderecoModel(
      id: _editingIndex != null 
          ? widget.enderecos[_editingIndex!].id 
          : 'temp_${DateTime.now().millisecondsSinceEpoch}',
      contatoId: '',
      logradouro: _logradouroController.text,
      bairro: _bairroController.text.isNotEmpty ? _bairroController.text : null,
      cidade: _cidadeController.text,
      estado: _estado,
      cep: _cepController.text.isNotEmpty ? _cepController.text : null,
      obs: null,
    );

    final novaLista = List<EnderecoModel>.from(widget.enderecos);
    if (_editingIndex != null) {
      novaLista[_editingIndex!] = endereco;
    } else {
      novaLista.add(endereco);
    }
    
    widget.onChanged(novaLista);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingIndex != null ? 'Endereço atualizado!' : 'Endereço adicionado!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removerEndereco(int index) {
    final novaLista = List<EnderecoModel>.from(widget.enderecos)..removeAt(index);
    widget.onChanged(novaLista);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text('Endereços', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (widget.isEditing)
                  TextButton(
                    onPressed: () => _abrirDialog(),
                    child: const Text('+ Adicionar'),
                  ),
              ],
            ),
            const Divider(),
            if (widget.enderecos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Nenhum endereço cadastrado', style: TextStyle(color: AppTheme.textLight)),
              )
            else
              ...widget.enderecos.asMap().entries.map((entry) {
                final index = entry.key;
                final endereco = entry.value;
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on, size: 16),
                  title: Text(endereco.logradouro),
                  subtitle: Text(endereco.enderecoCompleto),
                  trailing: widget.isEditing
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryColor),
                              onPressed: () => _abrirDialog(index: index),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerColor),
                              onPressed: () => _removerEndereco(index),
                              tooltip: 'Excluir',
                            ),
                          ],
                        )
                      : null,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 5) buffer.write('-');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
