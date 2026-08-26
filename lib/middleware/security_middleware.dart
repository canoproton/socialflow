/// ============================================
/// MIDDLEWARE DE SEGURANÇA - VERSÃO SIMPLIFICADA
/// ============================================

class SecurityMiddleware {
  // Removendo singleton, usando construtor simples
  const SecurityMiddleware();

  static final RegExp _dangerousChars = RegExp(
    r'[<>"' + "'" + r'`;]'
  );

  static const List<String> _sqlKeywords = [
    'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'ALTER',
    'CREATE', 'EXEC', 'UNION', 'OR', 'AND', 'WHERE', 'FROM'
  ];

  String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    String sanitized = input.replaceAll(_dangerousChars, '');
    sanitized = sanitized.trim();
    sanitized = sanitized.replaceAll(RegExp(r'\0'), '');
    return sanitized;
  }

  bool isInputSafe(String input) {
    if (input.isEmpty) return true;
    if (_dangerousChars.hasMatch(input)) {
      return false;
    }
    final upperInput = input.toUpperCase();
    for (var keyword in _sqlKeywords) {
      if (upperInput.contains(keyword)) {
        return false;
      }
    }
    return true;
  }

  String escapeHtml(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;')
        .replaceAll('/', '&#47;')
        .replaceAll('`', '&#96;');
  }

  String escapeStringForJson(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  String validateAndSanitizeEmail(String email) {
    email = email.trim().toLowerCase();
    email = sanitizeInput(email);
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Formato de email inválido');
    }
    if (!isInputSafe(email)) {
      throw Exception('Email contém caracteres inválidos');
    }
    return email;
  }

  bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  String maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) return email;
    final visible = username.substring(0, 2);
    final masked = '*' * (username.length - 2);
    return '$visible$masked@$domain';
  }
}
