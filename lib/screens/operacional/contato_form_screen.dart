/// ============================================
/// TELA: Formulário de Contato
/// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/contato_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

class ContatoFormScreen extends StatefulWidget {
  final String? contatoId;

  const ContatoFormScreen({super.key, this.contatoId});

  @override
  State<ContatoFormScreen> createState() => _ContatoFormScreenState();
}

class _ContatoFormScreenState extends State<ContatoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _obsController = TextEditingController();

  String _tipoVinculo = 'EXTERNO';
  String? _genero;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.contatoId != null;
    
    if (_isEditing) {
      _loadContatoData();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _loadContatoData() async {
    final provider = context.read<ContatoProvider>();
    await provider.loadContatoById(widget.contatoId!);
    
    final contato = provider.selectedContato;
    if (contato != null && mounted) {
      setState(() {
        _nomeController.text = contato.nome;
        _tipoVinculo = contato.tipoVinculo;
        _genero = contato.genero;
        _cpfController.text = contato.cpf ?? '';
        _rgController.text = contato.rg ?? '';
        _obsController.text = contato.obs ?? '';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'nome': _nomeController.text.trim(),
      'tipo_vinculo': _tipoVinculo,
      'genero': _genero,
      'cpf': _cpfController.text.replaceAll(RegExp(r'\D'), ''),
      'rg': _rgController.text.trim(),
      'obs': _obsController.text.trim(),
    };

    final provider = context.read<ContatoProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateContato(widget.contatoId!, data);
    } else {
      success = await provider.createContato(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Contato atualizado!' : 'Contato criado!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // Navegação segura
      if (mounted) {
        context.go('/operacional/contatos');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erro ao salvar contato'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  void _goBack() {
    if (mounted) {
      context.go('/operacional/contatos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Contato' : 'Novo Contato'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: _isEditing && widget.contatoId != null
          ? Consumer<ContatoProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
                        const SizedBox(height: 16),
                        Text(provider.error!),
                        ElevatedButton(
                          onPressed: () => _loadContatoData(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }
                return _buildForm();
              },
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nome
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo *',
                hintText: 'Digite o nome completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nome é obrigatório';
                }
                if (value.length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo de Vínculo
            DropdownButtonFormField<String>(
              value: _tipoVinculo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Vínculo *',
                prefixIcon: Icon(Icons.link_outlined),
              ),
              items: ContatoModel.tipoVinculoLabels.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _tipoVinculo = value!);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tipo de vínculo é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gênero
            DropdownButtonFormField<String>(
              value: _genero,
              decoration: const InputDecoration(
                labelText: 'Gênero',
                prefixIcon: Icon(Icons.person_outline),
              ),
              hint: const Text('Selecione o gênero'),
              items: ContatoModel.generoLabels.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _genero = value);
              },
            ),
            const SizedBox(height: 16),

            // CPF
            TextFormField(
              controller: _cpfController,
              decoration: const InputDecoration(
                labelText: 'CPF',
                hintText: 'XXX.XXX.XXX-XX',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                _CpfInputFormatter(),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final clean = value.replaceAll(RegExp(r'\D'), '');
                  if (clean.length != 11) {
                    return 'CPF deve ter 11 dígitos';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // RG
            TextFormField(
              controller: _rgController,
              decoration: const InputDecoration(
                labelText: 'RG',
                hintText: 'Digite o RG',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Observações
            TextFormField(
              controller: _obsController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                hintText: 'Informações adicionais',
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _goBack,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Atualizar' : 'Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Máscara para CPF (XXX.XXX.XXX-XX)
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
