/// ============================================
/// TELA: Formulário de Projeto (Simples)
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../theme/app_theme.dart';

class ProjetoFormScreen extends StatefulWidget {
  final String? projetoId;

  const ProjetoFormScreen({super.key, this.projetoId});

  @override
  State<ProjetoFormScreen> createState() => _ProjetoFormScreenState();
}

class _ProjetoFormScreenState extends State<ProjetoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _processoController = TextEditingController();
  String _status = ProjetoModel.STATUS_ORCAMENTO;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.projetoId != null) {
      _loadProjeto();
    }
  }

  Future<void> _loadProjeto() async {
    final provider = context.read<ProjetoProvider>();
    await provider.loadProjetoById(widget.projetoId!);
    
    final projeto = provider.selectedProjeto;
    if (projeto != null && mounted) {
      setState(() {
        _descricaoController.text = projeto.descricao ?? '';
        _processoController.text = projeto.processo ?? '';
        _status = projeto.statusProjeto;
      });
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _processoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'descricao': _descricaoController.text,
        'processo': _processoController.text.isNotEmpty ? _processoController.text : null,
        'status_projeto': _status,
      };

      final provider = context.read<ProjetoProvider>();
      bool success;

      if (widget.projetoId != null) {
        success = await provider.updateProjeto(widget.projetoId!, data);
      } else {
        success = await provider.createProjeto(data);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.projetoId != null ? 'Projeto atualizado!' : 'Projeto criado!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/projetos');
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
        title: Text(widget.projetoId != null ? 'Editar Projeto' : 'Novo Projeto'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                controller: _processoController,
                decoration: const InputDecoration(
                  labelText: 'Processo',
                  border: OutlineInputBorder(),
                  helperText: 'Formato: XXXXX-XXXXXXXX/XXXX-XX',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ProjetoModel.statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(ProjetoModel.statusLabels[status] ?? status),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go('/projetos'),
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
}