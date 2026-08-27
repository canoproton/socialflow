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
      if (mounted) {
        context.read<ContatoProvider>().loadContatos();
      }
    });
  }

  void _goBack() {
    if (mounted) {
      context.go('/operacional');
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
          tooltip: 'Voltar para o Módulo Operacional',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/operacional/contato/novo'),
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
                  Text(provider.error!),
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
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/operacional/contato/novo'),
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

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.contatos.length,
            itemBuilder: (context, index) {
              final contato = provider.contatos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      contato.nome.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    contato.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(contato.tipoVinculoLabel),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => context.go('/operacional/contato/${contato.id}'),
                        tooltip: 'Editar',
                      ),
                    ],
                  ),
                  onTap: () => context.go('/operacional/contato/${contato.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}