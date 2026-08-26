/// ============================================
/// TELA: Lista de Projetos
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/projetos/constants.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjetoProvider>().loadProjetos();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce para pesquisa (Regra 13)
    Future.delayed(_debounce, () {
      if (mounted) {
        _aplicarFiltros();
      }
    });
  }

  void _aplicarFiltros() {
    final provider = context.read<ProjetoProvider>();
    provider.loadProjetos(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      status: _statusFilter.isNotEmpty ? _statusFilter : null,
    );
  }

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
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<ProjetoProvider>(
              builder: (context, provider, child) {
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
              setState(() => _statusFilter = value ?? '');
              _aplicarFiltros();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ProjetoProvider provider) {
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_outlined, size: 64, color: AppTheme.textLight),
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

  Widget _buildList(ProjetoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: provider.projetos.length,
      itemBuilder: (context, index) {
        final projeto = provider.projetos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: projeto.statusColor,
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
                Row(
                  children: [
                    Chip(
                      label: Text(projeto.statusLabel),
                      backgroundColor: projeto.statusColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: projeto.statusColor),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'R\$ ${projeto.valorTotalMetas?.toStringAsFixed(2) ?? '0,00'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: AppTheme.primaryColor),
                  onPressed: () => context.go('/projetos/${projeto.id}'),
                  tooltip: 'Ver detalhes',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => context.go('/projetos/editar/${projeto.id}'),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, projeto),
                  tooltip: 'Excluir',
                ),
              ],
            ),
            onTap: () => context.go('/projetos/${projeto.id}'),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ProjetoModel projeto) {
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