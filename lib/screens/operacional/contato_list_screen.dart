/// ============================================
/// TELA: Lista de Contatos
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/contato_model.dart';
import '../../theme/app_theme.dart';

class ContatoListScreen extends StatefulWidget {
  const ContatoListScreen({super.key});

  @override
  State<ContatoListScreen> createState() => _ContatoListScreenState();
}

class _ContatoListScreenState extends State<ContatoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContatoProvider>().loadContatos();
    });
  }

  // ⭐ CORRIGIDO: Usar context.go com verificação mounted
  void _goBack() {
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos - Operacional'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
          tooltip: 'Voltar para o Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/operacional/contatos/novo'),
            tooltip: 'Novo Contato',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ContatoProvider>().loadContatos(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<ContatoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.contatos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando contatos...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(provider.error!, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadContatos(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.contatos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: AppTheme.textLight),
                  const SizedBox(height: 16),
                  const Text('Nenhum contato cadastrado'),
                  const SizedBox(height: 8),
                  const Text('Clique no botão + para adicionar'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/operacional/contatos/novo'),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Primeiro Contato'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadContatos(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.contatos.length,
              itemBuilder: (context, index) {
                final contato = provider.contatos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        contato.initials,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(contato.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo: ${contato.tipoVinculoLabel}', style: const TextStyle(fontSize: 12)),
                        if (contato.cpf != null && contato.cpf!.isNotEmpty)
                          Text('CPF: ${contato.cpfFormatado}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => context.go('/operacional/contatos/editar/${contato.id}'),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.dangerColor),
                          onPressed: () => _confirmDelete(context, contato, provider),
                          tooltip: 'Excluir',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ContatoModel contato, ContatoProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o contato "${contato.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.deleteContato(contato.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contato "${contato.nome}" excluído!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
}
