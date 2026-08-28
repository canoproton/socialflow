/// ============================================
/// TELA: Lista de Fontes de Recursos
/// REGRA 7
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../services/projetos/fontes_base_service.dart';
import '../../theme/app_theme.dart';

class FontesBaseListScreen extends StatefulWidget {
  const FontesBaseListScreen({super.key});

  @override
  State<FontesBaseListScreen> createState() => _FontesBaseListScreenState();
}

class _FontesBaseListScreenState extends State<FontesBaseListScreen> {
  final FontesBaseService _service = FontesBaseService();
  List<FontesBaseModel> _fontes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarFontes();
  }

  Future<void> _carregarFontes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _fontes = await _service.list();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fontes de Recursos'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/projetos/fontes/novo'),
            tooltip: 'Nova Fonte',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarFontes,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarFontes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_fontes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            const Text('Nenhuma fonte de recurso cadastrada'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/projetos/fontes/novo'),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Fonte'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _fontes.length,
      itemBuilder: (context, index) {
        final fonte = _fontes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                fonte.descricao.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              fonte.descricao,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entidade: ${fonte.entidade}'),
                Text(
                  'Valor: ${_formatCurrency(fonte.valorRecurso)}',
                  style: const TextStyle(color: Colors.green),
                ),
                if (fonte.dataAprovacao != null)
                  Text('Aprovação: ${_formatDate(fonte.dataAprovacao)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: AppTheme.primaryColor),
                  onPressed: () => context.go('/projetos/fontes/${fonte.id}'),
                  tooltip: 'Ver detalhes',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => context.go('/projetos/fontes/editar/${fonte.id}'),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(fonte),
                  tooltip: 'Excluir',
                ),
              ],
            ),
            onTap: () => context.go('/projetos/fontes/${fonte.id}'),
          ),
        );
      },
    );
  }

  void _confirmDelete(FontesBaseModel fonte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a fonte "${fonte.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.delete(fonte.id);
                await _carregarFontes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonte excluída com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
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