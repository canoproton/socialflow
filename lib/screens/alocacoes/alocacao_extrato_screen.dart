import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alocacao_provider.dart';
import 'alocacao_form_screen.dart';

class AlocacaoExtratoScreen extends StatefulWidget {
  final String fonteId;

  const AlocacaoExtratoScreen({Key? key, required this.fonteId}) : super(key: key);

  @override
  State<AlocacaoExtratoScreen> createState() => _AlocacaoExtratoScreenState();
}

class _AlocacaoExtratoScreenState extends State<AlocacaoExtratoScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExtrato();
  }

  Future<void> _loadExtrato() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<AlocacaoProvider>().carregarExtrato(widget.fonteId);
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
    final provider = context.watch<AlocacaoProvider>();
    final extratoData = provider.extratoAtual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato da Fonte'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExtrato,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : extratoData == null
                  ? const Center(child: Text('Nenhum dado encontrado'))
                  : _buildExtrato(extratoData), // extratoData já é List<FonteAlocacao>
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
            'Erro ao carregar extrato:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadExtrato,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildExtrato(Map<String, dynamic> extratoData) {
    final fonte = extratoData['fonte'];
    final extrato = extratoData['extrato'] as List;
    final saldoAtual = extratoData['saldo_atual'] as double;

    return Column(
      children: [
        // Cabeçalho da Fonte
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entidade: ${fonte.entidade ?? 'Entidade não informada'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Valor do Recurso',
                      value: _formatMoney(fonte.valor_recurso),
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Data de Entrada',
                      value: _formatDate(fonte.data_aprovacao),
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Saldo Atual',
                      value: _formatMoney(saldoAtual),
                      color: saldoAtual > 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Botão de Alocação
        if (saldoAtual > 0)
          Container(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlocacaoFormScreen(
                      fonteId: widget.fonteId,
                    ),
                  ),
                );
                if (result == true) {
                  _loadExtrato();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova Alocação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recurso sem saldo para alocação',
                      style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const Divider(height: 1),

        // Extrato
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: extrato.length,
            itemBuilder: (context, index) {
              final item = extrato[index];
              final isSaldoInicial = item['isSaldoInicial'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                elevation: isSaldoInicial ? 0 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSaldoInicial ? Colors.green[50] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: isSaldoInicial
                        ? Border.all(color: Colors.green[200]!)
                        : null,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSaldoInicial ? Colors.green[100] : Colors.blue[100],
                      child: Icon(
                        isSaldoInicial ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isSaldoInicial ? Colors.green[700] : Colors.blue[700],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      isSaldoInicial ? 'SALDO INICIAL' : (item['descricao'] ?? 'Alocação'),
                      style: TextStyle(
                        fontWeight: isSaldoInicial ? FontWeight.bold : FontWeight.normal,
                        color: isSaldoInicial ? Colors.green[700] : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data: ${_formatDate(item['data'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Destino: ${item['destino']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (!isSaldoInicial)
                          Text(
                            'Valor Alocado: ${_formatMoney(item['valor'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isSaldoInicial ? _formatMoney(item['valor']) : '-${_formatMoney(item['valor'])}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSaldoInicial ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                        Text(
                          'Saldo: ${_formatMoney(item['saldo'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: item['saldo'] >= 0 ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}