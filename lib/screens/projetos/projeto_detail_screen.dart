import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../providers/projetos/contra_partida_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/contra_partida_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import '../../widgets/projetos/meta_card_widget.dart';
import '../../widgets/projetos/contra_partida_card_widget.dart';
import 'contra_partida_list_screen.dart';
import 'projeto_form_screen.dart';

class ProjetoDetailScreen extends StatefulWidget {
  final String projetoId;

  const ProjetoDetailScreen({Key? key, required this.projetoId})
      : super(key: key);

  @override
  State<ProjetoDetailScreen> createState() => _ProjetoDetailScreenState();
}

class _ProjetoDetailScreenState extends State<ProjetoDetailScreen> {
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      await context.read<ProjetoProvider>().carregarProjeto(widget.projetoId);
      await context.read<ContraPartidaProvider>().carregarContraPartidas(widget.projetoId);
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projetoProvider = context.watch<ProjetoProvider>();
    final contraPartidaProvider = context.watch<ContraPartidaProvider>();

    final projeto = projetoProvider.projetoSelecionado;
    final contraPartidas = contraPartidaProvider.contraPartidas;

    return Scaffold(
      appBar: AppBar(
        title: Text(projeto?.descricao ?? 'Detalhe do Projeto'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (projeto?.id != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjetoFormScreen(
                      projetoId: projeto!.id,
                    ),
                  ),
                ).then((_) => _carregarDados());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar projeto',
                        style: TextStyle(fontSize: 18, color: Colors.red[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _erro!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _carregarDados,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : projeto == null
                  ? const Center(
                      child: Text('Projeto não encontrado'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Informações Gerais
                          _buildInfoSection(projeto),

                          const SizedBox(height: 24),

                          // ✅ Resumo Financeiro
                          _buildResumoFinanceiro(projeto),

                          const SizedBox(height: 24),

                          // ✅ Metas
                          _buildMetasSection(projeto),

                          const SizedBox(height: 24),

                          // ✅ Contra Partidas
                          _buildContraPartidasSection(contraPartidas),

                          const SizedBox(height: 24),

                          // ✅ Documentos (placeholder)
                          _buildDocumentosSection(),
                        ],
                      ),
                    ),
    );
  }

  // ============================================================
  // ✅ Seção: Informações Gerais
  // ============================================================
  Widget _buildInfoSection(ProjetoModel projeto) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(projeto.status_projeto),
                  child: Text(
                    _getStatusInitial(projeto.status_projeto),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projeto.descricao,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Processo: ${projeto.processo ?? 'Não informado'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  'Status',
                  projeto.status_projeto ?? 'ORCAMENTO',
                  _getStatusColor(projeto.status_projeto),
                ),
                _buildInfoChip(
                  'Data de Entrega',
                  projeto.dataEntregaFormatada ?? 'Não definida',
                  Colors.blue,
                ),
                _buildInfoChip(
                  'Valor Estimado',
                  projeto.valorEstimadoFormatado,
                  Colors.green,
                ),
                _buildInfoChip(
                  'Valor Aprovado',
                  projeto.valorAprovadoFormatado,
                  Colors.orange,
                ),
              ],
            ),
            if (projeto.obs != null && projeto.obs!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Observações',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                projeto.obs!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ✅ Seção: Resumo Financeiro
  // ============================================================
  Widget _buildResumoFinanceiro(ProjetoModel projeto) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo Financeiro',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceiroItem(
                    'Valor Estimado',
                    projeto.valorEstimadoFormatado,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildFinanceiroItem(
                    'Valor Aprovado',
                    projeto.valorAprovadoFormatado,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildFinanceiroItem(
                    'Saldo',
                    projeto.saldoFormatado,
                    projeto.saldoProjeto >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceiroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ✅ Seção: Metas
  // ============================================================
  Widget _buildMetasSection(ProjetoModel projeto) {
    final metas = projeto.metas ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Metas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${metas.length} metas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (metas.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhuma meta cadastrada',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: metas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final meta = metas[index];
                  return MetaCardWidget(meta: meta);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ✅ Seção: Contra Partidas
  // ============================================================
  Widget _buildContraPartidasSection(List<ContraPartidaModel> contraPartidas) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contra Partidas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${contraPartidas.length} registros',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContraPartidaListScreen(),
                          ),
                        );
                      },
                      tooltip: 'Adicionar Contra Partida',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (contraPartidas.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhuma contra partida cadastrada',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contraPartidas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cp = contraPartidas[index];
                  return ContraPartidaCardWidget(contraPartida: cp);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ✅ Seção: Documentos (Placeholder)
  // ============================================================
  Widget _buildDocumentosSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Documentos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file, color: Colors.blue),
                  onPressed: () {
                    // TODO: Implementar upload de documentos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade em desenvolvimento'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Nenhum documento anexado',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ✅ Widgets Auxiliares
  // ============================================================
  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
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

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ORCAMENTO':
        return Colors.grey;
      case 'EMITIDO':
        return Colors.blue;
      case 'APROVADO':
        return Colors.green;
      case 'INDEFERIDO':
        return Colors.red;
      case 'EXECUTANDO':
        return Colors.orange;
      case 'FINALIZADO':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusInitial(String? status) {
    switch (status?.toUpperCase()) {
      case 'ORCAMENTO':
        return 'O';
      case 'EMITIDO':
        return 'E';
      case 'APROVADO':
        return 'A';
      case 'INDEFERIDO':
        return 'I';
      case 'EXECUTANDO':
        return 'X';
      case 'FINALIZADO':
        return 'F';
      default:
        return '?';
    }
  }
}