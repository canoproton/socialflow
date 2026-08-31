import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fontes/fontes_base_provider.dart';
import '../../providers/fontes/fontes_alocacao_provider.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/fontes/fontes_alocacao_model.dart';
import '../../models/enums/destino_tipo_enum.dart';

/// Tela de Alocação de Recursos
class FontesAlocacaoScreen extends StatefulWidget {
  final String? fonteId;

  const FontesAlocacaoScreen({Key? key, this.fonteId}) : super(key: key);

  @override
  State<FontesAlocacaoScreen> createState() => _FontesAlocacaoScreenState();
}

class _FontesAlocacaoScreenState extends State<FontesAlocacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _obsController = TextEditingController();

  String? _fonteId;
  FontesBase? _fonte;
  String? _destinoTipo = 'projeto';
  String? _destinoId;
  DateTime? _dataAlocacao;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fonteId = widget.fonteId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      final alocacaoProvider = context.read<FontesAlocacaoProvider>();

      if (_fonteId != null && _fonteId!.isNotEmpty) {
        // Carregar fonte
        await context.read<FontesBaseProvider>().selecionarFonte(_fonteId!);
        _fonte = context.read<FontesBaseProvider>().fonteSelecionada;

        // Carregar saldo
        await alocacaoProvider.carregarAlocacoesPorFonte(_fonteId!);

        // Definir data padrão
        _dataAlocacao = DateTime.now();
      }

      // Carregar projetos
      context.read<ProjetoProvider>().loadProjetos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_destinoId == null || _destinoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um destino para a alocação'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
    final saldoAtual = context.read<FontesAlocacaoProvider>().saldoAtual ?? 0;

    if (valor > saldoAtual) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Valor excede o saldo disponível. Saldo: R\$ ${saldoAtual.toStringAsFixed(2).replaceAll('.', ',')}'
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final alocacao = FontesAlocacao(
        fonte_alocacao_id: _fonteId!,
        destino_tipo: DestinoTipo.fromString(_destinoTipo!),
        destino_id: _destinoId!,
        descricao: _descricaoController.text,
        valor_alocado: valor,
        saldo_recurso: 0, // Será calculado pelo trigger
        data_alocacao: _dataAlocacao ?? DateTime.now(),
        obs: _obsController.text.isNotEmpty ? _obsController.text : null,
      );

      await context.read<FontesAlocacaoProvider>().salvarAlocacao(alocacao);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alocação realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Recarregar saldo
        await context.read<FontesAlocacaoProvider>().carregarAlocacoesPorFonte(_fonteId!);

        // Limpar campos
        _descricaoController.clear();
        _valorController.clear();
        _obsController.clear();
        _destinoId = null;
        _dataAlocacao = DateTime.now();

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fonteProvider = context.watch<FontesBaseProvider>();
    final alocacaoProvider = context.watch<FontesAlocacaoProvider>();
    final projetos = context.watch<ProjetoProvider>().projetos;

    final saldoAtual = alocacaoProvider.saldoAtual ?? 0;
    final isDisponivel = saldoAtual > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alocação de Recurso'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _salvar,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ✅ Informações da Fonte
                    if (_fonte != null) ...[
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'Entidade',
                                _fonte!.entidade,
                                Icons.business,
                              ),
                              _buildInfoRow(
                                'Descrição',
                                _fonte!.descricao,
                                Icons.description,
                              ),
                              _buildInfoRow(
                                'Valor Total',
                                _fonte!.valorRecursoFormatado,
                                Icons.attach_money,
                              ),
                              _buildInfoRow(
                                'Data de Liberação',
                                _fonte!.dataAprovacaoFormatada,
                                Icons.calendar_today,
                              ),
                              _buildInfoRow(
                                'Saldo Disponível',
                                _fonte!.saldoFormatado,
                                Icons.account_balance,
                                color: isDisponivel ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (!isDisponivel) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Saldo indisponível para alocação. '
                                'Saldo atual: R\$ 0,00',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ✅ Destino da Alocação
                    const Text(
                      'Destino da Alocação',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tipo de Destino
                    DropdownButtonFormField<String>(
                      value: _destinoTipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Destino *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: DestinoTipo.dropdownItems.map((item) {
                        return DropdownMenuItem(
                          value: item['value'] as String,
                          child: Text(item['label'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _destinoTipo = value;
                          _destinoId = null;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione o tipo de destino';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Projeto ou Rubrica
                    if (_destinoTipo == 'projeto')
                      DropdownButtonFormField<String>(
                        value: _destinoId,
                        decoration: const InputDecoration(
                          labelText: 'Projeto *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.folder_open),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Selecione um projeto'),
                          ),
                          ...projetos.map((projeto) {
                            return DropdownMenuItem(
                              value: projeto.id,
                              child: Text(projeto.descricao ?? 'Sem descrição'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _destinoId = value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione um projeto';
                          }
                          return null;
                        },
                      ),

                    const SizedBox(height: 16),

                    // ✅ Descrição
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição *',
                        hintText: 'Descreva a alocação',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Valor Alocado
                    TextFormField(
                      controller: _valorController,
                      decoration: InputDecoration(
                        labelText: 'Valor Alocado *',
                        hintText: '0,00',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: 'R\$ ',
                        helperText: 'Saldo disponível: ${_formatMoney(saldoAtual)}',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      enabled: isDisponivel,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o valor';
                        }
                        final valor = double.tryParse(value.replaceAll(',', '.'));
                        if (valor == null || valor <= 0) {
                          return 'Valor inválido';
                        }
                        if (valor > saldoAtual) {
                          return 'Valor excede o saldo disponível';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Data da Alocação
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
                          labelText: 'Data da Alocação *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dataAlocacao != null
                                    ? DateFormat('dd/MM/yyyy').format(_dataAlocacao!)
                                    : 'Selecione a data',
                              ),
                            ),
                            if (_dataAlocacao != null)
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => setState(() => _dataAlocacao = null),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Observações
                    TextFormField(
                      controller: _obsController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        hintText: 'Informações adicionais',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.comment),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // ✅ Botões
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Voltar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving || !isDisponivel ? null : _salvar,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar Alocação'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
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
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
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