import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alocacao_provider.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/alocacao_pesquisa_filtro.dart';
import 'alocacao_extrato_screen.dart';

class AlocacaoPesquisaScreen extends StatefulWidget {
  const AlocacaoPesquisaScreen({Key? key}) : super(key: key);

  @override
  State<AlocacaoPesquisaScreen> createState() => _AlocacaoPesquisaScreenState();
}

class _AlocacaoPesquisaScreenState extends State<AlocacaoPesquisaScreen> {
  final _entidadeController = TextEditingController();
  bool _comSaldo = false;
  String? _projetoSelecionado;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ SÓ carrega a lista de projetos para o dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjetoProvider>().loadProjetos();
    });
    // ✅ NÃO carrega dados automaticamente
  }

  @override
  void dispose() {
    _entidadeController.dispose();
    super.dispose();
  }

  // ✅ Método de pesquisa - chamado apenas quando o usuário clica em Pesquisar
  Future<void> _pesquisar() async {
    final filtro = AlocacaoPesquisaFiltro(
      entidade: _entidadeController.text.isNotEmpty ? _entidadeController.text : null,
      comSaldo: _comSaldo ? true : null,
      projetoId: _projetoSelecionado,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    );

    setState(() => _isLoading = true);

    try {
      await context.read<AlocacaoProvider>().pesquisarFontes(filtro);
      print('✅ [PESQUISA] Resultados: ${context.read<AlocacaoProvider>().resultados.length}');
    } catch (e) {
      print('❌ [PESQUISA] Erro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na pesquisa: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limparFiltros() {
    setState(() {
      _entidadeController.clear();
      _comSaldo = false;
      _projetoSelecionado = null;
      _dataInicio = null;
      _dataFim = null;
    });
    context.read<AlocacaoProvider>().limparResultados();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlocacaoProvider>();
    final projetos = context.watch<ProjetoProvider>().projetos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Fontes de Recursos'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _limparFiltros,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Área de Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // Entidade
                TextFormField(
                  controller: _entidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Entidade',
                    hintText: 'Digite o nome da entidade',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                    isDense: true,
                  ),
                  onFieldSubmitted: (_) => _pesquisar(),
                ),
                const SizedBox(height: 8),

                // Linha: Com Saldo + Projeto
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        value: _comSaldo,
                        onChanged: (value) {
                          setState(() => _comSaldo = value ?? false);
                        },
                        title: const Text('Com Saldo Disponível'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _projetoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Projeto',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos os projetos'),
                          ),
                          ...projetos.map((projeto) {
                            return DropdownMenuItem(
                              value: projeto.id,
                              child: Text(projeto.descricao ?? 'Sem descrição'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _projetoSelecionado = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Range de Data
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dataInicio ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _dataInicio = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data Início',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _dataInicio != null
                                      ? '${_dataInicio!.day.toString().padLeft(2, '0')}/${_dataInicio!.month.toString().padLeft(2, '0')}/${_dataInicio!.year}'
                                      : 'Selecione',
                                ),
                              ),
                              if (_dataInicio != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => setState(() => _dataInicio = null),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dataFim ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _dataFim = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data Fim',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _dataFim != null
                                      ? '${_dataFim!.day.toString().padLeft(2, '0')}/${_dataFim!.month.toString().padLeft(2, '0')}/${_dataFim!.year}'
                                      : 'Selecione',
                                ),
                              ),
                              if (_dataFim != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => setState(() => _dataFim = null),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Botões de Ação
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _limparFiltros,
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pesquisar,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: _isLoading ? const Text('Pesquisando...') : const Text('Pesquisar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ Resultado da Pesquisa
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.resultados.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum resultado encontrado',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ajuste os filtros e tente novamente',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: provider.resultados.length,
                        itemBuilder: (context, index) {
                          final item = provider.resultados[index];
                          final fonte = item['fonte'];
                          final saldo = item['saldo'] as double;
                          final totalAlocado = item['total_alocado'] as double;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlocacaoExtratoScreen(
                                      fonteId: fonte.id,
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: saldo > 0 ? Colors.green[100] : Colors.red[100],
                                child: Icon(
                                  saldo > 0 ? Icons.account_balance : Icons.account_balance_outlined,
                                  color: saldo > 0 ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                              title: Text(
                                fonte.entidade ?? 'Entidade não informada',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fonte: ${fonte.descricao ?? 'Sem descrição'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Valor: ${_formatMoney(fonte.valor_recurso)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Saldo: ${_formatMoney(saldo)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: saldo > 0 ? Colors.green[700] : Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Alocado: ${_formatMoney(totalAlocado)} (${totalAlocado > 0 ? ((totalAlocado / fonte.valor_recurso) * 100).toStringAsFixed(1) : "0"}%)',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    'Data Aprovação: ${_formatDate(fonte.data_aprovacao)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: saldo > 0 ? Colors.green[100] : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  saldo > 0 ? 'DISPONÍVEL' : 'ESGOTADO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: saldo > 0 ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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