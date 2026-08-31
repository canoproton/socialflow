import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fontes/fontes_base_provider.dart';
import '../../providers/fontes/fontes_alocacao_provider.dart';
import '../../models/fontes/fontes_base_model.dart';
import 'fontes_alocacao_screen.dart';
import 'fontes_extrato_screen.dart';

/// Tela de Pesquisa de Fontes de Recursos
class FontesPesquisaScreen extends StatefulWidget {
  const FontesPesquisaScreen({Key? key}) : super(key: key);

  @override
  State<FontesPesquisaScreen> createState() => _FontesPesquisaScreenState();
}

class _FontesPesquisaScreenState extends State<FontesPesquisaScreen> {
  final _entidadeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorMinController = TextEditingController();
  final _valorMaxController = TextEditingController();

  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _comSaldo = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _entidadeController.dispose();
    _descricaoController.dispose();
    _valorMinController.dispose();
    _valorMaxController.dispose();
    super.dispose();
  }

  Future<void> _pesquisar() async {
    setState(() => _isLoading = true);

    final termo = _entidadeController.text.isNotEmpty 
        ? _entidadeController.text 
        : _descricaoController.text;

    final valorMin = double.tryParse(
      _valorMinController.text.replaceAll(',', '.')
    );
    final valorMax = double.tryParse(
      _valorMaxController.text.replaceAll(',', '.')
    );

    try {
      await context.read<FontesBaseProvider>().pesquisarFontes(
        termo,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        valorMinimo: valorMin,
        valorMaximo: valorMax,
        comSaldo: _comSaldo,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na pesquisa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limparFiltros() {
    setState(() {
      _entidadeController.clear();
      _descricaoController.clear();
      _valorMinController.clear();
      _valorMaxController.clear();
      _dataInicio = null;
      _dataFim = null;
      _comSaldo = false;
    });
    context.read<FontesBaseProvider>().limparSelecao();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FontesBaseProvider>();
    final alocacaoProvider = context.watch<FontesAlocacaoProvider>();

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
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Entidade
                  TextFormField(
                    controller: _entidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Entidade',
                      hintText: 'Nome da entidade financiadora',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                      isDense: true,
                    ),
                    onFieldSubmitted: (_) => _pesquisar(),
                  ),
                  const SizedBox(height: 8),

                  // Descrição
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição do Recurso',
                      hintText: 'Descritivo da fonte',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      isDense: true,
                    ),
                    onFieldSubmitted: (_) => _pesquisar(),
                  ),
                  const SizedBox(height: 8),

                  // Data Início e Fim
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataPicker(
                          label: 'Data Início',
                          value: _dataInicio,
                          onChanged: (date) => setState(() => _dataInicio = date),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDataPicker(
                          label: 'Data Fim',
                          value: _dataFim,
                          onChanged: (date) => setState(() => _dataFim = date),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Valor Mínimo e Máximo
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _valorMinController,
                          decoration: const InputDecoration(
                            labelText: 'Valor Mínimo',
                            hintText: '0,00',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _valorMaxController,
                          decoration: const InputDecoration(
                            labelText: 'Valor Máximo',
                            hintText: '0,00',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Com Saldo
                  CheckboxListTile(
                    value: _comSaldo,
                    onChanged: (value) {
                      setState(() => _comSaldo = value ?? false);
                    },
                    title: const Text('Com Saldo Disponível'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 12),

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _limparFiltros,
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                          label: _isLoading
                              ? const Text('Pesquisando...')
                              : const Text('Pesquisar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ✅ Resultados
          Expanded(
            child: provider.isLoading || _isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.fontes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              provider.erro ?? 'Nenhum resultado encontrado',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajuste os filtros e tente novamente',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: provider.fontes.length,
                        itemBuilder: (context, index) {
                          final fonte = provider.fontes[index];
                          return _buildResultItem(fonte);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPicker({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null
                    ? DateFormat('dd/MM/yyyy').format(value!)
                    : 'Selecione',
              ),
            ),
            if (value != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => onChanged(null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(FontesBase fonte) {
    final saldo = fonte.saldo_total ?? 0;
    final isDisponivel = saldo > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDisponivel ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isDisponivel ? Icons.account_balance : Icons.account_balance_outlined,
            color: isDisponivel ? Colors.green[700] : Colors.red[700],
          ),
        ),
        title: Text(
          fonte.entidade,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fonte.descricao,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Valor: ${fonte.valorRecursoFormatado}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Saldo: ${fonte.saldoFormatado}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDisponivel ? Colors.green[700] : Colors.red[700],
              ),
            ),
            if (fonte.data_aprovacao != null)
              Text(
                'Aprovação: ${fonte.dataAprovacaoFormatada}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDisponivel)
              IconButton(
                icon: const Icon(Icons.attach_money, color: Colors.orange),
                onPressed: () => _alocarRecursos(fonte.id!),
                tooltip: 'Alocar Recurso',
              ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.blue),
              onPressed: () => _verExtrato(fonte.id!),
              tooltip: 'Ver Extrato',
            ),
          ],
        ),
      ),
    );
  }

  void _alocarRecursos(String fonteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FontesAlocacaoScreen(fonteId: fonteId),
      ),
    );
  }

  void _verExtrato(String fonteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FontesExtratoScreen(fonteId: fonteId),
      ),
    );
  }
}