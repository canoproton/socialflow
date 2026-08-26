/// ============================================
/// TELA UNIFICADA: Contato + Relacionamentos
/// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../providers/operacional/empresa_provider.dart';
import '../../models/operacional/operacional_models.dart';
import '../../widgets/operacional/telefone_list_widget.dart';
import '../../widgets/operacional/email_list_widget.dart';
import '../../widgets/operacional/endereco_list_widget.dart';
import '../../widgets/operacional/midias_list_widget.dart';
import '../../theme/app_theme.dart';

class ContatoUnifiedScreen extends StatefulWidget {
  final String? contatoId;
  final String? empresaId;

  const ContatoUnifiedScreen({super.key, this.contatoId, this.empresaId});

  @override
  State<ContatoUnifiedScreen> createState() => _ContatoUnifiedScreenState();
}

class _ContatoUnifiedScreenState extends State<ContatoUnifiedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _obsController = TextEditingController();

  String _tipoVinculo = 'EXTERNO';
  String? _genero;
  bool _isEditing = false;
  bool _isLoading = false;

  List<TelefoneModel> _telefones = [];
  List<EmailModel> _emails = [];
  List<EnderecoModel> _enderecos = [];
  List<MidiasModel> _midias = [];

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
    setState(() => _isLoading = true);
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
        _telefones = List.from(contato.telefones);
        _emails = List.from(contato.emails);
        _enderecos = List.from(contato.enderecos);
        _midias = List.from(contato.midias);
        _isLoading = false;
      });
    }
  }

  Future<void> _vincularContatoEmpresa(String empresaId, String contatoId) async {
    try {
      print('=== VINCULANDO CONTATO À EMPRESA ===');
      
      final empresaProvider = context.read<EmpresaProvider>();
      final contatoProvider = context.read<ContatoProvider>();
      
      ContatoModel? contato = contatoProvider.contatos.firstWhere(
        (c) => c.id == contatoId,
        orElse: () => contatoProvider.selectedContato!,
      );
      
      if (contato.id.isEmpty) {
        await contatoProvider.loadContatoById(contatoId);
        contato = contatoProvider.selectedContato!;
      }
      
      await empresaProvider.loadEmpresaById(empresaId);
      final empresa = empresaProvider.selectedEmpresa;
      
      if (empresa == null) return;
      
      if (empresa.contatos.any((c) => c.id == contatoId)) return;
      
      final novosContatos = List<ContatoModel>.from(empresa.contatos)..add(contato);
      
      await empresaProvider.updateEmpresa(
        empresaId,
        {
          'nome': empresa.nome,
          'razao_social': empresa.razaoSocial,
          'qualif': empresa.qualif,
          'tipo_contr': empresa.tipoContr,
          'cnpj': empresa.cnpj,
          'ie': empresa.ie,
          'obs': empresa.obs,
          'contatos': novosContatos,
        },
      );
      
      print('✅ Contato vinculado com sucesso!');
    } catch (e) {
      print('❌ Erro ao vincular contato à empresa: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'nome': _nomeController.text.trim(),
        'tipo_vinculo': _tipoVinculo,
        'genero': _genero,
        'cpf': _cpfController.text.replaceAll(RegExp(r'\D'), ''),
        'rg': _rgController.text.trim(),
        'obs': _obsController.text.trim(),
        'telefones': _telefones,
        'emails': _emails,
        'enderecos': _enderecos,
        'midias': _midias,
      };

      final provider = context.read<ContatoProvider>();
      bool success;
      String? novoContatoId;

      if (_isEditing) {
        success = await provider.updateContato(widget.contatoId!, data);
        novoContatoId = widget.contatoId;
      } else {
        success = await provider.createContato(data);
        if (success && provider.selectedContato != null) {
          novoContatoId = provider.selectedContato!.id;
        }
      }

      if (mounted) setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '✅ Contato atualizado!' : '✅ Contato criado!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // ⭐ NAVEGAÇÃO CORRIGIDA - SEM Navigator.pop
        if (widget.empresaId != null) {
          if (mounted) {
            context.go('/operacional/empresas/editar/${widget.empresaId}');
          }
        } else {
          if (mounted) {
            context.go('/operacional/contatos');
          }
        }
      } else if (mounted && provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: AppTheme.dangerColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  void _goBack() {
    if (mounted) {
      // ⭐ NAVEGAÇÃO CORRIGIDA - SEM Navigator.pop
      if (widget.empresaId != null) {
        context.go('/operacional/empresas/editar/${widget.empresaId}');
      } else {
        context.go('/operacional/contatos');
      }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoForm(),
                  const SizedBox(height: 16),
                  const Divider(thickness: 2, color: AppTheme.primaryColor),
                  const SizedBox(height: 8),
                  TelefoneListWidget(
                    telefones: _telefones,
                    onChanged: (novos) => setState(() => _telefones = novos),
                  ),
                  EmailListWidget(
                    emails: _emails,
                    onChanged: (novos) => setState(() => _emails = novos),
                  ),
                  EnderecoListWidget(
                    enderecos: _enderecos,
                    onChanged: (novos) => setState(() => _enderecos = novos),
                  ),
                  MidiasListWidget(
                    midias: _midias,
                    onChanged: (novos) => setState(() => _midias = novos),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo *',
                  hintText: 'Digite o nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nome é obrigatório';
                  if (value.length < 3) return 'Nome deve ter pelo menos 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoVinculo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Vínculo *',
                  prefixIcon: Icon(Icons.link_outlined),
                ),
                items: ContatoModel.tipoVinculoLabels.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _tipoVinculo = value!),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Tipo de vínculo é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _genero,
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                hint: const Text('Selecione o gênero'),
                items: ContatoModel.generoLabels.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _genero = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: 'XXX.XXX.XXX-XX',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [_CpfInputFormatter()],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final clean = value.replaceAll(RegExp(r'\D'), '');
                    if (clean.length != 11) return 'CPF deve ter 11 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rgController,
                decoration: const InputDecoration(
                  labelText: 'RG',
                  hintText: 'Digite o RG',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  hintText: 'Informações adicionais',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
