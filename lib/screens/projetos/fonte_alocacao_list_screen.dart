/// ============================================
/// TELA: Lista de Alocações de Recursos
/// REGRA 7
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/fonte_alocacao_model.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../services/projetos/fontes_base_service.dart';
import '../../theme/app_theme.dart';

class FonteAlocacaoListScreen extends StatefulWidget {
  final String? fonteId;

  const FonteAlocacaoListScreen({super.key, this.fonteId});

  @override
  State<FonteAlocacaoListScreen> createState() => _FonteAlocacaoListScreenState();
}

class _FonteAlocacaoListScreenState extends State<FonteAlocacaoListScreen> {
  final FontesBaseService _service = FontesBaseService();
  List<FonteAlocacaoModel> _alocacoes = [];
  FontesBaseModel? _fonte;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⭐ RECARREGAR QUANDO VOLTAR
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.fonteId != null) {
        _fonte = await _service.getById(widget.fonteId!);
        _alocacoes = await _service.getAlocacoes(widget.fonteId!);
        print('📋 [ALOCACAO_LIST] Carregadas ${_alocacoes.length} alocações');
      } else {
        // Carregar todas as alocações
        // TODO: Implementar listagem geral
        _alocacoes = [];
      }
    } catch (e) {
      _error = e.toString();
      print('❌ [ALOCACAO_LIST] Erro: $e');
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
        title: Text(
          widget.fonteId != null
              ? 'Alocações - ${_fonte?.descricao ?? 'Fonte'}'
              : 'Alocações de Recursos',
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/projetos/fontes'),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final url = widget.fonteId != null
                  ? '/projetos/fontes/alocacao/novo?fonteId=${widget.fonteId}'
                  : '/projetos/fontes/alocacao/novo';
              context.go(url);
            },
            tooltip: 'Nova Alocação',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
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
              onPressed: _carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Resumo da fonte
    if (_fonte != null) {
      return Column(
        children: [
          _buildResumoFonte(),
          Expanded(child: _buildListaAlocacoes()),
        ],
      );
    }

    return _buildListaAlocacoes();
  }

  Widget _buildResumoFonte() {
    final totalAlocado = _calcularTotalAlocado();
    final saldo = _calcularSaldo();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fonte!.descricao,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text('Entidade: ${_fonte!.entidade}'),
                Row(
                  children: [
                    Text(
                      'Total: ${_formatCurrency(_fonte!.valorRecurso)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Alocado: ${_formatCurrency(totalAlocado)}',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Saldo: ${_formatCurrency(saldo)}',
                      style: TextStyle(
                        color: saldo >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calcularTotalAlocado() {
    double total = 0;
    for (var alocacao in _alocacoes) {
      total += alocacao.valorAlocado;
    }
    return total;
  }

  double _calcularSaldo() {
    if (_fonte == null) return 0;
    return _fonte!.valorRecurso - _calcularTotalAlocado();
  }

  Widget _buildListaAlocacoes() {
    if (_alocacoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            const Text('Nenhuma alocação encontrada'),
            const SizedBox(height: 8),
            Text(
              'Clique em "+" para alocar este recurso',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _alocacoes.length,
      itemBuilder: (context, index) {
        final alocacao = _alocacoes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              alocacao.descricao,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Destino: ${alocacao.destinoAlocacaoId}'),
                Text(
                  'Valor: ${_formatCurrency(alocacao.valorAlocado)}',
                  style: const TextStyle(color: Colors.orange),
                ),
                if (alocacao.dataAlocacao != null)
                  Text('Data: ${_formatDate(alocacao.dataAlocacao)}'),
                if (alocacao.saldoRecurso != null)
                  Text(
                    'Saldo: ${_formatCurrency(alocacao.saldoRecurso!)}',
                    style: TextStyle(
                      color: alocacao.saldoRecurso! >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(alocacao),
              tooltip: 'Excluir',
            ),
            onTap: () {
              // TODO: Editar alocação
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edição de alocação em desenvolvimento'),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(FonteAlocacaoModel alocacao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir esta alocação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.deleteAlocacao(alocacao.id);
                await _carregarDados();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alocação excluída com sucesso!')),
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