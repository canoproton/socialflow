import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fontes_base_provider.dart';
import '../../providers/projeto_provider.dart';
import 'fontes_base_form_screen.dart';
import 'fonte_detalhe_screen.dart';

class FontesBaseListScreen extends StatefulWidget {
  const FontesBaseListScreen({Key? key}) : super(key: key);

  @override
  State<FontesBaseListScreen> createState() => _FontesBaseListScreenState();
}

class _FontesBaseListScreenState extends State<FontesBaseListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<FontesBaseProvider>();
      await provider.loadFontes();
      
      // ✅ Carrega todas as alocações para calcular totais
      await provider.loadAlocacoes();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FontesBaseProvider>();
    final fontes = provider.fontes;
    final alocacoes = provider.alocacoes;

    // ✅ Calcula totais gerais
    final totalGeral = fontes.fold(0.0, (sum, f) => sum + f.valor_recurso);
    final totalAlocado = alocacoes.fold(0.0, (sum, a) => sum + a.valor_alocado);
    final saldoGeral = totalGeral - totalAlocado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fontes de Recursos'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    // ✅ Totais Gerais
                    _buildTotaisGerais(totalGeral, totalAlocado, saldoGeral),
                    const Divider(height: 1),
                    
                    // ✅ Lista de Fontes
                    Expanded(
                      child: fontes.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_balance, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhuma fonte de recurso cadastrada',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Clique no botão + para adicionar',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: fontes.length,
                              itemBuilder: (context, index) {
                                final fonte = fontes[index];
                                final alocacoesFonte = alocacoes
                                    .where((a) => a.fonte_alocacao == fonte.id)
                                    .toList();
                                final totalAlocadoFonte = alocacoesFonte
                                    .fold(0.0, (sum, a) => sum + a.valor_alocado);
                                final saldo = fonte.valor_recurso - totalAlocadoFonte;
                                final percentual = fonte.valor_recurso > 0
                                    ? (totalAlocadoFonte / fonte.valor_recurso) * 100
                                    : 0;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FonteDetalheScreen(
                                            fonteId: fonte.id,
                                          ),
                                        ),
                                      ).then((_) => _loadData()); // ✅ Atualiza ao voltar
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: saldo > 0
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                      child: Icon(
                                        saldo > 0
                                            ? Icons.account_balance
                                            : Icons.account_balance_outlined,
                                        color: saldo > 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                                    ),
                                    title: Text(
                                      fonte.descricao ?? 'Sem descrição',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Entidade: ${fonte.entidade ?? 'Não informada'}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _buildStatusChip(
                                              label: 'Total ${_formatMoney(fonte.valor_recurso)}',
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 4),
                                            _buildStatusChip(
                                              label: 'Alocado ${_formatMoney(totalAlocadoFonte)}',
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            _buildStatusChip(
                                              label: 'Saldo ${_formatMoney(saldo)}',
                                              color: saldo > 0 ? Colors.green : Colors.red,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: percentual / 100,
                                                backgroundColor: Colors.grey[200],
                                                color: percentual > 90
                                                    ? Colors.red
                                                    : percentual > 70
                                                        ? Colors.orange
                                                        : Colors.blue,
                                                minHeight: 6,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${percentual.toStringAsFixed(1)}%',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FonteDetalheScreen(
                                              fonteId: fonte.id,
                                            ),
                                          ),
                                        ).then((_) => _loadData());
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FontesBaseFormScreen(),
            ),
          );
          if (result == true) {
            await _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Fonte'),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildTotaisGerais(double total, double alocado, double saldo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTotalCard(
              label: 'Total Geral',
              value: _formatMoney(total),
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTotalCard(
              label: 'Total Alocado',
              value: _formatMoney(alocado),
              color: Colors.green[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTotalCard(
              label: 'Saldo Geral',
              value: _formatMoney(saldo),
              color: saldo > 0 ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard({
    required String label,
    required String value,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({required String label, required MaterialColor color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}