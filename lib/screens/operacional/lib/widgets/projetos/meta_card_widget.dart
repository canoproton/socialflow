/// ============================================
/// WIDGET: Card de Meta (para formulário)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/meta_model.dart';
import '../../theme/app_theme.dart';

class MetaCardWidget extends StatefulWidget {
  final Map<String, dynamic> meta;
  final int index;
  final Function(int, Map<String, dynamic>) onUpdate;
  final Function(int) onRemove;
  final Function(int) onAddEtapa;
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
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _indicadorController = TextEditingController();
  final TextEditingController _unidadeController = TextEditingController();
  final TextEditingController _quantifiqController = TextEditingController();
  final TextEditingController _publicoController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _provaController = TextEditingController();
  final TextEditingController _vlMetaAprovController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descricaoController.text = widget.meta['descricao'] ?? '';
    _indicadorController.text = widget.meta['indicador'] ?? '';
    _unidadeController.text = widget.meta['unidade'] ?? '';
    _quantifiqController.text = widget.meta['quantifiq'] ?? '';
    _publicoController.text = widget.meta['publicoAlvo'] ?? '';
    _localController.text = widget.meta['local'] ?? '';
    _provaController.text = widget.meta['prova'] ?? '';
    _vlMetaAprovController.text = widget.meta['vlMetaAprov']?.toString() ?? '';
    _obsController.text = widget.meta['obs'] ?? '';

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
    widget.onUpdate(widget.index, {field: value});
  }

  @override
  Widget build(BuildContext context) {
    final etapas = widget.meta['etapas'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  onPressed: () => widget.onRemove(widget.index),
                  tooltip: 'Remover Meta',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Campos em linha
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
                      labelText: 'Valor Aprovado (R$)',
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

            // Etapas
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.task, size: 20, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Etapas (${etapas.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => widget.onAddEtapa(widget.index),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Etapa'),
                ),
              ],
            ),

            if (etapas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Nenhuma etapa cadastrada',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )
            else
              ...etapas.asMap().entries.map((entry) {
                final etapaIndex = entry.key;
                final etapa = entry.value;
                return _buildEtapaCard(etapaIndex, etapa);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildEtapaCard(int etapaIndex, Map<String, dynamic> etapa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: etapa['descricao'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Descrição da Etapa *',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) => widget.onUpdateEtapa(
                      widget.index,
                      etapaIndex,
                      {'descricao': value},
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => widget.onRemoveEtapa(widget.index, etapaIndex),
                  tooltip: 'Remover Etapa',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Campos
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: etapa['valorUnitario']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Valor Unitário (R$)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => widget.onUpdateEtapa(
                      widget.index,
                      etapaIndex,
                      {'valorUnitario': double.tryParse(value) ?? 0.0},
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextFormField(
                    initialValue: etapa['quantidade']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => widget.onUpdateEtapa(
                      widget.index,
                      etapaIndex,
                      {'quantidade': double.tryParse(value) ?? 0.0},
                    ),
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
                          'R\$ ${((etapa['valorUnitario'] ?? 0.0) * (etapa['quantidade'] ?? 0.0)).toStringAsFixed(2)}',
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

            // Status e Observações
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: etapa['status'] ?? 'PLANEJADA',
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PLANEJADA', child: Text('Planejada')),
                      DropdownMenuItem(value: 'ACIONADO', child: Text('Acionado')),
                      DropdownMenuItem(value: 'EXECUÇÃO', child: Text('Execução')),
                      DropdownMenuItem(value: 'PENDENTE', child: Text('Pendente')),
                      DropdownMenuItem(value: 'CONCLUIDA', child: Text('Concluída')),
                      DropdownMenuItem(value: 'CANCELADA', child: Text('Cancelada')),
                    ],
                    onChanged: (value) => widget.onUpdateEtapa(
                      widget.index,
                      etapaIndex,
                      {'status': value},
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextFormField(
                    initialValue: etapa['obs'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) => widget.onUpdateEtapa(
                      widget.index,
                      etapaIndex,
                      {'obs': value},
                    ),
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