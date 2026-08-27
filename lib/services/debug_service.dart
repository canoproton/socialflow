/// ============================================
/// SERVIÇO: DEBUG
/// ============================================
/// Imprime logs detalhados com timestamp e cores
/// ============================================

import 'package:flutter/foundation.dart';

class DebugService {
  static const String _prefix = '🔍 SOCIALFLOW';

  // Cores para console (funciona no terminal)
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _bold = '\x1B[1m';

  static void log({
    required String module,
    required String action,
    dynamic data,
    String? error,
    bool isError = false,
    bool isWarning = false,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = isError ? '❌' : isWarning ? '⚠️' : '✅';

    String message = '$_prefix $_prefix';
    message += ' [${_blue}$timestamp$_reset]';
    message += ' ${_bold}[$_cyan$module$_reset]$_reset';
    message += ' ${_bold}[${_yellow}$action$_reset]$_reset';

    if (isError) {
      message += ' ${_red}ERROR: $error$_reset';
    } else if (isWarning) {
      message += ' ${_yellow}WARNING: $data$_reset';
    } else {
      message += ' ${_green}SUCCESS: $data$_reset';
    }

    if (kDebugMode) {
      print(message);
      if (isError && error != null) {
        print('${_red}STACK: $error$_reset');
      }
      if (data != null && !isWarning) {
        print('${_cyan}DATA: $data$_reset');
      }
      print('${_cyan}---${_reset}');
    }
  }

  static void module(String module) {
    print('\n${_bold}${_magenta}═══════════════════════════════════════$_reset');
    print('${_bold}${_magenta}  📦 MÓDULO: $module$_reset');
    print('${_bold}${_magenta}═══════════════════════════════════════$_reset\n');
  }

  static void separator() {
    print('${_cyan}─────────────────────────────────────────────$_reset');
  }

  static void navigation(String from, String to, {dynamic params}) {
    log(
      module: 'NAVEGAÇÃO',
      action: 'ROTA',
      data: 'DE: $from → PARA: $to ${params != null ? '| PARAMS: $params' : ''}',
    );
  }

  static void api(String method, String endpoint, {dynamic request, dynamic response, dynamic error}) {
    if (error != null) {
      log(
        module: 'API',
        action: '$method $endpoint',
        error: error.toString(),
        isError: true,
      );
    } else {
      log(
        module: 'API',
        action: '$method $endpoint',
        data: 'REQUEST: $request | RESPONSE: $response',
      );
    }
  }

  static void state(String provider, String action, {dynamic oldState, dynamic newState}) {
    log(
      module: 'PROVIDER',
      action: '$provider.$action',
      data: 'OLD: $oldState | NEW: $newState',
    );
  }

  static void widget(String widgetName, String action, {dynamic data}) {
    log(
      module: 'WIDGET',
      action: '$widgetName.$action',
      data: data,
    );
  }
}