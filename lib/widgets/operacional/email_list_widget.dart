/// ============================================
/// WIDGET: Lista de Emails (com Edição)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/operacional/email_model.dart';
import '../../theme/app_theme.dart';

class EmailListWidget extends StatefulWidget {
  final List<EmailModel> emails;
  final Function(List<EmailModel>) onChanged;
  final bool isEditing;

  const EmailListWidget({
    super.key,
    required this.emails,
    required this.onChanged,
    this.isEditing = true,
  });

  @override
  State<EmailListWidget> createState() => _EmailListWidgetState();
}

class _EmailListWidgetState extends State<EmailListWidget> {
  final _formKey = GlobalKey<FormState>();
  final _enderecoController = TextEditingController();
  String _uso = 'PARTICULAR';
  int? _editingIndex;

  void _abrirDialog({int? index}) {
    if (index != null) {
      final item = widget.emails[index];
      _enderecoController.text = item.endereco;
      _uso = item.uso;
      _editingIndex = index;
    } else {
      _enderecoController.clear();
      _uso = 'PARTICULAR';
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_editingIndex != null ? 'Editar Email' : 'Adicionar Email'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  hintText: 'exemplo@dominio.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email é obrigatório';
                  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!regex.hasMatch(value)) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _uso,
                decoration: const InputDecoration(labelText: 'Uso *'),
                items: EmailModel.usoLabels.entries.map((entry) {
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
                _salvarEmail();
                Navigator.pop(context);
              }
            },
            child: Text(_editingIndex != null ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  void _salvarEmail() {
    final email = EmailModel(
      id: _editingIndex != null 
          ? widget.emails[_editingIndex!].id 
          : 'temp_${DateTime.now().millisecondsSinceEpoch}',
      contatoId: '',
      uso: _uso,
      endereco: _enderecoController.text,
      obs: null,
    );

    final novaLista = List<EmailModel>.from(widget.emails);
    if (_editingIndex != null) {
      novaLista[_editingIndex!] = email;
    } else {
      novaLista.add(email);
    }
    
    widget.onChanged(novaLista);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingIndex != null ? 'Email atualizado!' : 'Email adicionado!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removerEmail(int index) {
    final novaLista = List<EmailModel>.from(widget.emails)..removeAt(index);
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
                const Icon(Icons.email, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text('Emails', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (widget.isEditing)
                  TextButton(
                    onPressed: () => _abrirDialog(),
                    child: const Text('+ Adicionar'),
                  ),
              ],
            ),
            const Divider(),
            if (widget.emails.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Nenhum email cadastrado', style: TextStyle(color: AppTheme.textLight)),
              )
            else
              ...widget.emails.asMap().entries.map((entry) {
                final index = entry.key;
                final email = entry.value;
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.email, size: 16),
                  title: Text(email.endereco),
                  subtitle: Text(email.usoLabel),
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
                              onPressed: () => _removerEmail(index),
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
