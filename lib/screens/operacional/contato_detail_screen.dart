/// ============================================
/// TELA: Detalhes do Contato
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/contato_model.dart';
import '../../widgets/operacional/telefone_list_widget.dart';
import '../../widgets/operacional/email_list_widget.dart';
import '../../widgets/operacional/endereco_list_widget.dart';
import '../../widgets/operacional/midias_list_widget.dart';
import '../../theme/app_theme.dart';

class ContatoDetailScreen extends StatefulWidget {
  final String contatoId;

  const ContatoDetailScreen({super.key, required this.contatoId});

  @override
  State<ContatoDetailScreen> createState() => _ContatoDetailScreenState();
}

class _ContatoDetailScreenState extends State<ContatoDetailScreen> {
  late ContatoModel _contato;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<ContatoProvider>();
    await provider.loadContatoById(widget.contatoId);
    if (mounted) {
      setState(() {
        _contato = provider.selectedContato!;
        _isLoading = false;
      });
    }
  }

  void _goBack() {
    if (mounted) {
      context.go('/operacional/contatos');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_contato.nome),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (mounted) {
                context.go('/operacional/contatos/editar/${_contato.id}');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            
            TelefoneListWidget(
              telefones: _contato.telefones,
              onChanged: (novos) {
                setState(() => _contato = _contato.copyWith(telefones: novos));
              },
            ),
            
            EmailListWidget(
              emails: _contato.emails,
              onChanged: (novos) {
                setState(() => _contato = _contato.copyWith(emails: novos));
              },
            ),
            
            EnderecoListWidget(
              enderecos: _contato.enderecos,
              onChanged: (novos) {
                setState(() => _contato = _contato.copyWith(enderecos: novos));
              },
            ),
            
            MidiasListWidget(
              midias: _contato.midias,
              onChanged: (novos) {
                setState(() => _contato = _contato.copyWith(midias: novos));
              },
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar para Lista'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    _contato.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
                        _contato.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _contato.tipoVinculoLabel,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Tipo', _contato.tipoVinculoLabel),
            if (_contato.genero != null)
              _buildInfoRow('Gênero', _contato.generoLabel),
            if (_contato.cpf != null && _contato.cpf!.isNotEmpty)
              _buildInfoRow('CPF', _contato.cpfFormatado),
            if (_contato.rg != null && _contato.rg!.isNotEmpty)
              _buildInfoRow('RG', _contato.rg!),
            if (_contato.obs != null && _contato.obs!.isNotEmpty)
              _buildInfoRow('Observações', _contato.obs!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
