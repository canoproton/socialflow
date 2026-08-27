/// ============================================
/// FORMATADOR: CNPJ
/// ============================================

import 'package:flutter/services.dart';

class CnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove tudo que não é dígito
    final String cleaned = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limita a 14 dígitos
    if (cleaned.length > 14) {
      return oldValue;
    }

    // Se estiver vazio, retorna vazio
    if (cleaned.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Aplica a máscara: 00.000.000/0000-00
    String formatted = cleaned;
    
    if (cleaned.length > 2) {
      formatted = '${cleaned.substring(0, 2)}.${cleaned.substring(2)}';
    }
    if (cleaned.length > 5) {
      formatted = '${formatted.substring(0, 6)}.${formatted.substring(6)}';
    }
    if (cleaned.length > 8) {
      formatted = '${formatted.substring(0, 10)}/${formatted.substring(10)}';
    }
    if (cleaned.length > 12) {
      formatted = '${formatted.substring(0, 15)}-${formatted.substring(15)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}