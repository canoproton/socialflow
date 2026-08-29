import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alocacao_provider.dart';
import '../../providers/projeto_provider.dart';
import '../../models/fonte_alocacao.dart';

class AlocacaoFormScreen extends StatefulWidget {
  final String fonteId;

  const AlocacaoFormScreen({Key? key, required this.fonteId}) : super(key: key);

  @override
  State<AlocacaoFormScreen> createState() => _AlocacaoFormScreenState();
}

class _AlocacaoFormScreenState extends State<AlocacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _projetoSelecionado;
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _obsController = TextEditingController();
  DateTime? _dataAlocacao;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataAlocacao = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    final alocacaoProvider = context.read<AlocacaoProvider>();
    final projetoProvider = context.read<ProjetoProvider>();
    
    await alocacaoProvider.getExtrato(widget.fonteId);
    await projetoProvider.loadProjetos();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_projetoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um projeto destino')),
      );
      return;
    }
    if (_dataAlocacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de alocação')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AlocacaoProvider>();
      final extrato = provider.extratoAtual;
      final saldoAtual = extrato?['saldo_atual'] as double? ?? 0;

      final valor = double.parse(_valorController.text);
      
      if (valor > saldoAtual) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Valor excede o saldo disponível (${_formatMoney(saldoAtual)})'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final alocacao = FonteAlocacao(
        id: '',
        fonte_alocacao_id: widget.fonteId,
        destino_alocao_id: _projetoSelecionado!,
        descricao: _descricaoController.text,
        valor_alocado: valor,
        saldo_recurso: saldoAtual - valor,
        data_alocacao: _dataAlocacao!,
        obs: _obsController.text.isNotEmpty ? _obsController.text : null,
      );

      await context.read<AlocacaoProvider>().createAlocacao(alocacao);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alocacaoProvider = context.watch<AlocacaoProvider>();
    final projetoProvider = context.watch<ProjetoProvider>();
    
    final extrato = alocacaoProvider.extratoAtual;
    final fonte = extrato?['fonte'];
    final saldoAtual = extrato?['saldo_atual'] as double? ?? 0;
    final totalAlocado = extrato?['total_alocado'] as double? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Alocação'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: fonte?.entidade ?? 'Carregando...',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fonte de Recurso *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Total',
                          value: _formatMoney(fonte?.valor_recurso ?? 0),
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Alocado',
                          value: _formatMoney(totalAlocado),
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Disponível',
                          value: _formatMoney(saldoAtual),
                          color: saldoAtual > 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _projetoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Destino (Projeto) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.folder),
                  ),
                  items: projetoProvider.projetos.map((projeto) {
                    return DropdownMenuItem(
                      value: projeto.id,
                      child: Text(projeto.descricao),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _projetoSelecionado = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Selecione um projeto';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição *',
                    hintText: 'Ex: Aporte para fase inicial',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite uma descrição';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _valorController,
                  decoration: InputDecoration(
                    labelText: 'Valor Alocado (R$) *',
                    hintText: 'Ex: 85000.00',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money),
                    helperText: 'Disponível: ${_formatMoney(saldoAtual)}',
                    helperStyle: TextStyle(
                      color: saldoAtual > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o valor';
                    }
                    final valor = double.tryParse(value);
                    if (valor == null || valor <= 0) {
                      return 'Digite um valor válido';
                    }
                    if (valor > saldoAtual) {
                      return 'Valor excede o saldo disponível (${_formatMoney(saldoAtual)})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dataAlocacao ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => _dataAlocacao = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de Alocação *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _dataAlocacao != null
                          ? '${_dataAlocacao!.day.toString().padLeft(2, '0')}/${_dataAlocacao!.month.toString().padLeft(2, '0')}/${_dataAlocacao!.year}'
                          : 'Selecione uma data',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _obsController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    hintText: 'Informações adicionais sobre a alocação',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.comment),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
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

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}