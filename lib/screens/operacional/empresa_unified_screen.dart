/// ============================================
/// TELA UNIFICADA: Empresa + Relacionamentos
/// ============================================

import 'package:flutter/material.dart';
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

  List<ContatoModel> _contatosVinculados = [];
  List<TelefoneModel> _telefones = [];
  List<EmailModel> _emails = [];
  List<EnderecoModel> _enderecos = [];
  List<MidiasModel> _midias = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.empresaId != null;
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadEmpresaData();
      });
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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final provider = context.read<EmpresaProvider>();
      await provider.loadEmpresaById(widget.empresaId!);

      final empresa = provider.selectedEmpresa;
      if (empresa != null && mounted) {
        setState(() {
          _nomeController.text = empresa.nome;
          _razaoController.text = empresa.razaoSocial ?? '';
          _qualif = empresa.qualif;
          _tipoContr = empresa.tipoContr;
          _cnpjController.text = empresa.cnpj ?? '';
          _ieController.text = empresa.ie ?? '';
          _obsController.text = empresa.obs ?? '';
          _contatosVinculados = List.from(empresa.contatos);
          _telefones = List.from(empresa.telefones);
          _emails = List.from(empresa.emails);
          _enderecos = List.from(empresa.enderecos);
          _midias = List.from(empresa.midias);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar empresa: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'nome': _nomeController.text,
        'razaoSocial': _razaoController.text,
        'qualif': _qualif,
        'tipoContr': _tipoContr,
        'cnpj': _cnpjController.text,
        'ie': _ieController.text,
        'obs': _obsController.text,
      };

      final provider = context.read<EmpresaProvider>();

      if (_isEditing) {
        final success = await provider.updateEmpresa(widget.empresaId!, data);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empresa atualizada!'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadEmpresaData();
        }
      } else {
        // ⭐ CRIA EMPRESA
        final novaEmpresa = await provider.createEmpresa(data);
        
        if (novaEmpresa != null && mounted) {
          // ⭐ RECARREGAR A LISTA DE EMPRESAS
          await provider.loadEmpresas();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empresa criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // ⭐ VOLTA PARA LISTA DE EMPRESAS (onde a empresa vai aparecer)
          context.go('/operacional/empresas');
        } else {
          // ⭐ SE FALHOU, MOSTRA ERRO
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar empresa: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
    // ⭐ DETERMINA SE PODE VINCULAR CONTATOS (SE É EDIÇÃO OU JÁ FOI SALVO)
    final podeVincular = _isEditing || widget.empresaId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Empresa' : 'Nova Empresa'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/operacional/empresas'),
          tooltip: 'Voltar para lista de empresas',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _salvar,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ============================================
                    // DADOS DA EMPRESA
                    // ============================================
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                labelText: 'Nome *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nome é obrigatório';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _razaoController,
                              decoration: const InputDecoration(
                                labelText: 'Razão Social',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cnpjController,
                                    decoration: const InputDecoration(
                                      labelText: 'CNPJ',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _ieController,
                                    decoration: const InputDecoration(
                                      labelText: 'Inscrição Estadual',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _qualif,
                                    decoration: const InputDecoration(
                                      labelText: 'Qualificação',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'INTERNA',
                                        child: Text('Interna'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'COLIGADA',
                                        child: Text('Coligada'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'OPERACIONAL',
                                        child: Text('Operacional'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'PESSOA_FISICA',
                                        child: Text('Pessoa Física'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'FORNECEDOR',
                                        child: Text('Fornecedor'),
                                      ),
                                    ],
                                    onChanged: (value) => setState(() => _qualif = value!),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _tipoContr,
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo Contratação',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'RPA',
                                        child: Text('RPA'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'CNPJ',
                                        child: Text('CNPJ'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'MEI',
                                        child: Text('MEI'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'ADH',
                                        child: Text('Ad-Hoc'),
                                      ),
                                    ],
                                    onChanged: (value) => setState(() => _tipoContr = value!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _obsController,
                              decoration: const InputDecoration(
                                labelText: 'Observações',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ============================================
                    // ⭐ CONTATOS VINCULADOS (SÓ APARECE SE FOR EDIÇÃO)
                    // ============================================
                    if (podeVincular)
                      ContatosVinculadosWidget(
                        contatos: _contatosVinculados,
                        empresaId: widget.empresaId,
                        onContatoVinculado: (contato) {
                          setState(() {
                            _contatosVinculados.add(contato);
                          });
                        },
                        onContatoDesvinculado: (contatoId) {
                          setState(() {
                            _contatosVinculados
                                .removeWhere((c) => c.id == contatoId);
                          });
                        },
                        onContatoCriado: (contato) {
                          setState(() {
                            _contatosVinculados.add(contato);
                          });
                        },
                      ),
                    
                    if (!podeVincular)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Salve a empresa para poder vincular contatos',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // ============================================
                    // ⭐ TELEFONES
                    // ============================================
                    TelefoneListWidget(
                      telefones: _telefones,
                      onChanged: (novaLista) {
                        if (mounted) {
                          setState(() => _telefones = novaLista);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ============================================
                    // ⭐ EMAILS
                    // ============================================
                    EmailListWidget(
                      emails: _emails,
                      onChanged: (novaLista) {
                        if (mounted) {
                          setState(() => _emails = novaLista);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ============================================
                    // ⭐ ENDEREÇOS
                    // ============================================
                    EnderecoListWidget(
                      enderecos: _enderecos,
                      onChanged: (novaLista) {
                        if (mounted) {
                          setState(() => _enderecos = novaLista);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ============================================
                    // ⭐ MÍDIAS SOCIAIS
                    // ============================================
                    MidiasListWidget(
                      midias: _midias,
                      onChanged: (novaLista) {
                        if (mounted) {
                          setState(() => _midias = novaLista);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // ============================================
                    // BOTÕES
                    // ============================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go('/operacional/empresas'),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
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