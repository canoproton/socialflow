/// ============================================
/// TELA UNIFICADA: Contato + Relacionamentos
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/operacional_models.dart';
import '../../widgets/operacional/telefone_list_widget.dart';
import '../../widgets/operacional/email_list_widget.dart';
import '../../widgets/operacional/endereco_list_widget.dart';
import '../../widgets/operacional/midias_list_widget.dart';
import '../../theme/app_theme.dart';

class ContatoUnifiedScreen extends StatefulWidget {
  final String? contatoId;

  const ContatoUnifiedScreen({super.key, this.contatoId});

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
  String _genero = 'MASCULINO';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadContatoData();
      });
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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final provider = context.read<ContatoProvider>();
      await provider.loadContatoById(widget.contatoId!);

      final contato = provider.selectedContato;
      if (contato != null && mounted) {
        setState(() {
          _nomeController.text = contato.nome;
          _tipoVinculo = contato.tipoVinculo;
          _genero = contato.genero ?? 'MASCULINO';
          _cpfController.text = contato.cpf ?? '';
          _rgController.text = contato.rg ?? '';
          _obsController.text = contato.obs ?? '';
          _telefones = List.from(contato.telefones);
          _emails = List.from(contato.emails);
          _enderecos = List.from(contato.enderecos);
          _midias = List.from(contato.midias);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar contato: ${e.toString()}'),
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
        'tipo_vinculo': _tipoVinculo,
        'genero': _genero,
        'cpf': _cpfController.text,
        'rg': _rgController.text,
        'obs': _obsController.text,
        'telefones': _telefones.map((t) => t.toJson()).toList(),
        'emails': _emails.map((e) => e.toJson()).toList(),
        'enderecos': _enderecos.map((e) => e.toJson()).toList(),
        'midias': _midias.map((m) => m.toJson()).toList(),
      };

      final provider = context.read<ContatoProvider>();
      bool success;
      ContatoModel? contatoCriado;

      if (_isEditing) {
        success = await provider.updateContato(widget.contatoId!, data);
        contatoCriado = provider.selectedContato;
      } else {
        success = await provider.createContato(data);
        contatoCriado = provider.selectedContato;
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Contato atualizado!' : 'Contato criado!'),
            backgroundColor: Colors.green,
          ),
        );
        // ⭐ VOLTA PARA QUEM CHAMOU (empresa ou lista de contatos)
        Navigator.pop(context, contatoCriado);
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
        title: Text(_isEditing ? 'Editar Contato' : 'Novo Contato'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),  // ⭐ VOLTA PARA QUEM CHAMOU
          tooltip: 'Voltar',
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
                    // DADOS DO CONTATO
                    // ============================================
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                labelText: 'Nome Completo *',
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
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _tipoVinculo,
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo de Vínculo *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'BANCO',
                                        child: Text('Banco'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'INTERNO',
                                        child: Text('Interno'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'EXTERNO',
                                        child: Text('Externo'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'EMPRESA',
                                        child: Text('Empresa'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'PATROCINADOR',
                                        child: Text('Patrocinador'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'OPERACIONAL',
                                        child: Text('Operacional'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'VARIOS',
                                        child: Text('Vários'),
                                      ),
                                    ],
                                    onChanged: (value) => setState(() => _tipoVinculo = value!),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _genero,
                                    decoration: const InputDecoration(
                                      labelText: 'Gênero',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'FEMININO',
                                        child: Text('Feminino'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'MASCULINO',
                                        child: Text('Masculino'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'OUTROS',
                                        child: Text('Outros'),
                                      ),
                                    ],
                                    onChanged: (value) => setState(() => _genero = value!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cpfController,
                                    decoration: const InputDecoration(
                                      labelText: 'CPF',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _rgController,
                                    decoration: const InputDecoration(
                                      labelText: 'RG',
                                      border: OutlineInputBorder(),
                                    ),
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
                          onPressed: () => Navigator.pop(context),
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