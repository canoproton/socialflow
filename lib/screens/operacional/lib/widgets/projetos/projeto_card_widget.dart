/// ============================================
/// WIDGET: Card do Projeto (para lista)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/projeto_model.dart';
import '../../theme/app_theme.dart';

class ProjetoCardWidget extends StatelessWidget {
  final ProjetoModel projeto;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onView;

  const ProjetoCardWidget({
    super.key,
    required this.projeto,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: projeto.statusColor,
                          radius: 20,
                          child: Text(
                            projeto.descricao?.substring(0, 1).toUpperCase() ?? 'P',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                projeto.descricao ?? 'Sem título',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (projeto.processo != null)
                                Text(
                                  'Processo: ${projeto.processo}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(projeto.statusLabel),
                    backgroundColor: projeto.statusColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: projeto.statusColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Info
              Row(
                children: [
                  _buildInfoItem(
                    Icons.calendar_today,
                    'Entrega: ${_formatDate(projeto.dataEntrega)}',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.attach_money,
                    'R\$ ${projeto.valorTotalMetas?.toStringAsFixed(2) ?? '0,00'}',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.trending_up,
                    'Saldo: R\$ ${projeto.saldoProjeto?.toStringAsFixed(2) ?? '0,00'}',
                    color: projeto.saldoProjeto != null && projeto.saldoProjeto! >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Ações
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: AppTheme.primaryColor),
                    onPressed: onView ?? onTap,
                    tooltip: 'Ver detalhes',
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                    tooltip: 'Editar',
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Excluir',
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}