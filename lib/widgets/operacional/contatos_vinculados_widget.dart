/// ============================================
/// WIDGET: Lista de Contatos Vinculados
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../providers/operacional/empresa_provider.dart';
import '../../models/operacional/contato_model.dart';
import '../../theme/app_theme.dart';
import '../../screens/operacional/contato_unified_screen.dart';

class ContatosVinculadosWidget extends StatefulWidget {
  final List<ContatoModel> contatos;
  final String? empresaId;
  final Function(ContatoModel) onContatoVinculado;
  final Function(String) onContatoDesvinculado;
  final Function(ContatoModel) onContatoCriado;

  const ContatosVinculadosWidget({
    super.key,
    required this.contatos,
    this.empresaId,
    required this.onContatoVinculado,
    required this.onContatoDesvinculado,
    required this.onContatoCriado,
  });

  @override
  State<ContatosVinculadosWidget> createState() => _ContatosVinculadosWidgetState();
}

class _ContatosVinculadosWidgetState extends State<ContatosVinculadosWidget> {
  bool _isLoading = false;
  String _searchQuery = '';

  // ⭐ MÉTODO PARA SELECIONAR CONTATO (sem arquivo externo)
  Future<void> _selecionarContato(List<ContatoModel> contatosDisponiveis) async {
    final contatoSelecionado = await showModalBottomSheet<ContatoModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            String searchQuery = '';
            List<ContatoModel> filtered = contatosDisponiveis;

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selecionar Contato',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // Search
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar contato...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setStateModal(() {
                        searchQuery = value;
                        if (searchQuery.isEmpty) {
                          filtered = contatosDisponiveis;
                        } else {
                          filtered = contatosDisponiveis.where((c) =>
                            c.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            c.tipoVinculoLabel.toLowerCase().contains(searchQuery.toLowerCase())
                          ).toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Lista
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final contato = filtered[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              contato.nome.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(contato.nome),
                          subtitle: Text(contato.tipoVinculoLabel),
                          onTap: () => Navigator.pop(context, contato),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (contatoSelecionado != null && mounted) {
      await _vincularContatoSelecionado(contatoSelecionado);
    }
  }

  Future<void> _vincularContatoSelecionado(ContatoModel contato) async {
    if (widget.empresaId == null) return;

    setState(() => _isLoading = true);

    try {
      final empresaProvider = context.read<EmpresaProvider>();
      final success = await empresaProvider.vincularContato(
        widget.empresaId!,
        contato.id,
      );

      if (success && mounted) {
        widget.onContatoVinculado(contato);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contato "${contato.nome}" vinculado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao vincular contato: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _vincularContato() async {
    if (widget.empresaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salve a empresa antes de vincular contatos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Carregar lista de contatos disponíveis
    final contatoProvider = context.read<ContatoProvider>();
    await contatoProvider.loadContatos();

    final contatosDisponiveis = contatoProvider.contatos
        .where((c) => !widget.contatos.any((vinculado) => vinculado.id == c.id))
        .toList();

    if (contatosDisponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os contatos já estão vinculados a esta empresa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _selecionarContato(contatosDisponiveis);
  }

  Future<void> _criarNovoContato() async {
    if (widget.empresaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salve a empresa antes de criar um contato'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navegar para tela de criação de contato
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ContatoProvider(),
          child: const ContatoUnifiedScreen(),
        ),
      ),
    );

    if (result != null && result is ContatoModel && mounted) {
      // Vincular o contato criado à empresa
      setState(() => _isLoading = true);

      try {
        final empresaProvider = context.read<EmpresaProvider>();
        final success = await empresaProvider.vincularContato(
          widget.empresaId!,
          result.id,
        );

        if (success && mounted) {
          widget.onContatoCriado(result);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contato "${result.nome}" criado e vinculado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao vincular contato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _desvincularContato(ContatoModel contato) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desvincular Contato'),
        content: Text('Deseja desvincular "${contato.nome}" da empresa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desvincular', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        final empresaProvider = context.read<EmpresaProvider>();
        final success = await empresaProvider.desvincularContato(
          widget.empresaId!,
          contato.id,
        );

        if (success && mounted) {
          widget.onContatoDesvinculado(contato.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contato "${contato.nome}" desvinculado!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao desvincular contato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Contatos Vinculados (${widget.contatos.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (widget.empresaId != null) ...[
                      TextButton.icon(
                        onPressed: _isLoading ? null : _vincularContato,
                        icon: const Icon(Icons.link, size: 18),
                        label: const Text('Vincular existente'),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: _isLoading ? null : _criarNovoContato,
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Criar novo'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const Divider(),
            if (widget.contatos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Nenhum contato vinculado',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...widget.contatos.map((contato) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 16,
                  child: Text(
                    contato.nome.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  contato.nome,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(contato.tipoVinculoLabel),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: _isLoading ? null : () => _desvincularContato(contato),
                  tooltip: 'Desvincular',
                ),
              )),
          ],
        ),
      ),
    );
  }
}