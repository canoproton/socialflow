/// ============================================
/// TELA: Formulário de Projeto (com Metas e Etapas)
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import '../../theme/app_theme.dart';
import '../../services/debug_service.dart';
import '../../widgets/projetos/meta_card_widget.dart';

class ProjetoFormScreen extends StatefulWidget {
  final String? projetoId;

  const ProjetoFormScreen({super.key, this.projetoId});

  @override
  State<ProjetoFormScreen> createState() => _ProjetoFormScreenState();
}

class _ProjetoFormScreenState extends State<ProjetoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _processoController = TextEditingController();
  final _dataEntregaController = TextEditingController();
  final _valorEstimadoController = TextEditingController();

  String _status = ProjetoModel.STATUS_ORCAMENTO;
  bool _isLoading = false;

  // ⭐ METAS DO PROJETO
  List<MetaModel> _metas = [];

  @override
  void initState() {
    super.initState();
    DebugService.module('PROJETO FORM SCREEN');
    DebugService.log(
      module: 'PROJETO',
      action: 'INIT',
      data: 'projetoId: ${widget.projetoId} | isEditing: ${widget.projetoId != null}',
    );
    
    if (widget.projetoId != null) {
      _loadProjeto();
    }
  }

  Future<void> _loadProjeto() async {
    DebugService.log(
      module: 'PROJETO',
      action: 'LOAD',
      data: 'Carregando projeto ID: ${widget.projetoId}',
    );
    
    try {
      final provider = context.read<ProjetoProvider>();
      await provider.loadProjetoCompleto(widget.projetoId!);
      
      final projeto = provider.selectedProjeto;
      if (projeto != null && mounted) {
        DebugService.log(
          module: 'PROJETO',
          action: 'LOADED',
          data: 'Projeto: ${projeto.descricao}, Metas: ${projeto.metas.length}',
        );
        setState(() {
          _descricaoController.text = projeto.descricao ?? '';
          _processoController.text = projeto.processo ?? '';
          _dataEntregaController.text = projeto.dataEntrega?.toIso8601String().split('T').first ?? '';
          _valorEstimadoController.text = projeto.valorEstimado?.toString() ?? '';
          _status = projeto.statusProjeto;
          _metas = List.from(projeto.metas);
        });
      }
    } catch (e) {
      DebugService.log(
        module: 'PROJETO',
        action: 'LOAD',
        error: e.toString(),
        isError: true,
      );
    }
  }

  // ⭐ MÉTODOS PARA GERENCIAR METAS
  void _adicionarMeta() {
    DebugService.log(
      module: 'PROJETO',
      action: 'ADD_META',
      data: 'Adicionando nova meta',
    );
    setState(() {
      _metas.add(MetaModel(
        id: '',
        projetoId: widget.projetoId ?? '',
        descricao: '',
        etapas: [],
      ));
    });
  }

  void _removerMeta(int index) {
    DebugService.log(
      module: 'PROJETO',
      action: 'REMOVE_META',
      data: 'Removendo meta $index',
    );
    setState(() {
      _metas.removeAt(index);
    });
  }

  void _atualizarMeta(int index, Map<String, dynamic> data) {
    DebugService.log(
      module: 'PROJETO',
      action: 'UPDATE_META',
      data: 'Meta $index - $data',
    );
    setState(() {
      final meta = _metas[index];
      _metas[index] = MetaModel(
        id: meta.id,
        projetoId: meta.projetoId,
        sequencia: meta.sequencia,
        descricao: data['descricao'] ?? meta.descricao,
        indicador: data['indicador'] ?? meta.indicador,
        unidade: data['unidade'] ?? meta.unidade,
        quantifiq: data['quantifiq'] ?? meta.quantifiq,
        publicoAlvo: data['publicoAlvo'] ?? meta.publicoAlvo,
        local: data['local'] ?? meta.local,
        prova: data['prova'] ?? meta.prova,
        vlMetaAprov: data['vlMetaAprov'] ?? meta.vlMetaAprov,
        valorTotalEtapas: meta.valorTotalEtapas,
        saldoMeta: meta.saldoMeta,
        supervisorId: meta.supervisorId,
        docsMetas: meta.docsMetas,
        obs: data['obs'] ?? meta.obs,
        atualizadoPor: meta.atualizadoPor,
        atualizadoEm: meta.atualizadoEm,
        createdAt: meta.createdAt,
        updatedAt: meta.updatedAt,
        etapas: meta.etapas,
      );
    });
  }

  void _adicionarEtapa(int metaIndex, EtapaModel etapa) {
    DebugService.log(
      module: 'PROJETO',
      action: 'ADD_ETAPA',
      data: 'Meta $metaIndex - Etapa: ${etapa.descricao}',
    );
    setState(() {
      final meta = _metas[metaIndex];
      final novasEtapas = List<EtapaModel>.from(meta.etapas)..add(etapa);
      _metas[metaIndex] = meta.copyWith(etapas: novasEtapas);
    });
  }

  void _atualizarEtapa(int metaIndex, int etapaIndex, Map<String, dynamic> data) {
    DebugService.log(
      module: 'PROJETO',
      action: 'UPDATE_ETAPA',
      data: 'Meta $metaIndex - Etapa $etapaIndex - $data',
    );
    setState(() {
      final meta = _metas[metaIndex];
      final etapas = List<EtapaModel>.from(meta.etapas);
      final etapa = etapas[etapaIndex];
      
      // ⭐ CALCULAR VALOR_ETAPA (Regra 4)
      final valorUnitario = data['valorUnitario'] ?? etapa.valorUnitario ?? 0;
      final quantidade = data['quantidade'] ?? etapa.quantidade ?? 0;
      final valorEtapa = (valorUnitario as double) * (quantidade as double);
      
      etapas[etapaIndex] = etapa.copyWith(
        descricao: data['descricao'] ?? etapa.descricao,
        valorUnitario: data['valorUnitario'] ?? etapa.valorUnitario,
        quantidade: data['quantidade'] ?? etapa.quantidade,
        valorEtapa: valorEtapa,
        status: data['status'] ?? etapa.status,
        obs: data['obs'] ?? etapa.obs,
      );
      _metas[metaIndex] = meta.copyWith(etapas: etapas);
    });
  }

  void _removerEtapa(int metaIndex, int etapaIndex) {
    DebugService.log(
      module: 'PROJETO',
      action: 'REMOVE_ETAPA',
      data: 'Meta $metaIndex - Etapa $etapaIndex',
    );
    setState(() {
      final meta = _metas[metaIndex];
      final etapas = List<EtapaModel>.from(meta.etapas)..removeAt(etapaIndex);
      _metas[metaIndex] = meta.copyWith(etapas: etapas);
    });
  }

  // ⭐ SALVAR PROJETO COMPLETO
  Future<void> _salvar() async {
    DebugService.log(
      module: 'PROJETO',
      action: 'SALVAR',
      data: 'Iniciando salvamento | isEditing: ${widget.projetoId != null} | Metas: ${_metas.length}',
    );
    
    if (!_formKey.currentState!.validate()) {
      DebugService.log(
        module: 'PROJETO',
        action: 'SALVAR',
        data: 'Formulário inválido',
        isWarning: true,
      );
      return;
    }

    // ⭐ VALIDAR METAS E ETAPAS
    if (_metas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos uma meta ao projeto!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    for (var meta in _metas) {
      if (meta.etapas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A meta "${meta.descricao}" não tem etapas!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'descricao': _descricaoController.text,
        'processo': _processoController.text.isNotEmpty ? _processoController.text : null,
        'status_projeto': _status,
        'data_entrega': _dataEntregaController.text.isNotEmpty 
            ? DateTime.parse(_dataEntregaController.text).toIso8601String()
            : null,
        'valor_estimado': double.tryParse(_valorEstimadoController.text),
        'metas': _metas.map((meta) => {
          'descricao': meta.descricao,
          'indicador': meta.indicador,
          'unidade': meta.unidade,
          'quantifiq': meta.quantifiq,
          'publico': meta.publicoAlvo,
          'local': meta.local,
          'prova': meta.prova,
          'vl_meta_aprov': meta.vlMetaAprov,
          'obs': meta.obs,
          'etapas': meta.etapas.map((etapa) => {
            'descricao': etapa.descricao,
            'valor_unitario': etapa.valorUnitario,
            'quantidade': etapa.quantidade,
            'status': etapa.status,
            'obs': etapa.obs,
          }).toList(),
        }).toList(),
      };

      DebugService.log(
        module: 'PROJETO',
        action: 'SALVAR',
        data: 'Dados: $data',
      );

      final provider = context.read<ProjetoProvider>();
      bool success;

      if (widget.projetoId != null) {
        success = await provider.updateProjeto(widget.projetoId!, data);
      } else {
        success = await provider.createProjeto(data);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.projetoId != null ? 'Projeto atualizado!' : 'Projeto criado!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/projetos');
      }
    } catch (e) {
      DebugService.log(
        module: 'PROJETO',
        action: 'SALVAR',
        error: e.toString(),
        isError: true,
      );
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
    DebugService.log(
      module: 'PROJETO',
      action: 'BUILD',
      data: 'isEditing: ${widget.projetoId != null} | Metas: ${_metas.length}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projetoId != null ? 'Editar Projeto' : 'Novo Projeto'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            DebugService.log(
              module: 'PROJETO',
              action: 'VOLTAR',
              data: 'Voltando para lista de projetos',
            );
            context.go('/projetos');
          },
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _salvar,
            tooltip: 'Salvar',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ DADOS DO PROJETO
                    _buildProjetoSection(),
                    const SizedBox(height: 16),

                    // ⭐ METAS DO PROJETO
                    _buildMetasSection(),
                    const SizedBox(height: 24),

                    // ⭐ BOTÕES
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProjetoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Dados do Projeto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Descrição é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _processoController,
              decoration: const InputDecoration(
                labelText: 'Processo',
                border: OutlineInputBorder(),
                helperText: 'Formato: XXXXX-XXXXXXXX/XXXX-XX',
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ProjetoModel.statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(ProjetoModel.statusLabels[status] ?? status),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dataEntregaController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Entrega',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _dataEntregaController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _valorEstimadoController,
              decoration: const InputDecoration(
                labelText: 'Valor Estimado (R$)',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetasSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.checklist, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Metas do Projeto (${_metas.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _adicionarMeta,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Meta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            if (_metas.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Adicione uma meta para começar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._metas.asMap().entries.map((entry) {
                final index = entry.key;
                final meta = entry.value;
                return MetaCardWidget(
                  meta: meta,
                  index: index,
                  onUpdate: _atualizarMeta,
                  onRemove: _removerMeta,
                  onAddEtapa: _adicionarEtapa,
                  onUpdateEtapa: _atualizarEtapa,
                  onRemoveEtapa: _removerEtapa,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => context.go('/projetos'),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(_isLoading ? 'Salvando...' : 'Salvar'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }
}