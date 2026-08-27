/// ============================================
/// MODAL: Seleção de Contato
/// ============================================

import 'package:flutter/material.dart';
import '../../models/operacional/contato_model.dart';
import '../../theme/app_theme.dart';

class ContatoSelectionModal extends StatefulWidget {
  final List<ContatoModel> contatos;

  const ContatoSelectionModal({
    super.key,
    required this.contatos,
  });

  @override
  State<ContatoSelectionModal> createState() => _ContatoSelectionModalState();
}

class _ContatoSelectionModalState extends State<ContatoSelectionModal> {
  String _searchQuery = '';

  List<ContatoModel> get _filteredContatos {
    if (_searchQuery.isEmpty) return widget.contatos;
    return widget.contatos.where((c) =>
        c.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.tipoVinculoLabel.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Selecionar Contato',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar contato...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

            // Lista
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContatos.length,
                itemBuilder: (context, index) {
                  final contato = _filteredContatos[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        contato.nome.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(contato.nome),
                    subtitle: Text(contato.tipoVinculoLabel),
                    onTap: () => Navigator.pop(context, contato),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}