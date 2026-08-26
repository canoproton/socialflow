/// ============================================
/// VALIDADORES DO MÓDULO PROJETOS
/// ============================================

class ProjetoValidators {
  // Validação do Processo (Regra 1)
  static String? validarProcesso(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo Processo é obrigatório';
    }

    final regex = RegExp(r'^\d{5}-\d{8}/\d{4}-\d{2}$');
    if (!regex.hasMatch(value)) {
      return 'Formato inválido. Use: XXXXX-XXXXXXXX/XXXX-XX (ex: 00150-00003771/2019-44)';
    }
    return null;
  }

  // Validação de CNPJ
  static String? validarCnpj(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final cleanCnpj = value.replaceAll(RegExp(r'\D'), '');
    if (cleanCnpj.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }
    return null;
  }

  // Validação de Valor
  static String? validarValor(double? value) {
    if (value == null || value <= 0) {
      return 'Valor deve ser maior que zero';
    }
    return null;
  }

  // Validação de Datas
  static String? validarDatas(DateTime? inicio, DateTime? fim) {
    if (inicio == null || fim == null) return null;
    if (fim.isBefore(inicio)) {
      return 'Data de fim não pode ser anterior à data de início';
    }
    return null;
  }

  // Validação de Quantidade
  static String? validarQuantidade(double? value) {
    if (value == null || value <= 0) {
      return 'Quantidade deve ser maior que zero';
    }
    return null;
  }
}