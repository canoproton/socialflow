import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fontes/fontes_base_provider.dart';
import '../../providers/fontes/fontes_alocacao_provider.dart';
import '../../models/fontes/fontes_alocacao_model.dart';
import 'fontes_alocacao_screen.dart';

/// Tela de Extrato das Fontes de Recursos
class FontesExtratoScreen extends StatefulWidget {
  final String fonteId;

  const FontesExtratoScreen({Key? key, required this.fonteId}) : super(key: key);

  @override
  State<FontesExtratoScreen> createState() => _FontesExtratoScreenState();
}

class _FontesExtratoScreenState extends State<FontesExtratoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  Future<void> _carregarDados() async {
    try {
      await context.read<FontesBaseProvider>().selecionarFonte(widget.fonteId);
      await context.read<FontesAlocacaoProvider>().carregarExtrato(widget.fonteId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar extrato: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fonteProvider = context.watch<FontesBaseProvider>();
    final alocacaoProvider = context.watch<FontesAlocacaoProvider>();

    final fonte = fonteProvider.fonteSelecionada;
    final extrato = alocacaoProvider.extrato;
    final saldoAtual = alocacaoProvider.saldoAtual ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato do Recurso'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: fonteProvider.isLoading || alocacaoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ Informações da Fonte
                if (fonte != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[50],
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem(
                              'Saldo Inicial',
                              fonte.valorRecursoFormatado,
                              Colors.blue,
                            ),
                            _buildInfoItem(
                              'Total Alocado',
                              _formatMoney(
                                extrato.fold<double>(
                                  0, (sum, a) => sum + a.valor_alocado
                                )
                              ),
                              Colors.orange,
                            ),
                            _buildInfoItem(
                              'Saldo Atual',
                              _formatMoney(saldoAtual),
                              saldoAtual > 0 ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${fonte.entidade} - ${fonte.descricao}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                // ✅ Lista de Lançamentos
                Expanded(
                  child: extrato.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                alocacaoProvider.erro ?? 'Nenhum lançamento encontrado',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: extrato.length,
                          itemBuilder: (context, index) {
                            final alocacao = extrato[index];
                            return _buildLancamentoCard(alocacao, index + 1);
                          },
                        ),
                ),

                // ✅ Botão Alocar Recurso
                if (saldoAtual > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FontesAlocacaoScreen(
                                    fonteId: widget.fonteId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.attach_money),
                            label: const Text('Alocar Recurso'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Voltar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Voltar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLancamentoCard(FontesAlocacao alocacao, int numero) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            '$numero',
            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          alocacao.descricao,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destino: ${alocacao.destinoLabel}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Data: ${alocacao.dataAlocacaoFormatada}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '- ${alocacao.valorAlocadoFormatado}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            Text(
              'Saldo: ${alocacao.saldoRecursoFormatado}',
              style: TextStyle(
                fontSize: 12,
                color: alocacao.saldo_recurso > 0 ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}