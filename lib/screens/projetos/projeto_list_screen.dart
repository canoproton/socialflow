/// ============================================
/// TELA: Lista de Projetos (com Filtros Básicos)
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../theme/app_theme.dart';

class ProjetoListScreen extends StatefulWidget {
  const ProjetoListScreen({super.key});

  @override
  State<ProjetoListScreen> createState() => _ProjetoListScreenState();
}

class _ProjetoListScreenState extends State<ProjetoListScreen> {
  // ⭐ CONTROLLER PARA BUSCA
  final TextEditingController _searchController = TextEditingController();
  
  // ⭐ FILTRO DE STATUS
  String _statusFilter = '';
  
  // ⭐ DEBOUNCE PARA BUSCA (500ms)
  final _debounce = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    print('📋 [PROJETO_LIST] INIT - Inicializando lista de projetos');
    
    // ⭐ CARREGAR PROJETOS AO INICIAR
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjetoProvider>().loadProjetos();
    });
    
    // ⭐ ADICIONAR LISTENER PARA BUSCA COM DEBOUNCE
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    print('🗑️ [PROJETO_LIST] DISPOSE - Dispondo lista de projetos');
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ============================================
  // MÉTODO: BUSCA COM DEBOUNCE (Regra 13)
  // ============================================

  void _onSearchChanged() {
    // ⭐ AGUARDA 500ms APÓS A ÚLTIMA DIGITAÇÃO
    Future.delayed(_debounce, () {
      if (mounted) {
        _aplicarFiltros();
      }
    });
  }

  void _aplicarFiltros() {
    print('📋 [PROJETO_LIST] APLICAR_FILTROS - '
        'Search: ${_searchController.text}, '
        'Status: $_statusFilter');

    // ⭐ CHAMAR SEM PARÂMETROS
    context.read<ProjetoProvider>().loadProjetos();
  }

  // ============================================
  // MÉTODO: LIMPAR FILTROS
  // ============================================

  void _limparFiltros() {
    print('🧹 [PROJETO_LIST] LIMPAR_FILTROS - Limpando todos os filtros');
    setState(() {
      _searchController.clear();
      _statusFilter = '';
    });
    _aplicarFiltros();
  }

  // ============================================
  // MÉTODO: EXECUTAR PROJETO (Regra 8)
  // ============================================

  void _executarProjeto(BuildContext context, String projetoId) async {
    print('📋 [PROJETO_LIST] EXECUTAR_PROJETO - Projeto: $projetoId');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Executar Projeto'),
        content: const Text(
          'Ao executar o projeto, todas as etapas serão disparadas para:\n\n'
          '📋 Tickets (módulo Tarefas)\n'
          '💰 ItemLancamento (módulo Financeiro)\n\n'
          'Deseja continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Executar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Executando projeto...'),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        final provider = context.read<ProjetoProvider>();
        final success = await provider.aprovarProjeto(projetoId);

        if (mounted) Navigator.pop(context);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Projeto executado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          provider.loadProjetos();
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ============================================
  // MÉTODO: CONFIRMAR EXCLUSÃO
  // ============================================

  void _confirmDelete(BuildContext context, ProjetoModel projeto) {
    print('⚠️ [PROJETO_LIST] CONFIRMAR_EXCLUSAO - Projeto: ${projeto.descricao}');
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
              print('🗑️ [PROJETO_LIST] EXCLUIR_CONFIRMADO - Projeto ID: ${projeto.id}');
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

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    print('📋 [PROJETO_LIST] BUILD - Construindo lista de projetos');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetos'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print('⬅️ [PROJETO_LIST] VOLTAR - Voltando para dashboard');
            context.go('/');
          },
          tooltip: 'Voltar para o Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              print('📋 [PROJETO_LIST] NOVO - Criando novo projeto');
              context.go('/projetos/novo');
            },
            tooltip: 'Novo Projeto',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('🔄 [PROJETO_LIST] REFRESH - Atualizando lista');
              context.read<ProjetoProvider>().refresh();
            },
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // ⭐ FILTROS BÁSICOS
          _buildFilters(),
          
          // ⭐ LISTA DE PROJETOS
          Expanded(
            child: Consumer<ProjetoProvider>(
              builder: (context, provider, child) {
                print('📋 [PROJETO_LIST] CONSUMER - isLoading: ${provider.isLoading}, projetos: ${provider.projetos.length}');

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

  // ============================================
  // FILTROS BÁSICOS
  // ============================================

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
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
          // ⭐ CAMPO DE BUSCA (Regra 13 - debounce)
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar projetos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          print('📋 [PROJETO_LIST] CLEAR_SEARCH - Limpando busca');
                          _searchController.clear();
                          _aplicarFiltros();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // ⭐ FILTRO DE STATUS
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _statusFilter.isEmpty ? null : _statusFilter,
              hint: const Text('Status'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                isDense: true,
              ),
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
                print('📋 [PROJETO_LIST] STATUS_FILTER - Novo status: $value');
                setState(() => _statusFilter = value ?? '');
                _aplicarFiltros();
              },
            ),
          ),
          
          const SizedBox(width: 8),
          
          // ⭐ BOTÃO LIMPAR
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.red),
            onPressed: _limparFiltros,
            tooltip: 'Limpar filtros',
          ),
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS DE ESTADO
  // ============================================

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
            onPressed: () {
              print('🔄 [PROJETO_LIST] RETRY - Tentando novamente');
              provider.loadProjetos();
            },
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
            onPressed: () {
              print('📋 [PROJETO_LIST] CRIAR_PRIMEIRO - Criando primeiro projeto');
              context.go('/projetos/novo');
            },
            icon: const Icon(Icons.add),
            label: const Text('Criar primeiro projeto'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // LISTA DE PROJETOS
  // ============================================

  Widget _buildList(ProjetoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: provider.projetos.length,
      itemBuilder: (context, index) {
        final projeto = provider.projetos[index];
        print('📋 [PROJETO_LIST] ITEM - Projeto ${index + 1}: ${projeto.descricao}');

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
                // ⭐ VER DETALHES
                IconButton(
                  icon: const Icon(Icons.visibility, color: AppTheme.primaryColor),
                  onPressed: () {
                    print('👁️ [PROJETO_LIST] VISUALIZAR - Projeto ID: ${projeto.id}');
                    context.go('/projetos/${projeto.id}');
                  },
                  tooltip: 'Ver detalhes',
                ),
                
                // ⭐ EDITAR
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    print('✏️ [PROJETO_LIST] EDITAR - Projeto ID: ${projeto.id}');
                    context.go('/projetos/editar/${projeto.id}');
                  },
                  tooltip: 'Editar',
                ),
                
                // ⭐ EXECUTAR (Regra 8) - Só aparece se status for APROVADO
                IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                    color: projeto.statusProjeto == ProjetoModel.STATUS_APROVADO 
                        ? Colors.green 
                        : Colors.grey,
                  ),
                  onPressed: () {
                    if (projeto.statusProjeto == ProjetoModel.STATUS_APROVADO) {
                      _executarProjeto(context, projeto.id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Projeto não está aprovado para execução'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  tooltip: 'Executar Projeto',
                ),
                
                // ⭐ EXCLUIR
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    print('🗑️ [PROJETO_LIST] EXCLUIR - Projeto ID: ${projeto.id}');
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
}