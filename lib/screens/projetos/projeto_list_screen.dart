/// ============================================
/// TELA: Lista de Projetos
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../theme/app_theme.dart';

class ProjetoListScreen extends StatelessWidget {
  const ProjetoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetos'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/projetos/novo'),
            tooltip: 'Novo Projeto',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProjetoProvider>().refresh(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<ProjetoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.projetos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProjetos(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.projetos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nenhum projeto cadastrado'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/projetos/novo'),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar primeiro projeto'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.projetos.length,
            itemBuilder: (context, index) {
              final projeto = provider.projetos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    projeto.descricao ?? 'Sem título',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(projeto.statusLabel),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () => context.go('/projetos/${projeto.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                        onPressed: () => context.go('/projetos/editar/${projeto.id}'),
                      ),
                    ],
                  ),
                  onTap: () => context.go('/projetos/${projeto.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}