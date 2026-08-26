/// ============================================
/// TELA UNIFICADA: Empresa + Relacionamentos
/// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/empresa_provider.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/operacional_models.dart';
import '../../widgets/operacional/telefone_list_widget.dart';
import '../../widgets/operacional/email_list_widget.dart';
import '../../widgets/operacional/endereco_list_widget.dart';
import '../../widgets/operacional/midias_list_widget.dart';
import '../../widgets/operacional/contatos_vinculados_widget.dart';
import '../../theme/app_theme.dart';
import 'contato_unified_screen.dart';

class EmpresaUnifiedScreen extends StatefulWidget {
  final String? empresaId;

  const EmpresaUnifiedScreen({super.key, this.empresaId});

  @override
  State<EmpresaUnifiedScreen> createState() => _EmpresaUnifiedScreenState();
}

class _EmpresaUnifiedScreenState extends State<EmpresaUnifiedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _razaoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _ieController = TextEditingController();
  final _obsController = TextEditingController();

  String _qualif = 'FORNECEDOR';
  String _tipoContr = 'CNPJ';
  bool _isEditing = false;
  bool _isLoading = false;

  List<ContatoModel> _contatos = [];
  List<TelefoneModel> _telefones = [];
  List<EmailModel> _emails = [];
  List<EnderecoModel> _enderecos = [];
  List<MidiasModel> _midias = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.empresaId != null;
    if (_isEditing) {
      _loadEmpresaData();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _razaoController.dispose();
    _cnpjController.dispose();
    _ieController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _loadEmpresaData() async {
    setState(() => _isLoading = true);
    final provider = context.read<EmpresaProvider>();
    await provider.loadEmpresaById(widget.empresaId!);

    final empresa = provider.selectedEmpresa;
    if (empresa != null && mounted) {
      setState(() {
        _nomeController.text = empresa.nome;
        _razaoController.text = empresa.razaoSocial;
        _qualif = empresa.qualif;
        _tipoContr = empresa.tipoContr;
        _cnpjController.text = empresa.cnpj ?? '';
        _ieController.text = empresa.ie ?? '';
        _obsController.text = empresa.obs ?? '';
        _contatos = List.from(empresa.contatos);
        _telefones = List.from(empresa.telefones);
        _emails = List.from(empresa.emails);
        _enderecos = List.from(empresa.enderecos);
        _midias = List.from(empresa.midias);
        _isLoading = false;
      });
    }
  }

  Future<void> _vincularContato() async {
    final contatoProvider = context.read<ContatoProvider>();
    await contatoProvider.loadContatos();

    final contatosDisponiveis = contatoProvider.contatos
        .where((c) => !_contatos.any((vinculado) => vinculado.id == c.id))
        .toList();

    if (contatosDisponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os contatos já estão vinculados a esta empresa'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final contatoSelecionado = await showDialog<ContatoModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Contato'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: contatosDisponiveis.length,
            itemBuilder: (context, index) {
              final contato = contatosDisponiveis[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    contato.initials,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(contato.nome),
                subtitle: Text(contato.tipoVinculoLabel),
                onTap: () => Navigator.pop(context, contato),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (contatoSelecionado != null && mounted) {
      if (_contatos.any((c) => c.id == contatoSelecionado.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este contato já está vinculado à empresa'),
            backgroundColor: AppTheme.warningColor,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        _contatos.add(contatoSelecionado);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contato "${contatoSelecionado.nome}" vinculado!'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _criarNovoContato() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContatoUnifiedScreen(
          empresaId: widget.empresaId,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result != null && mounted) {
      print('✅ Contato criado com ID: $result');

      final contatoProvider = context.read<ContatoProvider>();
      await contatoProvider.loadContatos();

      final empresaProvider = context.read<EmpresaProvider>();
      await empresaProvider.loadEmpresaById(widget.empresaId!);

      if (empresaProvider.selectedEmpresa != null) {
        setState(() {
          _contatos = List.from(empresaProvider.selectedEmpresa!.contatos);
        });
        print('✅ Contatos atualizados: ${_contatos.length}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Novo contato criado e vinculado com sucesso!'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String?> _validateCnpj(String? value) async {
    if (value == null || value.isEmpty) return null;

    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 14) return 'CNPJ deve ter 14 dígitos';

    if (_isEditing && _cnpjController.text == value) return null;

    try {
      final provider = context.read<EmpresaProvider>();
      final existing = await provider.checkCnpj(clean);
      if (existing != null) {
        return 'CNPJ já cadastrado para a empresa "${existing.nome}"';
      }
    } catch (e) {
      print('Erro ao verificar CNPJ: $e');
    }

    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cleanCnpj = _cnpjController.text.replaceAll(RegExp(r'\D'), '');

      final data = {
        'nome': _nomeController.text.trim(),
        'razao_social': _razaoController.text.trim(),
        'qualif': _qualif,
        'tipo_contr': _tipoContr,
        'cnpj': cleanCnpj,
        'ie': _ieController.text.trim(),
        'obs': _obsController.text.trim(),
        'contatos': _contatos,
        'telefones': _telefones,
        'emails': _emails,
        'enderecos': _enderecos,
        'midias': _midias,
      };

      final provider = context.read<EmpresaProvider>();
      bool success;

      if (_isEditing) {
        success = await provider.updateEmpresa(widget.empresaId!, data);
      } else {
        success = await provider.createEmpresa(data);
      }

      if (mounted) setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '✅ Empresa atualizada!' : '✅ Empresa criada!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.go('/operacional/empresas');
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
      context.go('/operacional/empresas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Empresa' : 'Nova Empresa'),
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

                  ContatosVinculadosWidget(
                    contatos: _contatos,
                    onChanged: (novos) => setState(() => _contatos = novos),
                    onAddContato: _vincularContato,
                    onCriarNovoContato: _criarNovoContato,
                  ),

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
                  labelText: 'Nome Fantasia *',
                  hintText: 'Digite o nome fantasia',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nome é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _razaoController,
                decoration: const InputDecoration(
                  labelText: 'Razão Social *',
                  hintText: 'Digite a razão social',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Razão Social é obrigatória';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _qualif,
                decoration: const InputDecoration(
                  labelText: 'Qualificação *',
                  prefixIcon: Icon(Icons.verified_outlined),
                ),
                items: EmpresaModel.qualifLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _qualif = value!),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Qualificação é obrigatória';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoContr,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Contratação *',
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                items: EmpresaModel.tipoContrLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _tipoContr = value!),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Tipo de contratação é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(
                  labelText: 'CNPJ',
                  hintText: 'XX.XXX.XXX/XXXX-XX',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [_CnpjInputFormatter()],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final clean = value.replaceAll(RegExp(r'\D'), '');
                    if (clean.length != 14) return 'CNPJ deve ter 14 dígitos';
                  }
                  return null;
                },
                onChanged: (value) {
                  final provider = context.read<EmpresaProvider>();
                  if (provider.error != null && provider.error!.contains('CNPJ')) {
                    provider.clearError();
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ieController,
                decoration: const InputDecoration(
                  labelText: 'Inscrição Estadual',
                  hintText: 'Digite a IE',
                  prefixIcon: Icon(Icons.numbers_outlined),
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

class _CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
