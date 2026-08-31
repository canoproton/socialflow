import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alocacao_provider.dart';
import '../../models/fonte_alocacao.dart';
import '../../models/fontes_base.dart';

class AlocacaoFormScreen extends StatefulWidget {
  final String fonteId;
  final String? alocacaoId;

  const AlocacaoFormScreen({
    Key? key,
    required this.fonteId,
    this.alocacaoId,
  }) : super(key: key);

  @override
  State<AlocacaoFormScreen> createState() => _AlocacaoFormScreenState();
}

class _AlocacaoFormScreenState extends State<AlocacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();
  final _obsController = TextEditingController();

  FontesBase? _fonte;
  List<FonteAlocacao> _extrato = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      final alocacaoProvider = context.read<AlocacaoProvider>();
      
      // 🔧 CORREÇÃO 1: Carregar extrato com método correto
      await alocacaoProvider.carregarExtrato(widget.fonteId);
      
      // 🔧 CORREÇÃO 4: Buscar fonte pelo ID
      _fonte = await alocacaoProvider.getFonteBase(widget.fonteId);
      _extrato = alocacaoProvider.extratoAtual;

      // Se tiver alocacaoId, carregar dados para edição
      if (widget.alocacaoId != null) {
        await alocacaoProvider.selecionarAlocacao(widget.alocacaoId!);
        final alocacao = alocacaoProvider.alocacaoSelecionada;
        if (alocacao != null) {
          _descricaoController.text = alocacao.descricao ?? '';
          _valorController.text = alocacao.valor_alocado?.toString() ?? '';
          _dataController.text = alocacao.data_alocacao?.toIso8601String().split('T').first ?? '';
          _obsController.text = alocacao.obs ?? '';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final alocacao = FonteAlocacao(
        id: widget.alocacaoId,
        fonte_alocacao_id: widget.fonteId,
        descricao: _descricaoController.text,
        valor_alocado: double.tryParse(_valorController.text.replaceAll(',', '.')),
        data_alocacao: _dataController.text.isNotEmpty
            ? DateTime.parse(_dataController.text)
            : DateTime.now(),
        obs: _obsController.text.isNotEmpty ? _obsController.text : null,
      );

      // 🔧 CORREÇÃO 3: Salvar com método correto
      await context.read<AlocacaoProvider>().salvarAlocacao(alocacao);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alocação salva com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatMoney(double? value) {
    if (value == null) return 'R\$ 0,00';
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    // 🔧 CORREÇÃO 5: Usar _fonte (objeto) para acessar propriedades
    final saldoAtual = _extrato.fold<double>(0, (sum, a) => sum + (a.saldo_recurso ?? 0));
    final totalAlocado = _extrato.fold<double>(0, (sum, a) => sum + (a.valor_alocado ?? 0));
    final valorRecurso = _fonte?.valor_recurso ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alocacaoId != null ? 'Editar Alocação' : 'Nova Alocação'),
        actions: [
          if (widget.alocacaoId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmarExclusao,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Informações da Fonte
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_balance),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _fonte?.entidade ?? 'Carregando...',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoItem('Total', _formatMoney(valorRecurso)),
                                _buildInfoItem('Alocado', _formatMoney(totalAlocado)),
                                _buildInfoItem('Saldo', _formatMoney(saldoAtual)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe uma descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Valor
                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor Alocado',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe o valor';
                        }
                        final valor = double.tryParse(value.replaceAll(',', '.'));
                        if (valor == null) {
                          return 'Valor inválido';
                        }
                        if (valor <= 0) {
                          return 'O valor deve ser maior que zero';
                        }
                        if (valor > saldoAtual) {
                          return 'Valor excede o saldo disponível (${_formatMoney(saldoAtual)})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Data
                    TextFormField(
                      controller: _dataController,
                      decoration: const InputDecoration(
                        labelText: 'Data da Alocação',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          _dataController.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione uma data';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Observações
                    TextFormField(
                      controller: _obsController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _salvar,
                            child: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _confirmarExclusao() async {
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

    if (confirm == true && widget.alocacaoId != null) {
      setState(() => _isLoading = true);
      try {
        await context.read<AlocacaoProvider>().removerAlocacao(widget.alocacaoId!);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alocação removida com sucesso!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}