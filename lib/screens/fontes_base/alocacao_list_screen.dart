import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fontes_base_provider.dart';
import '../../models/fonte_alocacao.dart';
import '../../models/fontes_base.dart';

class AlocacaoListScreen extends StatefulWidget {
  const AlocacaoListScreen({Key? key}) : super(key: key);

  @override
  State<AlocacaoListScreen> createState() => _AlocacaoListScreenState();
}

class _AlocacaoListScreenState extends State<AlocacaoListScreen> {
  bool _isLoading = true;
  String? _error;
  String _filtroFonteId = 'Todas as fontes';
  DateTime? _dataInicio;
  DateTime? _dataFim;

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
    final todasAlocacoes = provider.alocacoes;

    // ✅ Aplica filtros
    var alocacoesFiltradas = List<FonteAlocacao>.from(todasAlocacoes);

    // Filtro por fonte
    if (_filtroFonteId != 'Todas as fontes') {
      alocacoesFiltradas = alocacoesFiltradas
          .where((a) => a.fonte_alocacao == _filtroFonteId)
          .toList();
    }

    // Filtro por data
    if (_dataInicio != null) {
      alocacoesFiltradas = alocacoesFiltradas
          .where((a) => a.data_alocacao.isAfter(_dataInicio!.subtract(const Duration(days: 1))))
          .toList();
    }
    if (_dataFim != null) {
      alocacoesFiltradas = alocacoesFiltradas
          .where((a) => a.data_alocacao.isBefore(_dataFim!.add(const Duration(days: 1))))
          .toList();
    }

    // ✅ Ordena por data (mais antiga primeiro para cálculo de saldo)
    alocacoesFiltradas.sort((a, b) => a.data_alocacao.compareTo(b.data_alocacao));

    // ✅ Calcula totais por fonte
    final Map<String, double> totalPorFonte = {};
    final Map<String, String> nomePorFonte = {};
    for (var alocacao in alocacoesFiltradas) {
      totalPorFonte[alocacao.fonte_alocacao] = 
          (totalPorFonte[alocacao.fonte_alocacao] ?? 0) + alocacao.valor_alocado;
      
      // Busca o nome da fonte
      final fonte = fontes.firstWhere(
        (f) => f.id == alocacao.fonte_alocacao,
        orElse: () => FontesBase(
          id: alocacao.fonte_alocacao,
          descricao: 'Fonte não identificada',
          entidade: '',
          valor_recurso: 0,
          remanejamento: 0,
          data_aprovacao: DateTime.now(),
        ),
      );
      nomePorFonte[alocacao.fonte_alocacao] = fonte.descricao ?? 'Fonte não identificada';
    }

    // ✅ Agrupa alocações por fonte
    final Map<String, List<FonteAlocacao>> alocacoesPorFonte = {};
    for (var alocacao in alocacoesFiltradas) {
      if (!alocacoesPorFonte.containsKey(alocacao.fonte_alocacao)) {
        alocacoesPorFonte[alocacao.fonte_alocacao] = [];
      }
      alocacoesPorFonte[alocacao.fonte_alocacao]!.add(alocacao);
    }

    // ✅ Calcula totais gerais
    final totalGeral = fontes.fold(0.0, (sum, f) => sum + f.valor_recurso);
    final totalAlocado = todasAlocacoes.fold(0.0, (sum, a) => sum + a.valor_alocado);
    final saldoGeral = totalGeral - totalAlocado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Alocações'),
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
                    // ✅ Filtros
                    _buildFiltros(fontes),
                    const Divider(height: 1),
                    
                    // ✅ Totais Gerais
                    _buildTotaisGerais(totalGeral, totalAlocado, saldoGeral),
                    const Divider(height: 1),

                    // ✅ Lista de Alocações Agrupadas por Fonte
                    Expanded(
                      child: alocacoesFiltradas.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhuma alocação encontrada',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Ajuste os filtros para ver mais resultados',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: alocacoesPorFonte.keys.length,
                              itemBuilder: (context, index) {
                                final fonteId = alocacoesPorFonte.keys.elementAt(index);
                                final alocacoesDaFonte = alocacoesPorFonte[fonteId]!;
                                final totalFonte = totalPorFonte[fonteId] ?? 0;
                                final nomeFonte = nomePorFonte[fonteId] ?? 'Fonte não identificada';
                                
                                // Busca a fonte completa
                                final fonte = fontes.firstWhere(
                                  (f) => f.id == fonteId,
                                  orElse: () => FontesBase(
                                    id: fonteId,
                                    descricao: nomeFonte,
                                    entidade: '',
                                    valor_recurso: 0,
                                    remanejamento: 0,
                                    data_aprovacao: DateTime.now(),
                                  ),
                                );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ✅ Cabeçalho da Fonte
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        border: Border(
                                          bottom: BorderSide(color: Colors.blue[200]!),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  nomeFonte,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Entidade: ${fonte.entidade ?? 'Não informada'}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Total: ${_formatMoney(fonte.valor_recurso)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                'Alocado: ${_formatMoney(totalFonte)}',
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                'Saldo: ${_formatMoney(fonte.valor_recurso - totalFonte)}',
                                                style: TextStyle(
                                                  color: (fonte.valor_recurso - totalFonte) > 0
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // ✅ Lista de alocações da fonte
                                    ...alocacoesDaFonte.asMap().entries.map((entry) {
                                      final alocIndex = entry.key;
                                      final alocacao = entry.value;
                                      final isPrimeira = alocIndex == 0;
                                      
                                      // Calcula saldo acumulado dentro desta fonte
                                      double saldoAcumulado = 0;
                                      for (int i = 0; i <= alocIndex; i++) {
                                        saldoAcumulado += alocacoesDaFonte[i].valor_alocado;
                                      }

                                      // Percentual em relação ao total da fonte
                                      final percentualTotal = fonte.valor_recurso > 0
                                          ? (alocacao.valor_alocado / fonte.valor_recurso) * 100
                                          : 0;

                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 2,
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: isPrimeira
                                                ? Colors.green[100]
                                                : Colors.blue[100],
                                            child: Text(
                                              '${alocIndex + 1}',
                                              style: TextStyle(
                                                color: isPrimeira
                                                    ? Colors.green[800]
                                                    : Colors.blue[800],
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
                                                'Destino: ${alocacao.projeto?.descricao ?? alocacao.destino_alocao}',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                'Data: ${_formatDate(alocacao.data_alocacao)}',
                                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                              ),
                                              if (isPrimeira)
                                                Container(
                                                  margin: const EdgeInsets.only(top: 2),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 1,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[100],
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    'SALDO INICIAL',
                                                    style: TextStyle(
                                                      color: Colors.green[800],
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _formatMoney(alocacao.valor_alocado),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: isPrimeira
                                                      ? Colors.green[700]
                                                      : Colors.blue[700],
                                                ),
                                              ),
                                              Text(
                                                '${percentualTotal.toStringAsFixed(1)}% do total',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                'Saldo: ${_formatMoney(saldoAcumulado)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: saldoAcumulado > 0
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    
                                    // ✅ Totalizador da fonte
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        border: Border(
                                          top: BorderSide(color: Colors.grey[300]!),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total Alocado:',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _formatMoney(totalFonte),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFiltros(List<FontesBase> fontes) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // ✅ Filtro por Entidade (Fonte)
          Row(
            children: [
              const Text(
                'Filtrar por Entidade',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _filtroFonteId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: 'Todas as fontes',
                      child: Text('Todas as fontes'),
                    ),
                    ...fontes.map((fonte) {
                      return DropdownMenuItem(
                        value: fonte.id,
                        child: Text(fonte.descricao ?? 'Sem descrição'),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filtroFonteId = value ?? 'Todas as fontes';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // ✅ Filtro por Data
          Row(
            children: [
              const Text(
                'Filtro Rápido',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDateFilter(
                        label: 'Data Início',
                        date: _dataInicio,
                        onChanged: (date) {
                          setState(() => _dataInicio = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDateFilter(
                        label: 'Data Fim',
                        date: _dataFim,
                        onChanged: (date) {
                          setState(() => _dataFim = date);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    _dataInicio = null;
                    _dataFim = null;
                    _filtroFonteId = 'Todas as fontes';
                  });
                },
                tooltip: 'Limpar Filtros',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                date != null
                    ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                    : label,
                style: TextStyle(
                  fontSize: 12,
                  color: date != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            if (date != null)
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                onPressed: () => onChanged(null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotaisGerais(double total, double alocado, double saldo) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}