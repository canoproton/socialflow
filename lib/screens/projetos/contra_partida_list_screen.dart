/// ============================================
/// TELA: Lista de Contra Partidas
/// REGRA 11
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/contra_partida_model.dart';
import '../../services/projetos/contra_partida_service.dart';
import '../../theme/app_theme.dart';

class ContraPartidaListScreen extends StatefulWidget {
  const ContraPartidaListScreen({super.key});

  @override
  State<ContraPartidaListScreen> createState() => _ContraPartidaListScreenState();
}

class _ContraPartidaListScreenState extends State<ContraPartidaListScreen> {
  final ContraPartidaService _service = ContraPartidaService();
  List<ContraPartidaModel> _contraPartidas = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarContraPartidas();
  }

  Future<void> _carregarContraPartidas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _contraPartidas = await _service.list();
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

  Color _getStatusColor(String status) {
    switch (status) {
      case ContraPartidaModel.STATUS_PENDENTE:
        return Colors.orange;
      case ContraPartidaModel.STATUS_CONFIRMADO:
        return Colors.blue;
      case ContraPartidaModel.STATUS_REALIZADO:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contra Partidas'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/projetos'),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/projetos/contra-partida/novo'),
            tooltip: 'Nova Contra Partida',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarContraPartidas,
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
              onPressed: _carregarContraPartidas,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_contraPartidas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            const Text('Nenhuma contra partida cadastrada'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/projetos/contra-partida/novo'),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Contra Partida'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _contraPartidas.length,
      itemBuilder: (context, index) {
        final cp = _contraPartidas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(cp.status),
              child: Text(
                cp.descricao.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              cp.descricao,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Valor: ${_formatCurrency(cp.valor)}'),
                if (cp.dataEntrega != null)
                  Text('Entrega: ${_formatDate(cp.dataEntrega)}'),
                Chip(
                  label: Text(cp.statusLabel),
                  backgroundColor: _getStatusColor(cp.status).withOpacity(0.2),
                  labelStyle: TextStyle(color: _getStatusColor(cp.status)),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => context.go('/projetos/contra-partida/editar/${cp.id}'),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(cp),
                  tooltip: 'Excluir',
                ),
              ],
            ),
            onTap: () => context.go('/projetos/contra-partida/${cp.id}'),
          ),
        );
      },
    );
  }

  void _confirmDelete(ContraPartidaModel cp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a contra partida "${cp.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.delete(cp.id);
                await _carregarContraPartidas();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contra partida excluída com sucesso!')),
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