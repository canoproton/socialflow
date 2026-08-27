/// ============================================
/// TELA: Lista de Projetos
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../theme/app_theme.dart';
import '../../services/debug_service.dart';

class ProjetoListScreen extends StatefulWidget {
  const ProjetoListScreen({super.key});

  @override
  State<ProjetoListScreen> createState() => _ProjetoListScreenState();
}

class _ProjetoListScreenState extends State<ProjetoListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = '';
  final _debounce = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    DebugService.module('PROJETO LIST SCREEN');
    DebugService.log(
      module: 'PROJETO',
      action: 'INIT',
      data: 'Inicializando lista de projetos',
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjetoProvider>().loadProjetos();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    DebugService.log(
      module: 'PROJETO',
      action: 'DISPOSE',
      data: 'Dispondo lista de projetos',
    );
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    DebugService.log(
      module: 'PROJETO',
      action: 'SEARCH',
      data: 'Termo: ${_searchController.text}',
    );
    Future.delayed(_debounce, () {
      if (mounted) {
        _aplicarFiltros();
      }
    });
  }

  void _aplicarFiltros() {
    DebugService.log(
      module: 'PROJETO',
      action: 'FILTRAR',
      data: 'Filtros - Search: ${_searchController.text}, Status: $_statusFilter',
    );
    // ⭐ CHAMAR SEM FILTROS (por enquanto)
    context.read<ProjetoProvider>().loadProjetos();
  }

  @override
  Widget build(BuildContext context) {
    DebugService.log(
      module: 'PROJETO',
      action: 'BUILD',
      data: 'Construindo lista de projetos',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetos'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            DebugService.log(
              module: 'PROJETO',
              action: 'VOLTAR',
              data: 'Voltando para dashboard',
            );
            context.go('/');
          },
          tooltip: 'Voltar para o Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              DebugService.log(
                module: 'PROJETO',
                action: 'NOVO',
                data: 'Criando novo projeto',
              );
              context.go('/projetos/novo');
            },
            tooltip: 'Novo Projeto',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              DebugService.log(
                module: 'PROJETO',
                action: 'REFRESH',
                data: 'Atualizando lista',
              );
              context.read<ProjetoProvider>().refresh();
            },
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<ProjetoProvider>(
              builder: (context, provider, child) {
                DebugService.log(
                  module: 'PROJETO',
                  action: 'CONSUMER',
                  data: 'isLoading: ${provider.isLoading}, projetos: ${provider.projetos.length}',
                );

                if (provider.isLoading && provider.projetos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return _buildErrorWidget(provider);
                }

                if (provider.projetos.isEmpty) {
                  return _buildEmptyWidget();
                }

                return _buildList(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar projetos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          DebugService.log(
                            module: 'PROJETO',
                            action: 'CLEAR_SEARCH',
                            data: 'Limpando busca',
                          );
                          _searchController.clear();
                          _aplicarFiltros();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _statusFilter.isEmpty ? null : _statusFilter,
            hint: const Text('Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...ProjetoModel.statusOptions.map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(ProjetoModel.statusLabels[status] ?? status),
                ),
              ),
            ],
            onChanged: (value) {
              DebugService.log(
                module: 'PROJETO',
                action: 'STATUS_FILTER',
                data: 'Novo status: $value',
              );
              setState(() => _statusFilter = value ?? '');
              _aplicarFiltros();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ProjetoProvider provider) {
    DebugService.log(
      module: 'PROJETO',
      action: 'ERROR',
      data: provider.error,
      isError: true,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
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

  Widget _buildEmptyWidget() {
    DebugService.log(
      module: 'PROJETO',
      action: 'EMPTY',
      data: 'Nenhum projeto cadastrado',
      isWarning: true,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_outlined, size: 64, color: AppTheme.textLight),
          const SizedBox(height: 16),
          const Text('Nenhum projeto cadastrado'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              DebugService.log(
                module: 'PROJETO',
                action: 'CRIAR_PRIMEIRO',
                data: 'Criando primeiro projeto',
              );
              context.go('/projetos/novo');
            },
            icon: const Icon(Icons.add),
            label: const Text('Criar primeiro projeto'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ProjetoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: provider.projetos.length,
      itemBuilder: (context, index) {
        final projeto = provider.projetos[index];
        DebugService.log(
          module: 'PROJETO',
          action: 'ITEM',
          data: 'Projeto ${index + 1}: ${projeto.descricao}',
        );
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                projeto.descricao?.substring(0, 1).toUpperCase() ?? 'P',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              projeto.descricao ?? 'Sem título',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (projeto.processo != null)
                  Text('Processo: ${projeto.processo}'),
                Chip(
                  label: Text(projeto.statusLabel),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  labelStyle: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: AppTheme.primaryColor),
                  onPressed: () {
                    DebugService.log(
                      module: 'PROJETO',
                      action: 'VISUALIZAR',
                      data: 'Projeto ID: ${projeto.id}',
                    );
                    context.go('/projetos/${projeto.id}');
                  },
                  tooltip: 'Ver detalhes',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    DebugService.log(
                      module: 'PROJETO',
                      action: 'EDITAR',
                      data: 'Projeto ID: ${projeto.id}',
                    );
                    context.go('/projetos/editar/${projeto.id}');
                  },
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    DebugService.log(
                      module: 'PROJETO',
                      action: 'EXCLUIR',
                      data: 'Projeto ID: ${projeto.id}',
                    );
                    _confirmDelete(context, projeto);
                  },
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ProjetoModel projeto) {
    DebugService.log(
      module: 'PROJETO',
      action: 'CONFIRMAR_EXCLUSAO',
      data: 'Projeto: ${projeto.descricao}',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o projeto "${projeto.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              DebugService.log(
                module: 'PROJETO',
                action: 'EXCLUIR_CONFIRMADO',
                data: 'Excluindo projeto ID: ${projeto.id}',
              );
              Navigator.pop(context);
              final success = await context.read<ProjetoProvider>().deleteProjeto(projeto.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Projeto excluído com sucesso')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}