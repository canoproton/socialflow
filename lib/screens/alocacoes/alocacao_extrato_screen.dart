import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alocacao_provider.dart';
import '../../models/fonte_alocacao.dart';

class AlocacaoExtratoScreen extends StatefulWidget {
  final String fonteId;

  const AlocacaoExtratoScreen({
    Key? key,
    required this.fonteId,
  }) : super(key: key);

  @override
  State<AlocacaoExtratoScreen> createState() => _AlocacaoExtratoScreenState();
}

class _AlocacaoExtratoScreenState extends State<AlocacaoExtratoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ CORREÇÃO: usar carregarExtrato
      context.read<AlocacaoProvider>().carregarExtrato(widget.fonteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlocacaoProvider>();
    final alocacoes = provider.extratoAtual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato de Alocações'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : alocacoes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma alocação encontrada',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : _buildExtrato(alocacoes), // ← Passando List<FonteAlocacao>
    );
  }

  // ✅ CORREÇÃO: função recebe List<FonteAlocacao>
  Widget _buildExtrato(List<FonteAlocacao> alocacoes) {
    final totalAlocado = alocacoes.fold<double>(
      0, (sum, a) => sum + (a.valor_alocado ?? 0)
    );

    return Column(
      children: [
        // Resumo
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResumoItem('Total Alocações', alocacoes.length.toString()),
              _buildResumoItem('Valor Total', 'R\$ ${totalAlocado.toStringAsFixed(2).replaceAll('.', ',')}'),
            ],
          ),
        ),
        const Divider(height: 1),

        // Lista
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: alocacoes.length,
            itemBuilder: (context, index) {
              final alocacao = alocacoes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                  title: Text(
                    alocacao.descricao ?? 'Sem descrição',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor: R\$ ${alocacao.valor_alocado?.toStringAsFixed(2).replaceAll('.', ',') ?? '0,00'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (alocacao.data_alocacao != null)
                        Text(
                          'Data: ${_formatDate(alocacao.data_alocacao!)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      if (alocacao.saldo_recurso != null)
                        Text(
                          'Saldo após: R\$ ${alocacao.saldo_recurso!.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: alocacao.saldo_recurso! > 0 ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(context, alocacao.id!),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResumoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _confirmarExclusao(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta alocação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<AlocacaoProvider>().removerAlocacao(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alocação removida com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}