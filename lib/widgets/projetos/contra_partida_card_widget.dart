/// ============================================
/// WIDGET: Card de Contra Partida (Regra 11)
/// ============================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/contra_partida_model.dart';
import '../../theme/app_theme.dart';

class ContraPartidaCardWidget extends StatelessWidget {
  final ContraPartidaModel contraPartida;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ContraPartidaCardWidget({
    super.key,
    required this.contraPartida,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case ContraPartidaModel.STATUS_PENDENTE:
        return Colors.orange;
      case ContraPartidaModel.STATUS_CONFIRMADO:
        return Colors.blue;
      case ContraPartidaModel.STATUS_REALIZADO:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(contraPartida.status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contraPartida.descricao,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Valor: ${_formatCurrency(contraPartida.valor)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (contraPartida.dataEntrega != null)
                  Text(
                    'Entrega: ${_formatDate(contraPartida.dataEntrega)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Chip(
            label: Text(contraPartida.statusLabel),
            backgroundColor: _getStatusColor(contraPartida.status).withOpacity(0.2),
            labelStyle: TextStyle(
              color: _getStatusColor(contraPartida.status),
              fontSize: 10,
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