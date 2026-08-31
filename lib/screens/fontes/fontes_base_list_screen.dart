import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fontes/fontes_base_provider.dart';
import '../../providers/fontes/fontes_alocacao_provider.dart';
import '../../models/fontes/fontes_base_model.dart';
import 'fontes_base_form_screen.dart';
import 'fontes_pesquisa_screen.dart';
import 'fontes_alocacao_screen.dart';

/// Tela principal do módulo Fontes de Recursos
class FontesBaseListScreen extends StatefulWidget {
  const FontesBaseListScreen({Key? key}) : super(key: key);

  @override
  State<FontesBaseListScreen> createState() => _FontesBaseListScreenState();
}

class _FontesBaseListScreenState extends State<FontesBaseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FontesBaseProvider>().carregarFontes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FontesBaseProvider>();
    final alocacaoProvider = context.watch<FontesAlocacaoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fontes de Recursos'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.carregarFontes(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Barra de Ações
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _registrarFonte,
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pesquisarFontes,
                    icon: const Icon(Icons.search),
                    label: const Text('Pesquisar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _alocarRecursos,
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Alocar Recursos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
              ],
            ),
          ),

          // ✅ Resumo
          if (provider.fontes.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResumoItem(
                    'Total Geral',
                    _formatMoney(provider.totalGeral),
                    Colors.blue[700]!,
                  ),
                  _buildResumoItem(
                    'Total Alocado',
                    _formatMoney(provider.totalAlocadoGeral),
                    Colors.orange[700]!,
                  ),
                  _buildResumoItem(
                    'Saldo Geral',
                    _formatMoney(provider.saldoGeral),
                    provider.saldoGeral > 0 ? Colors.green[700]! : Colors.red[700]!,
                  ),
                ],
              ),
            ),

          // ✅ Lista de Fontes
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.fontes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.erro ?? 'Nenhuma fonte cadastrada',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _registrarFonte,
                              icon: const Icon(Icons.add),
                              label: const Text('Cadastrar Primeira Fonte'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: provider.fontes.length,
                        itemBuilder: (context, index) {
                          final fonte = provider.fontes[index];
                          return _buildFonteCard(fonte);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
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

  Widget _buildFonteCard(FontesBase fonte) {
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
            IconButton(
              icon: const Icon(Icons.attach_money, color: Colors.orange),
              onPressed: () => _alocarRecursos(fonteId: fonte.id),
              tooltip: 'Alocar Recurso',
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.blue),
              onPressed: () => _verExtrato(fonte.id!),
              tooltip: 'Ver Extrato',
            ),
            if (fonte.id != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _editarFonte(fonte),
                tooltip: 'Editar',
              ),
          ],
        ),
      ),
    );
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // ✅ Navegações
  void _registrarFonte() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FontesBaseFormScreen(),
      ),
    );
  }

  void _editarFonte(FontesBase fonte) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FontesBaseFormScreen(fonte: fonte),
      ),
    );
  }

  void _pesquisarFontes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FontesPesquisaScreen(),
      ),
    );
  }

  void _alocarRecursos({String? fonteId}) {
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