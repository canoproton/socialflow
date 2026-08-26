/// Utilitários de Validação do SocialFlow
/// Funções para validar campos de formulário
class Validators {
  /// Valida o campo de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O email é obrigatório';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Digite um email válido';
    }
    
    return null;
  }

  /// Valida o campo de senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }
    
    if (value.trim().length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  /// Valida o campo de confirmação de senha
  static String? validateConfirmPassword(String? value, String? password) 
{
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    
    if (value.trim() != password?.trim()) {
      return 'As senhas não coincidem';
    }
    
    return null;
  }

  /// Valida o campo de nome
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'O nome é obrigatório';
    }
    
    if (value.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    
    return null;
  }

  /// Valida se o campo não está vazio
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Campo'} é obrigatório';
    }
    return null;
  }
}
