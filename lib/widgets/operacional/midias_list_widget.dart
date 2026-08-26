/// ============================================
/// WIDGET: Lista de Mídias Sociais (com Edição)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/operacional/midias_model.dart';
import '../../theme/app_theme.dart';

class MidiasListWidget extends StatefulWidget {
  final List<MidiasModel> midias;
  final Function(List<MidiasModel>) onChanged;
  final bool isEditing;

  const MidiasListWidget({
    super.key,
    required this.midias,
    required this.onChanged,
    this.isEditing = true,
  });

  @override
  State<MidiasListWidget> createState() => _MidiasListWidgetState();
}

class _MidiasListWidgetState extends State<MidiasListWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  String _uso = 'PARTICULAR';
  String _tipo = 'APLICATIVO';
  String? _nomeDoApp;
  int? _editingIndex;

  void _abrirDialog({int? index}) {
    if (index != null) {
      final item = widget.midias[index];
      _descricaoController.text = item.descricao;
      _uso = item.uso;
      _tipo = item.tipo;
      _nomeDoApp = item.nomeDoApp;
      _editingIndex = index;
    } else {
      _descricaoController.clear();
      _uso = 'PARTICULAR';
      _tipo = 'APLICATIVO';
      _nomeDoApp = null;
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_editingIndex != null ? 'Editar Mídia Social' : 'Adicionar Mídia Social'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _nomeDoApp,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Aplicativo',
                    hintText: 'Selecione o aplicativo',
                    prefixIcon: Icon(Icons.apps),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Selecione...')),
                    const DropdownMenuItem(value: 'Site', child: Text('Site')),
                    ...MidiasModel.appsComuns.map((app) {
                      return DropdownMenuItem(value: app, child: Text(app));
                    }),
                  ],
                  onChanged: (value) => setState(() => _nomeDoApp = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição *',
                    hintText: 'Link, usuário ou identificador',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Descrição é obrigatória';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo *',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: MidiasModel.tipoLabels.entries.map((entry) {
                    return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                  }).toList(),
                  onChanged: (value) => setState(() => _tipo = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _uso,
                  decoration: const InputDecoration(
                    labelText: 'Uso *',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: MidiasModel.usoLabels.entries.map((entry) {
                    return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                  }).toList(),
                  onChanged: (value) => setState(() => _uso = value!),
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
                _salvarMidia();
                Navigator.pop(context);
              }
            },
            child: Text(_editingIndex != null ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  void _salvarMidia() {
    final midia = MidiasModel(
      id: _editingIndex != null 
          ? widget.midias[_editingIndex!].id 
          : 'temp_${DateTime.now().millisecondsSinceEpoch}',
      contatoId: '',
      uso: _uso,
      tipo: _tipo,
      nomeDoApp: _nomeDoApp,
      descricao: _descricaoController.text,
      obs: null,
    );

    final novaLista = List<MidiasModel>.from(widget.midias);
    if (_editingIndex != null) {
      novaLista[_editingIndex!] = midia;
    } else {
      novaLista.add(midia);
    }
    
    widget.onChanged(novaLista);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingIndex != null ? 'Mídia atualizada!' : 'Mídia adicionada!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removerMidia(int index) {
    final novaLista = List<MidiasModel>.from(widget.midias)..removeAt(index);
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
                const Icon(Icons.share, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text('Mídias Sociais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (widget.isEditing)
                  TextButton(
                    onPressed: () => _abrirDialog(),
                    child: const Text('+ Adicionar'),
                  ),
              ],
            ),
            const Divider(),
            if (widget.midias.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Nenhuma mídia cadastrada', style: TextStyle(color: AppTheme.textLight)),
              )
            else
              ...widget.midias.asMap().entries.map((entry) {
                final index = entry.key;
                final midia = entry.value;
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.share, size: 16),
                  title: Text(midia.descricao),
                  subtitle: Text(
                    '${midia.nomeDoApp != null ? '${midia.nomeDoApp} - ' : ''}${midia.tipoLabel} - ${midia.usoLabel}',
                  ),
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
                              onPressed: () => _removerMidia(index),
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
