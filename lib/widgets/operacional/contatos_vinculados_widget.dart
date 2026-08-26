/// ============================================
/// WIDGET: Lista de Contatos Vinculados à Empresa
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/operacional/contato_model.dart';
import '../../theme/app_theme.dart';

class ContatosVinculadosWidget extends StatefulWidget {
  final List<ContatoModel> contatos;
  final Function(List<ContatoModel>) onChanged;
  final VoidCallback onAddContato;
  final VoidCallback? onCriarNovoContato;
  final bool isEditing;

  const ContatosVinculadosWidget({
    super.key,
    required this.contatos,
    required this.onChanged,
    required this.onAddContato,
    this.onCriarNovoContato,
    this.isEditing = true,
  });

  @override
  State<ContatosVinculadosWidget> createState() => _ContatosVinculadosWidgetState();
}

class _ContatosVinculadosWidgetState extends State<ContatosVinculadosWidget> {
  void _removerContato(ContatoModel contato) {
    final novaLista = List<ContatoModel>.from(widget.contatos)..remove(contato);
    widget.onChanged(novaLista);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Contatos Vinculados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                if (widget.isEditing)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'vincular') {
                        widget.onAddContato();
                      } else if (value == 'criar') {
                        widget.onCriarNovoContato?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'vincular',
                        child: Row(
                          children: [
                            Icon(Icons.link, size: 18),
                            SizedBox(width: 8),
                            Text('Vincular existente'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'criar',
                        child: Row(
                          children: [
                            Icon(Icons.person_add, size: 18),
                            SizedBox(width: 8),
                            Text('Criar novo contato'),
                          ],
                        ),
                      ),
                    ],
                    child: TextButton(
                      onPressed: null,
                      child: const Text('+ Adicionar'),
                    ),
                  ),
              ],
            ),
            const Divider(),
            if (widget.contatos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Nenhum contato vinculado',
                  style: TextStyle(color: AppTheme.textLight),
                ),
              )
            else
              ...widget.contatos.map((contato) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        contato.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      contato.nome,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contato.tipoVinculoLabel,
                            style: const TextStyle(fontSize: 11)),
                        if (contato.telefones.isNotEmpty)
                          Text('📱 ${contato.telefones.first.numeroFormatado}',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                        if (contato.emails.isNotEmpty)
                          Text('✉️ ${contato.emails.first.endereco}',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                        if (contato.enderecos.isNotEmpty)
                          Text('📍 ${contato.enderecos.first.cidade}, ${contato.enderecos.first.estado}',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                      ],
                    ),
                    trailing: widget.isEditing
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                size: 18, color: AppTheme.dangerColor),
                            onPressed: () => _removerContato(contato),
                          )
                        : null,
                    onTap: () {
                      context.go('/operacional/contatos/editar/${contato.id}');
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
