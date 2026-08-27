/// ============================================
/// WIDGET: Card de Meta (para o formulário)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import '../../theme/app_theme.dart';

class MetaCardWidget extends StatefulWidget {
  final MetaModel meta;
  final int index;
  final Function(int, Map<String, dynamic>) onUpdate;
  final Function(int) onRemove;
  final Function(int, EtapaModel) onAddEtapa;
  final Function(int, int, Map<String, dynamic>) onUpdateEtapa;
  final Function(int, int) onRemoveEtapa;

  const MetaCardWidget({
    super.key,
    required this.meta,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
    required this.onAddEtapa,
    required this.onUpdateEtapa,
    required this.onRemoveEtapa,
  });

  @override
  State<MetaCardWidget> createState() => _MetaCardWidgetState();
}

class _MetaCardWidgetState extends State<MetaCardWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _indicadorController = TextEditingController();
  final _unidadeController = TextEditingController();
  final _quantifiqController = TextEditingController();
  final _publicoController = TextEditingController();
  final _localController = TextEditingController();
  final _provaController = TextEditingController();
  final _vlMetaAprovController = TextEditingController();
  final _obsController = TextEditingController();

  // ⭐ ETAPAS DA META
  List<EtapaModel> _etapas = [];

  @override
  void initState() {
    super.initState();
    _etapas = List.from(widget.meta.etapas);
    _descricaoController.text = widget.meta.descricao ?? '';
    _indicadorController.text = widget.meta.indicador ?? '';
    _unidadeController.text = widget.meta.unidade ?? '';
    _quantifiqController.text = widget.meta.quantifiq ?? '';
    _publicoController.text = widget.meta.publicoAlvo ?? '';
    _localController.text = widget.meta.local ?? '';
    _provaController.text = widget.meta.prova ?? '';
    _vlMetaAprovController.text = widget.meta.vlMetaAprov?.toString() ?? '';
    _obsController.text = widget.meta.obs ?? '';

    _descricaoController.addListener(() => _onUpdate('descricao', _descricaoController.text));
    _indicadorController.addListener(() => _onUpdate('indicador', _indicadorController.text));
    _unidadeController.addListener(() => _onUpdate('unidade', _unidadeController.text));
    _quantifiqController.addListener(() => _onUpdate('quantifiq', _quantifiqController.text));
    _publicoController.addListener(() => _onUpdate('publicoAlvo', _publicoController.text));
    _localController.addListener(() => _onUpdate('local', _localController.text));
    _provaController.addListener(() => _onUpdate('prova', _provaController.text));
    _vlMetaAprovController.addListener(() => _onUpdate('vlMetaAprov', double.tryParse(_vlMetaAprovController.text) ?? 0.0));
    _obsController.addListener(() => _onUpdate('obs', _obsController.text));
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _indicadorController.dispose();
    _unidadeController.dispose();
    _quantifiqController.dispose();
    _publicoController.dispose();
    _localController.dispose();
    _provaController.dispose();
    _vlMetaAprovController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _onUpdate(String field, dynamic value) {
    print('📋 [META_CARD] UPDATE - Meta ${widget.index + 1} - $field: $value');
    widget.onUpdate(widget.index, {field: value});
  }

  // ⭐ CORRIGIDO: Adicionar etapa com ID temporário
  void _adicionarEtapa() {
    print('📋 [META_CARD] ADD_ETAPA - Meta ${widget.index + 1}');
    
    final novaEtapa = EtapaModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      metaId: widget.meta.id,
      descricao: '',
      status: EtapaModel.STATUS_PLANEJADA,
      valorUnitario: 0,
      quantidade: 0,
      valorEtapa: 0,
    );
    
    print('✅ [META_CARD] ADD_ETAPA - Etapa criada: ${novaEtapa.id}');
    widget.onAddEtapa(widget.index, novaEtapa);
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ ATUALIZAR A LISTA DE ETAPAS QUANDO O WIDGET RECONSTRUIR
    _etapas = List.from(widget.meta.etapas);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ HEADER DA META
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição da Meta *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Descrição é obrigatória';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      print('🗑️ [META_CARD] REMOVE - Meta ${widget.index + 1}');
                      widget.onRemove(widget.index);
                    },
                    tooltip: 'Remover Meta',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ⭐ CAMPOS DA META
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _indicadorController,
                      decoration: const InputDecoration(
                        labelText: 'Indicador',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _unidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantifiqController,
                      decoration: const InputDecoration(
                        labelText: 'Quantificação',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _publicoController,
                      decoration: const InputDecoration(
                        labelText: 'Público-alvo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _localController,
                      decoration: const InputDecoration(
                        labelText: 'Local',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _provaController,
                      decoration: const InputDecoration(
                        labelText: 'Prova',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _vlMetaAprovController,
                      decoration: const InputDecoration(
                        labelText: 'Valor Aprovado (R\$)',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _obsController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              // ⭐ ETAPAS DA META
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.task, size: 20, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'Etapas (${_etapas.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _adicionarEtapa,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar Etapa'),
                  ),
                ],
              ),

              // ⭐ LISTA DE ETAPAS
              if (_etapas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Nenhuma etapa cadastrada',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              else
                ..._etapas.asMap().entries.map((entry) {
                  final etapaIndex = entry.key;
                  final etapa = entry.value;
                  return _buildEtapaCard(etapaIndex, etapa);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEtapaCard(int etapaIndex, EtapaModel etapa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da Etapa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: etapa.descricao ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Descrição da Etapa *',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) {
                      widget.onUpdateEtapa(
                        widget.index,
                        etapaIndex,
                        {'descricao': value},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    print('🗑️ [META_CARD] REMOVE_ETAPA - Meta ${widget.index + 1} - Etapa $etapaIndex');
                    widget.onRemoveEtapa(widget.index, etapaIndex);
                  },
                  tooltip: 'Remover Etapa',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Campos da Etapa
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: etapa.valorUnitario?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Valor Unitário (R\$)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final valorUnitario = double.tryParse(value) ?? 0.0;
                      widget.onUpdateEtapa(
                        widget.index,
                        etapaIndex,
                        {'valorUnitario': valorUnitario},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextFormField(
                    initialValue: etapa.quantidade?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantidade = double.tryParse(value) ?? 0.0;
                      widget.onUpdateEtapa(
                        widget.index,
                        etapaIndex,
                        {'quantidade': quantidade},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valor Calculado',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          'R\$ ${(etapa.valorUnitario ?? 0) * (etapa.quantidade ?? 0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Status da Etapa
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: etapa.status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    items: EtapaModel.statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(EtapaModel.statusLabels[status] ?? status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      widget.onUpdateEtapa(
                        widget.index,
                        etapaIndex,
                        {'status': value},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextFormField(
                    initialValue: etapa.obs ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) {
                      widget.onUpdateEtapa(
                        widget.index,
                        etapaIndex,
                        {'obs': value},
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}