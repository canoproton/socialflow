import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fontes_base_provider.dart';
import '../../providers/projeto_provider.dart';
import '../../models/fonte_alocacao.dart';
import 'alocacao_form_screen.dart';

class FonteDetalheScreen extends StatefulWidget {
  final String fonteId;

  const FonteDetalheScreen({Key? key, required this.fonteId}) : super(key: key);

  @override
  State<FonteDetalheScreen> createState() => _FonteDetalheScreenState();
}

class _FonteDetalheScreenState extends State<FonteDetalheScreen> {
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
      await provider.loadAlocacoesByFonte(widget.fonteId);
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
    final fonte = provider.getFonteById(widget.fonteId);
    final alocacoes = provider.getAlocacoesByFonteId(widget.fonteId);
    
    final totalAlocado = alocacoes.fold(0.0, (sum, a) => sum + a.valor_alocado);
    final saldo = (fonte?.valor_recurso ?? 0) - totalAlocado;
    final percentual = (fonte?.valor_recurso ?? 0) > 0 
        ? (totalAlocado / (fonte?.valor_recurso ?? 1)) * 100 
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(fonte?.descricao ?? 'Detalhes da Fonte'),
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
              : fonte == null
                  ? const Center(child: Text('Fonte não encontrada'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Cabeçalho da Fonte
                          _buildFonteHeader(fonte, totalAlocado, saldo, percentual),
                          const SizedBox(height: 24),

                          // ✅ Botão Nova Alocação
                          _buildNewAlocacaoButton(),
                          const SizedBox(height: 16),

                          // ✅ Lista de Alocações
                          _buildAlocacoesList(alocacoes, totalAlocado),
                        ],
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

  Widget _buildFonteHeader(dynamic fonte, double totalAlocado, double saldo, double percentual) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fonte.descricao ?? 'Fonte sem descrição',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Entidade: ${fonte.entidade ?? 'Não informada'}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Resumo Financeiro
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Total',
                  value: _formatMoney(fonte.valor_recurso ?? 0),
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(
                  label: 'Alocado',
                  value: _formatMoney(totalAlocado),
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(
                  label: 'Saldo',
                  value: _formatMoney(saldo),
                  color: saldo > 0 ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progresso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${percentual.toStringAsFixed(1)}% alocado',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentual / 100,
                backgroundColor: Colors.grey[200],
                color: percentual > 90 
                    ? Colors.red 
                    : percentual > 70 
                        ? Colors.orange 
                        : Colors.blue,
                minHeight: 8,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Aprovação: ${_formatDate(fonte.data_aprovacao)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (fonte.obs != null && fonte.obs!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Obs: ${fonte.obs}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          if (fonte.remanejamento != null && fonte.remanejamento > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Remanejamento: ${fonte.remanejamento}% (${_formatMoney(fonte.valor_recurso * (fonte.remanejamento / 100))})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value, Color? color}) {
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

  Widget _buildNewAlocacaoButton() {
    return ElevatedButton.icon(
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
          _loadData();
          // ✅ Atualiza também a lista de fontes no provider
          await context.read<FontesBaseProvider>().loadFontes();
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
    );
  }

  Widget _buildAlocacoesList(List<FonteAlocacao> alocacoes, double totalAlocado) {
    if (alocacoes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Nenhuma alocação registrada',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Clique em "Nova Alocação" para começar',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico de Alocações',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...alocacoes.asMap().entries.map((entry) {
          final index = entry.key;
          final alocacao = entry.value;
          final isPrimeira = index == 0;
          final isRemanejamento = !isPrimeira;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isPrimeira ? Colors.green[100] : Colors.orange[100],
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isPrimeira ? Colors.green[800] : Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
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
                    'Projeto: ${alocacao.projeto?.descricao ?? alocacao.destino_alocao}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Data: ${_formatDate(alocacao.data_alocacao)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (isRemanejamento)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'REMANEJAMENTO',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Text(
                _formatMoney(alocacao.valor_alocado),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPrimeira ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ),
          );
        }).toList(),
        
        // ✅ Resumo final
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Alocado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _formatMoney(totalAlocado),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}