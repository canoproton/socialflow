/// ============================================
/// TELA: Formulário Unificado do Projeto
/// (Projeto + Metas + Etapas na mesma tela)
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/projetos/validators.dart';
import '../../utils/projetos/constants.dart';
import '../../widgets/projetos/meta_card_widget.dart';

class ProjetoFormScreen extends StatefulWidget {
  final String? projetoId;

  const ProjetoFormScreen({super.key, this.projetoId});

  @override
  State<ProjetoFormScreen> createState() => _ProjetoFormScreenState();
}

class _ProjetoFormScreenState extends State<ProjetoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _descricaoController = TextEditingController();
  final _processoController = TextEditingController();
  final _proponenteController = TextEditingController();
  final _contaController = TextEditingController();
  final _valorEstimadoController = TextEditingController();
  final _valorAprovadoController = TextEditingController();
  final _dataEntregaController = TextEditingController();
  final _dataAprovacaoController = TextEditingController();
  final _obsController = TextEditingController();

  String _statusProjeto = ProjetoModel.STATUS_ORCAMENTO;
  bool _isEditing = false;
  bool _isLoading = false;

  // Listas de Metas e Etapas (gerenciadas localmente)
  List<Map<String, dynamic>> _metas = [];
  int _nextMetaId = -1;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.projetoId != null;
    if (_isEditing) {
      _loadProjetoData();
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _processoController.dispose();
    _proponenteController.dispose();
    _contaController.dispose();
    _valorEstimadoController.dispose();
    _valorAprovadoController.dispose();
    _dataEntregaController.dispose();
    _dataAprovacaoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _loadProjetoData() async {
    setState(() => _isLoading = true);
    final provider = context.read<ProjetoProvider>();
    await provider.loadProjetoCompleto(widget.projetoId!);

    final projeto = provider.selectedProjeto;
    if (projeto != null && mounted) {
      setState(() {
        _descricaoController.text = projeto.descricao ?? '';
        _processoController.text = projeto.processo ?? '';
        _proponenteController.text = projeto.proponenteId ?? '';
        _contaController.text = projeto.contaId ?? '';
        _valorEstimadoController.text = projeto.valorEstimado?.toString() ?? '';
        _valorAprovadoController.text = projeto.valorAprovado?.toString() ?? '';
        _dataEntregaController.text = projeto.dataEntrega?.toIso8601String().split('T').first ?? '';
        _dataAprovacaoController.text = projeto.dataAprovacao?.toIso8601String().split('T').first ?? '';
        _obsController.text = projeto.obs ?? '';
        _statusProjeto = projeto.statusProjeto;
        
        // Carregar metas e etapas
        _metas = projeto.metas.map((meta) => {
          'id': meta.id,
          'tempId': meta.id,
          'descricao': meta.descricao,
          'indicador': meta.indicador,
          'unidade': meta.unidade,
          'quantifiq': meta.quantifiq,
          'publicoAlvo': meta.publicoAlvo,
          'local': meta.local,
          'prova': meta.prova,
          'vlMetaAprov': meta.vlMetaAprov,
          'supervisorId': meta.supervisorId,
          'obs': meta.obs,
          'etapas': meta.etapas.map((etapa) => {
            'id': etapa.id,
            'tempId': etapa.id,
            'descricao': etapa.descricao,
            'rubricaId': etapa.rubricaId,
            'executorId': etapa.executorId,
            'areaId': etapa.areaId,
            'unidadeEtapaId': etapa.unidadeEtapaId,
            'dataInicio': etapa.dataInicio?.toIso8601String().split('T').first,
            'dataVencimento': etapa.dataVencimento?.toIso8601String().split('T').first,
            'valorUnitario': etapa.valorUnitario,
            'unidadePgtoId': etapa.unidadePgtoId,
            'quantidade': etapa.quantidade,
            'valorEtapa': etapa.valorEtapa,
            'status': etapa.status,
            'obs': etapa.obs,
          }).toList(),
        }).toList();
        
        _isLoading = false;
      });
    }
  }

  // ============================================
  // GERENCIAMENTO DE METAS
  // ============================================

  void _adicionarMeta() {
    setState(() {
      _metas.add({
        'id': null,
        'tempId': _nextMetaId--,
        'descricao': '',
        'indicador': '',
        'unidade': '',
        'quantifiq': '',
        'publicoAlvo': '',
        'local': '',
        'prova': '',
        'vlMetaAprov': 0.0,
        'supervisorId': '',
        'obs': '',
        'etapas': [],
      });
    });
  }

  void _removerMeta(int index) {
    setState(() {
      _metas.removeAt(index);
    });
  }

  void _atualizarMeta(int index, Map<String, dynamic> data) {
    setState(() {
      _metas[index] = {..._metas[index], ...data};
    });
  }

  // ============================================
  // GERENCIAMENTO DE ETAPAS (dentro de uma meta)
  // ============================================

  void _adicionarEtapa(int metaIndex) {
    setState(() {
      final etapas = List<Map<String, dynamic>>.from(_metas[metaIndex]['etapas'] ?? []);
      etapas.add({
        'id': null,
        'tempId': _nextMetaId--,
        'descricao': '',
        'rubricaId': '',
        'executorId': '',
        'areaId': '',
        'unidadeEtapaId': '',
        'dataInicio': '',
        'dataVencimento': '',
        'valorUnitario': 0.0,
        'unidadePgtoId': '',
        'quantidade': 0.0,
        'valorEtapa': 0.0,
        'status': EtapaModel.STATUS_PLANEJADA,
        'obs': '',
      });
      _metas[metaIndex]['etapas'] = etapas;
    });
  }

  void _removerEtapa(int metaIndex, int etapaIndex) {
    setState(() {
      final etapas = List<Map<String, dynamic>>.from(_metas[metaIndex]['etapas'] ?? []);
      etapas.removeAt(etapaIndex);
      _metas[metaIndex]['etapas'] = etapas;
    });
  }

  void _atualizarEtapa(int metaIndex, int etapaIndex, Map<String, dynamic> data) {
    setState(() {
      final etapas = List<Map<String, dynamic>>.from(_metas[metaIndex]['etapas'] ?? []);
      etapas[etapaIndex] = {...etapas[etapaIndex], ...data};
      
      // Recalcular valor_etapa (Regra 4)
      final valorUnitario = etapas[etapaIndex]['valorUnitario'] ?? 0.0;
      final quantidade = etapas[etapaIndex]['quantidade'] ?? 0.0;
      etapas[etapaIndex]['valorEtapa'] = valorUnitario * quantidade;
      
      _metas[metaIndex]['etapas'] = etapas;
    });
  }

  // ============================================
  // SUBMISSÃO
  // ============================================

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Montar payload
      final payload = {
        'descricao': _descricaoController.text,
        'processo': _processoController.text.isNotEmpty ? _processoController.text : null,
        'proponente': _proponenteController.text.isNotEmpty ? _proponenteController.text : null,
        'conta': _contaController.text.isNotEmpty ? _contaController.text : null,
        'valor_estimado': double.tryParse(_valorEstimadoController.text),
        'valor_aprovado': double.tryParse(_valorAprovadoController.text),
        'data_entrega': _dataEntregaController.text.isNotEmpty 
            ? DateTime.parse(_dataEntregaController.text).toIso8601String()
            : null,
        'data_aprovacao': _dataAprovacaoController.text.isNotEmpty
            ? DateTime.parse(_dataAprovacaoController.text).toIso8601String()
            : null,
        'status_projeto': _statusProjeto,
        'obs': _obsController.text.isNotEmpty ? _obsController.text : null,
        'metas': _metas.map((meta) {
          return {
            'id': meta['id'],
            'descricao': meta['descricao'],
            'indicador': meta['indicador'],
            'unidade': meta['unidade'],
            'quantifiq': meta['quantifiq'],
            'publico': meta['publicoAlvo'],
            'local': meta['local'],
            'prova': meta['prova'],
            'vl_meta_aprov': meta['vlMetaAprov'],
            'supervisor': meta['supervisorId'],
            'obs': meta['obs'],
            'etapas': (meta['etapas'] as List).map((etapa) {
              return {
                'id': etapa['id'],
                'descricao': etapa['descricao'],
                'rubrica': etapa['rubricaId'],
                'executor': etapa['executorId'],
                'area': etapa['areaId'],
                'unidade_etapa': etapa['unidadeEtapaId'],
                'data_inicio': etapa['dataInicio'],
                'data_vencimento': etapa['dataVencimento'],
                'valor_unitario': etapa['valorUnitario'],
                'unidade_pgto': etapa['unidadePgtoId'],
                'quantidade': etapa['quantidade'],
                'status': etapa['status'],
                'obs': etapa['obs'],
              };
            }).toList(),
          };
        }).toList(),
      };

      final provider = context.read<ProjetoProvider>();
      bool success;

      if (_isEditing) {
        success = await provider.updateProjeto(widget.projetoId!, payload);
      } else {
        success = await provider.createProjeto(payload);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Projeto atualizado com sucesso!' : 'Projeto criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/projetos');
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

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Projeto' : 'Novo Projeto'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
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
                    // Dados do Projeto
                    _buildProjetoSection(),
                    const SizedBox(height: 24),
                    
                    // Metas
                    _buildMetasSection(),
                    const SizedBox(height: 24),
                    
                    // Botões de Ação
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================
  // SEÇÕES DO FORMULÁRIO
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
                labelText: 'Descrição do Projeto *',
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
            
            // Processo (com validação)
            TextFormField(
              controller: _processoController,
              decoration: const InputDecoration(
                labelText: 'Processo',
                border: OutlineInputBorder(),
                helperText: 'Formato: XXXXX-XXXXXXXX/XXXX-XX (ex: 00150-00003771/2019-44)',
              ),
              validator: ProjetoValidators.validarProcesso,
            ),
            const SizedBox(height: 16),
            
            // Proponente e Conta (linha)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proponenteController,
                    decoration: const InputDecoration(
                      labelText: 'ID do Proponente',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _contaController,
                    decoration: const InputDecoration(
                      labelText: 'ID da Conta',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Valores (linha)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valorEstimadoController,
                    decoration: const InputDecoration(
                      labelText: 'Valor Estimado (R$)',
                      border: OutlineInputBorder(),
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _valorAprovadoController,
                    decoration: const InputDecoration(
                      labelText: 'Valor Aprovado (R$)',
                      border: OutlineInputBorder(),
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Datas (linha)
            Row(
              children: [
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
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dataAprovacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Aprovação',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _dataAprovacaoController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status
            DropdownButtonFormField<String>(
              value: _statusProjeto,
              decoration: const InputDecoration(
                labelText: 'Status do Projeto',
                border: OutlineInputBorder(),
              ),
              items: ProjetoModel.statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(ProjetoModel.statusLabels[status] ?? status),
                );
              }).toList(),
              onChanged: (value) => setState(() => _statusProjeto = value!),
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
                    const Text(
                      'Metas do Projeto',
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
                    'Nenhuma meta cadastrada. Clique em "Adicionar Meta" para começar.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._metas.asMap().entries.map((entry) {
                final index = entry.key;
                final meta = entry.value;
                return _buildMetaCard(index, meta);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard(int index, Map<String, dynamic> meta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da Meta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: meta['descricao'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Descrição da Meta *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _atualizarMeta(index, {'descricao': value}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removerMeta(index),
                  tooltip: 'Remover Meta',
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Campos da Meta (linha)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: meta['indicador'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Indicador',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _atualizarMeta(index, {'indicador': value}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: meta['unidade'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _atualizarMeta(index, {'unidade': value}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: meta['quantifiq'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Quantificação',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _atualizarMeta(index, {'quantifiq': value}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: meta['publicoAlvo'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Público-alvo',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _atualizarMeta(index, {'publicoAlvo': value}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: meta['local'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Local',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _atualizarMeta(index, {'local': value}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: meta['prova'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Prova',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _atualizarMeta(index, {'prova': value}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: meta['vlMetaAprov']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Valor Aprovado (R$)',
                      border: OutlineInputBorder(),
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _atualizarMeta(
                      index, 
                      {'vlMetaAprov': double.tryParse(value) ?? 0.0}
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: meta['obs'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _atualizarMeta(index, {'obs': value}),
                  ),
                ),
              ],
            ),
            
            // Etapas da Meta
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.task, size: 20, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Etapas (${(meta['etapas'] as List).length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _adicionarEtapa(index),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Etapa'),
                ),
              ],
            ),
            
            if ((meta['etapas'] as List).isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Nenhuma etapa cadastrada',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )
            else
              ...(meta['etapas'] as List).asMap().entries.map((etapaEntry) {
                final etapaIndex = etapaEntry.key;
                final etapa = etapaEntry.value;
                return _buildEtapaCard(index, etapaIndex, etapa);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildEtapaCard(int metaIndex, int etapaIndex, Map<String, dynamic> etapa) {
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
                    initialValue: etapa['descricao'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Descrição da Etapa *',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) => _atualizarEtapa(
                      metaIndex, 
                      etapaIndex, 
                      {'descricao': value}
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removerEtapa(metaIndex, etapaIndex),
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
                    initialValue: etapa['valorUnitario']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Valor Unitário (R$)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _atualizarEtapa(
                      metaIndex,
                      etapaIndex,
                      {'valorUnitario': double.tryParse(value) ?? 0.0}
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
                    onChanged: (value) => _atualizarEtapa(
                      metaIndex,
                      etapaIndex,
                      {'quantidade': double.tryParse(value) ?? 0.0}
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
            
            // Status da Etapa
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: etapa['status'] ?? EtapaModel.STATUS_PLANEJADA,
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
                    onChanged: (value) => _atualizarEtapa(
                      metaIndex,
                      etapaIndex,
                      {'status': value}
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
                    onChanged: (value) => _atualizarEtapa(
                      metaIndex,
                      etapaIndex,
                      {'obs': value}
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
          child: Text(_isLoading ? 'Salvando...' : 'Salvar Projeto'),
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
    }
  }
}