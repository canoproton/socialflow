/// ============================================
/// SERVIÇO DE RATE LIMITING - CORRIGIDO
/// ============================================

import 'dart:collection';

class RateLimitService {
  RateLimitService(); // ← Removendo const

  static const int MAX_LOGIN_ATTEMPTS = 5;
  static const int MAX_ACTION_ATTEMPTS = 10;
  static const Duration BLOCK_DURATION = Duration(minutes: 15);
  static const Duration ACTION_WINDOW = Duration(minutes: 5);

  final Map<String, int> _loginAttempts = {};
  final Map<String, DateTime> _loginBlockedUntil = {};
  final Map<String, Queue<DateTime>> _actionTimestamps = {};

  bool canAttemptLogin(String identifier) {
    if (_loginBlockedUntil.containsKey(identifier)) {
      if (DateTime.now().isBefore(_loginBlockedUntil[identifier]!)) {
        return false;
      }
      _loginBlockedUntil.remove(identifier);
      _loginAttempts.remove(identifier);
    }
    return true;
  }

  Map<String, dynamic> registerLoginAttempt(String identifier, bool success) {
    if (success) {
      _loginAttempts.remove(identifier);
      _loginBlockedUntil.remove(identifier);
      return {
        'allowed': true,
        'message': 'Login realizado com sucesso',
        'blocked': false,
      };
    }

    _loginAttempts[identifier] = (_loginAttempts[identifier] ?? 0) + 1;
    final attempts = _loginAttempts[identifier]!;
    final remaining = MAX_LOGIN_ATTEMPTS - attempts;

    if (attempts >= MAX_LOGIN_ATTEMPTS) {
      _loginBlockedUntil[identifier] = DateTime.now().add(BLOCK_DURATION);
      return {
        'allowed': false,
        'message': 'Muitas tentativas falhas. Bloqueado por 15 minutos.',
        'blocked': true,
        'blocked_until': _loginBlockedUntil[identifier],
      };
    }

    return {
      'allowed': true,
      'message': 'Tentativa falha. $remaining tentativas restantes.',
      'blocked': false,
      'remaining': remaining,
    };
  }

  bool canPerformAction(String userId, String action) {
    final key = '$userId:$action';
    
    if (!_actionTimestamps.containsKey(key)) {
      _actionTimestamps[key] = Queue<DateTime>();
    }

    final timestamps = _actionTimestamps[key]!;
    
    final cutoff = DateTime.now().subtract(ACTION_WINDOW);
    while (timestamps.isNotEmpty && timestamps.first.isBefore(cutoff)) {
      timestamps.removeFirst();
    }

    if (timestamps.length >= MAX_ACTION_ATTEMPTS) {
      return false;
    }

    timestamps.add(DateTime.now());
    return true;
  }

  void resetCounters(String identifier) {
    _loginAttempts.remove(identifier);
    _loginBlockedUntil.remove(identifier);
    _actionTimestamps.removeWhere((key, _) => key.startsWith(identifier));
  }

  Map<String, dynamic> getStats() {
    return {
      'total_login_attempts': _loginAttempts.length,
      'total_blocked': _loginBlockedUntil.length,
      'total_actions': _actionTimestamps.length,
      'blocked_until': _loginBlockedUntil.map(
        (key, value) => MapEntry(key, value.toString())
      ),
    };
  }
}
