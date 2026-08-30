/// ============================================
/// TELA: Formulário de Projeto (com Metas e Etapas) ⭐ REGRA 2
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/projetos/meta_card_widget.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../models/projetos/fonte_alocacao_model.dart';
import '../../models/projetos/contra_partida_model.dart';
import '../../services/projetos/fontes_base_service.dart';
import '../../services/projetos/contra_partida_service.dart';
import '../../widgets/projetos/fonte_card_widget.dart';
import '../../widgets/projetos/contra_partida_card_widget.dart';

class ProjetoFormScreen extends StatefulWidget {
  final String? projetoId;

  const ProjetoFormScreen({super.key, this.projetoId});

  @override
  State<ProjetoFormScreen> createState() => _ProjetoFormScreenState();
}

class _ProjetoFormScreenState extends State<ProjetoFormScreen> {
  // ⭐ CONTROLLERS
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _processoController = TextEditingController();
  final _dataEntregaController = TextEditingController();
  final _valorEstimadoController = TextEditingController();

  String _status = Projeto.STATUS_ORCAMENTO;
  bool _isLoading = false;

  // ⭐ METAS DO PROJETO (Regra 2)
  List<MetaModel> _metas = [];

  @override
  void initState() {
    super.initState();
    print('📋 [PROJETO_FORM] INIT - projetoId: ${widget.projetoId} | isEditing: ${widget.projetoId != null}');

    if (widget.projetoId != null) {
      _loadProjeto();
    }
  }

  @override
  void dispose() {
    print('🗑️ [PROJETO_FORM] DISPOSE - Dispondo formulário');
    _descricaoController.dispose();
    _processoController.dispose();
    _dataEntregaController.dispose();
    _valorEstimadoController.dispose();
    super.dispose();
  }

  // ============================================
  // CARREGAR PROJETO PARA EDIÇÃO
  // ============================================

  Future<void> _loadProjeto() async {
    print('📋 [PROJETO_FORM] LOAD - Carregando projeto ID: ${widget.projetoId}');

    try {
      final provider = context.read<ProjetoProvider>();
      await provider.loadProjetoCompleto(widget.projetoId!);

      final projeto = provider.selectedProjeto;
      if (projeto != null && mounted) {
        print('✅ [PROJETO_FORM] LOADED - Projeto: ${projeto.descricao}, Metas: ${projeto.metas.length}');
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
      print('❌ [PROJETO_FORM] LOAD - Erro: $e');
    }
  }

  // ============================================
  // GERENCIAR METAS (Regra 2)
  // ============================================

  void _adicionarMeta() {
    print('📋 [PROJETO_FORM] ADD_META - Adicionando nova meta');
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
    print('🗑️ [PROJETO_FORM] REMOVE_META - Removendo meta $index');
    setState(() {
      _metas.removeAt(index);
    });
  }

  void _atualizarMeta(int index, Map<String, dynamic> data) {
    print('📋 [PROJETO_FORM] UPDATE_META - Meta $index - $data');
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

  // ============================================
  // GERENCIAR ETAPAS (Regra 2)
  // ============================================

  void _adicionarEtapa(int metaIndex, EtapaModel etapa) {
    print('📋 [PROJETO_FORM] ADD_ETAPA - Meta $metaIndex - Etapa: ${etapa.descricao}');
    
    setState(() {
      final meta = _metas[metaIndex];
      final novasEtapas = List<EtapaModel>.from(meta.etapas)..add(etapa);
      _metas[metaIndex] = meta.copyWith(etapas: novasEtapas);
    });
    
    print('✅ [PROJETO_FORM] ADD_ETAPA - Meta $metaIndex agora tem ${_metas[metaIndex].etapas.length} etapas');
  }

  void _atualizarEtapa(int metaIndex, int etapaIndex, Map<String, dynamic> data) {
    print('📋 [PROJETO_FORM] UPDATE_ETAPA - Meta $metaIndex - Etapa $etapaIndex - $data');
    setState(() {
      final meta = _metas[metaIndex];
      final etapas = List<EtapaModel>.from(meta.etapas);
      final etapa = etapas[etapaIndex];

      // ⭐ REGRA 4: Calcular valor_etapa = valor_unitario * quantidade
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
    print('🗑️ [PROJETO_FORM] REMOVE_ETAPA - Meta $metaIndex - Etapa $etapaIndex');
    setState(() {
      final meta = _metas[metaIndex];
      final etapas = List<EtapaModel>.from(meta.etapas)..removeAt(etapaIndex);
      _metas[metaIndex] = meta.copyWith(etapas: etapas);
    });
  }
  // ============================================
  // SALVAR PROJETO (Regras 2, 4, 5, 6)
  // ============================================

  Future<void> _salvar() async {
    print('📋 [PROJETO_FORM] SALVAR - Iniciando salvamento | isEditing: ${widget.projetoId != null} | Metas: ${_metas.length}');

    if (!_formKey.currentState!.validate()) {
      print('⚠️ [PROJETO_FORM] SALVAR - Formulário inválido');
      return;
    }

    // ⭐ REGRA 2: Validar metas e etapas
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
      // ⭐ Montar payload com metas e etapas
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

      print('📋 [PROJETO_FORM] SALVAR - Dados: ${data.keys}');

      final provider = context.read<ProjetoProvider>();
      bool success;

      if (widget.projetoId != null) {
        // ⭐ EDIÇÃO: Usar updateCompleto
        success = await provider.updateProjetoCompleto(widget.projetoId!, data);
      } else {
        // ⭐ CRIAÇÃO: Usar createCompleto
        success = await provider.createProjetoCompleto(data);
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
      print('❌ [PROJETO_FORM] SALVAR - Erro: $e');
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

  // ============================================
  // WIDGET BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    print('📋 [PROJETO_FORM] BUILD - isEditing: ${widget.projetoId != null} | Metas: ${_metas.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projetoId != null ? 'Editar Projeto' : 'Novo Projeto'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print('⬅️ [PROJETO_FORM] VOLTAR - Voltando para lista de projetos');
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
                    // ⭐ SEÇÃO: DADOS DO PROJETO
                    _buildProjetoSection(),
                    const SizedBox(height: 16),

                    // ⭐ SEÇÃO: METAS E ETAPAS (Regra 2)
                    _buildMetasSection(),
                    const SizedBox(height: 24),
                    _buildFontesSection(),
                    const SizedBox(height: 16),
                    _buildContraPartidaSection(),
                    const SizedBox(height: 24),
                    // ⭐ SEÇÃO: BOTÕES
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================
  // SEÇÃO: DADOS DO PROJETO
  // ============================================

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

            // Descrição
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

            // Processo
            TextFormField(
              controller: _processoController,
              decoration: const InputDecoration(
                labelText: 'Processo',
                border: OutlineInputBorder(),
                helperText: 'Formato: XXXXX-XXXXXXXX/XXXX-XX',
              ),
            ),
            const SizedBox(height: 16),

            // Status + Data Entrega
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: Projeto.statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(Projeto.statusLabels[status] ?? status),
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

            // Valor Estimado
            TextFormField(
              controller: _valorEstimadoController,
              decoration: const InputDecoration(
                labelText: 'Valor Estimado (R\$)', // ⭐ ESCAPADO COM \
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

  // ============================================
  // SEÇÃO: METAS E ETAPAS (Regra 2)
  // ============================================

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
// ============================================
// SEÇÃO: FONTES DE RECURSOS (Regra 7)
// ============================================

Widget _buildFontesSection() {
  // TODO: Buscar fontes disponíveis
  // Por enquanto, mostrar um placeholder
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
                  const Icon(Icons.attach_money, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Fontes de Recursos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Abrir modal para selecionar fonte
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecionar fonte de recurso'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Vincular Fonte'),
              ),
            ],
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Nenhuma fonte vinculada ao projeto',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================
// SEÇÃO: CONTRA PARTIDA (Regra 11)
// ============================================

Widget _buildContraPartidaSection() {
  // TODO: Buscar contra partidas do projeto
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
                  const Icon(Icons.swap_horiz, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    'Contra Partida',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Abrir modal para selecionar contra partida
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecionar contra partida'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Vincular Contra Partida'),
              ),
            ],
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Nenhuma contra partida vinculada',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  // ============================================
  // SEÇÃO: BOTÕES
  // ============================================

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

  // ============================================
  // AUXILIARES
  // ============================================

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
      print('📅 [PROJETO_FORM] DATA_ENTREGA - Data selecionada: ${controller.text}');
    }
  }
}