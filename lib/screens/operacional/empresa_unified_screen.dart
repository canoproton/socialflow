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
import '../../services/debug_service.dart';
import '../../utils/formatters/formatters.dart';

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

  String? _empresaIdSalva;

  @override
  void initState() {
    super.initState();
    DebugService.module('EMPRESA UNIFIED SCREEN');
    DebugService.log(
      module: 'EMPRESA',
      action: 'INIT',
      data: 'empresaId: ${widget.empresaId} | isEditing: ${widget.empresaId != null}',
    );
    _isEditing = widget.empresaId != null;
    
    // ⭐ LOG PARA VERIFICAR
    print('🔍 _isEditing: $_isEditing, empresaId: ${widget.empresaId}');
    
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
    DebugService.log(
      module: 'EMPRESA',
      action: 'LOAD',
      data: 'Carregando empresa ID: ${widget.empresaId}',
    );
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
          _empresaIdSalva = widget.empresaId;
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

  Future<bool> _cnpjJaExiste(String cnpj) async {
    // Buscar todas as empresas
    final provider = context.read<EmpresaProvider>();
    await provider.loadEmpresas();
    
    // ⭐ PEGAR O ID DA EMPRESA QUE ESTÁ SENDO EDITADA
    final String? idAtual = widget.empresaId;
    
    for (var empresa in provider.empresas) {
      // ⭐ IGNORAR A PRÓPRIA EMPRESA (se for edição)
      if (idAtual != null && empresa.id == idAtual) {
        continue; // Pula a própria empresa
      }
      
      if (empresa.cnpj == cnpj) {
        return true;
      }
    }
    return false;
  }

  Future<void> _salvar() async {
    DebugService.log(
      module: 'EMPRESA',
      action: 'SALVAR',
      data: 'Iniciando salvamento | isEditing: $_isEditing | empresaId: ${widget.empresaId}',
    );
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String cnpjLimpo = _cnpjController.text.replaceAll(RegExp(r'\D'), '');
      final cnpjParaEnviar = cnpjLimpo.isNotEmpty ? cnpjLimpo : null;

      final data = {
        'nome': _nomeController.text,
        'razao_social': _razaoController.text,
        'qualif': _qualif,
        'tipo_contr': _tipoContr,
        'cnpj': cnpjParaEnviar,
        'ie': _ieController.text.isNotEmpty ? _ieController.text : null,
        'obs': _obsController.text.isNotEmpty ? _obsController.text : null,
      };

      final provider = context.read<EmpresaProvider>();

      // ⭐ VALIDAR CNPJ DUPLICADO (APENAS SE NÃO FOR EDIÇÃO)
      if (cnpjParaEnviar != null && !_isEditing) {
        DebugService.log(
          module: 'EMPRESA',
          action: 'VALIDAR_CNPJ',
          data: 'Validando CNPJ para nova empresa: $cnpjParaEnviar',
        );
        final existe = await _cnpjJaExiste(cnpjParaEnviar);
        if (existe) {
          DebugService.log(
            module: 'EMPRESA',
            action: 'CNPJ_DUPLICADO',
            data: 'CNPJ já existe: $cnpjParaEnviar',
            isWarning: true,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CNPJ já cadastrado! Verifique o número informado.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      if (_isEditing) {
        DebugService.log(
          module: 'EMPRESA',
          action: 'ATUALIZAR',
          data: 'Atualizando empresa ID: ${widget.empresaId}',
        );
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
        DebugService.log(
          module: 'EMPRESA',
          action: 'CRIAR',
          data: 'Criando nova empresa',
        );
        final novaEmpresa = await provider.createEmpresa(data);
        
        if (novaEmpresa != null && mounted) {
          _empresaIdSalva = novaEmpresa.id;
          await provider.loadEmpresas();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empresa criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          
          context.go('/operacional/empresa/${novaEmpresa.id}');
        } else {
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
        DebugService.log(
          module: 'EMPRESA',
          action: 'ERRO',
          data: e.toString(),
          isError: true,
        );
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
    DebugService.log(
      module: 'EMPRESA',
      action: 'BUILD',
      data: 'empresaId: ${widget.empresaId} | _empresaIdSalva: $_empresaIdSalva | contatos: ${_contatosVinculados.length}',
    );
    final idParaVincular = _empresaIdSalva ?? widget.empresaId;

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
                                      hintText: '00.000.000/0000-00',
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      CnpjFormatter(),
                                    ],
                                    onChanged: (value) {
                                      DebugService.log(
                                        module: 'CNPJ',
                                        action: 'DIGITANDO',
                                        data: 'CNPJ: $value',
                                      );
                                      final clean = value.replaceAll(RegExp(r'\D'), '');
                                      if (clean.length > 14) return;
                                      
                                      String formatted = clean;
                                      if (clean.length > 2) {
                                        formatted = '${clean.substring(0,2)}.${clean.substring(2)}';
                                      }
                                      if (clean.length > 5) {
                                        formatted = '${formatted.substring(0,6)}.${formatted.substring(6)}';
                                      }
                                      if (clean.length > 8) {
                                        formatted = '${formatted.substring(0,10)}/${formatted.substring(10)}';
                                      }
                                      if (clean.length > 12) {
                                        formatted = '${formatted.substring(0,15)}-${formatted.substring(15)}';
                                      }
                                      
                                      if (_cnpjController.text != formatted) {
                                        _cnpjController.value = TextEditingValue(
                                          text: formatted,
                                          selection: TextSelection.collapsed(offset: formatted.length),
                                        );
                                      }
                                    },
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
                    // CONTATOS VINCULADOS
                    // ============================================
                    ContatosVinculadosWidget(
                      contatos: _contatosVinculados,
                      empresaId: _empresaIdSalva ?? widget.empresaId,
                      onContatoVinculado: (contato) {
                        setState(() {
                          _contatosVinculados.add(contato);
                        });
                      },
                      onContatoDesvinculado: (contatoId) {
                        setState(() {
                          _contatosVinculados.removeWhere((c) => c.id == contatoId);
                        });
                      },
                      onContatoCriado: (contato) {
                        setState(() {
                          _contatosVinculados.add(contato);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // ============================================
                    // TELEFONES
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
                    // EMAILS
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
                    // ENDEREÇOS
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
                    // MÍDIAS SOCIAIS
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