/// ============================================
/// WIDGET: Card da Etapa (para visualização)
/// ============================================

import 'package:flutter/material.dart';
import '../../models/projetos/etapa_model.dart';
import '../../theme/app_theme.dart';

class EtapaCardWidget extends StatelessWidget {
  final EtapaModel etapa;
  final VoidCallback? onTap;

  const EtapaCardWidget({
    super.key,
    required this.etapa,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: etapa.statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),

          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etapa.descricao ?? 'Sem descrição',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (etapa.valorUnitario != null && etapa.quantidade != null)
                  Text(
                    '${etapa.valorUnitario?.toStringAsFixed(2)} x ${etapa.quantidade?.toStringAsFixed(0)} = R\$ ${etapa.valorEtapa?.toStringAsFixed(2) ?? '0,00'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                if (etapa.dataInicio != null && etapa.dataVencimento != null)
                  Text(
                    '${_formatDate(etapa.dataInicio)} - ${_formatDate(etapa.dataVencimento)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),

          // Status
          Chip(
            label: Text(etapa.statusLabel),
            backgroundColor: etapa.statusColor.withOpacity(0.2),
            labelStyle: TextStyle(
              color: etapa.statusColor,
              fontSize: 11,
            ),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}