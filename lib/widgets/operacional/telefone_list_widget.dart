/// ============================================
/// WIDGET: Lista de Telefones (com Edição)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/operacional/telefone_model.dart';
import '../../theme/app_theme.dart';

class TelefoneListWidget extends StatefulWidget {
  final List<TelefoneModel> telefones;
  final Function(List<TelefoneModel>) onChanged;
  final bool isEditing;

  const TelefoneListWidget({
    super.key,
    required this.telefones,
    required this.onChanged,
    this.isEditing = true,
  });

  @override
  State<TelefoneListWidget> createState() => _TelefoneListWidgetState();
}

class _TelefoneListWidgetState extends State<TelefoneListWidget> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  String _uso = 'PARTICULAR';
  int? _editingIndex;

  void _abrirDialog({int? index}) {
    if (index != null) {
      // Edição
      final item = widget.telefones[index];
      _numeroController.text = item.numero;
      _uso = item.uso;
      _editingIndex = index;
    } else {
      // Novo
      _numeroController.clear();
      _uso = 'PARTICULAR';
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_editingIndex != null ? 'Editar Telefone' : 'Adicionar Telefone'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número *',
                  hintText: '(11) 99999-9999',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Número é obrigatório';
                  final clean = value.replaceAll(RegExp(r'\D'), '');
                  if (clean.length < 10) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _uso,
                decoration: const InputDecoration(labelText: 'Uso *'),
                items: TelefoneModel.usoLabels.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (value) => _uso = value!,
              ),
            ],
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
                _salvarTelefone();
                Navigator.pop(context);
              }
            },
            child: Text(_editingIndex != null ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  void _salvarTelefone() {
    final telefone = TelefoneModel(
      id: _editingIndex != null 
          ? widget.telefones[_editingIndex!].id 
          : 'temp_${DateTime.now().millisecondsSinceEpoch}',
      contatoId: '',
      uso: _uso,
      numero: _numeroController.text,
      obs: null,
    );

    final novaLista = List<TelefoneModel>.from(widget.telefones);
    if (_editingIndex != null) {
      novaLista[_editingIndex!] = telefone;
    } else {
      novaLista.add(telefone);
    }
    
    widget.onChanged(novaLista);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingIndex != null ? 'Telefone atualizado!' : 'Telefone adicionado!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removerTelefone(int index) {
    final novaLista = List<TelefoneModel>.from(widget.telefones)..removeAt(index);
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
                const Icon(Icons.phone, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text('Telefones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (widget.isEditing)
                  TextButton(
                    onPressed: () => _abrirDialog(),
                    child: const Text('+ Adicionar'),
                  ),
              ],
            ),
            const Divider(),
            if (widget.telefones.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Nenhum telefone cadastrado', style: TextStyle(color: AppTheme.textLight)),
              )
            else
              ...widget.telefones.asMap().entries.map((entry) {
                final index = entry.key;
                final telefone = entry.value;
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.phone, size: 16),
                  title: Text(telefone.numeroFormatado),
                  subtitle: Text(telefone.usoLabel),
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
                              onPressed: () => _removerTelefone(index),
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
