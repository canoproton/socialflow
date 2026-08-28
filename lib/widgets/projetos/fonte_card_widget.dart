/// ============================================
/// WIDGET: Card de Fonte de Recurso (Regra 7)
/// ============================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../theme/app_theme.dart';

class FonteCardWidget extends StatelessWidget {
  final FontesBaseModel fonte;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const FonteCardWidget({
    super.key,
    required this.fonte,
    this.onTap,
    this.onRemove,
  });

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fonte.descricao,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Entidade: ${fonte.entidade}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  'Valor: ${_formatCurrency(fonte.valorRecurso)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (fonte.dataAprovacao != null)
                  Text(
                    'Aprovação: ${_formatDate(fonte.dataAprovacao)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.red),
              onPressed: onRemove,
              tooltip: 'Remover',
            ),
        ],
      ),
    );
  }
}