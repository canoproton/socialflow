# 📚 SocialFlow - Documentação Completa do Projeto

## 📁 Estrutura de Pastas
```
lib
lib/config
lib/controllers
lib/middleware
lib/models
lib/models/contabilidade
lib/models/documentos
lib/models/financeiro
lib/models/operacional
lib/models/projetos
lib/models/usuarios
lib/providers
lib/providers/operacional
lib/providers/usuarios
lib/router
lib/screens
lib/screens/operacional
lib/screens/usuarios
lib/services
lib/services/backup
lib/services/operacional
lib/services/security
lib/services/usuarios
lib/theme
lib/utils
lib/widgets
lib/widgets/operacional
lib/widgets/usuarios
```

## 📄 Lista de Arquivos Dart
```
lib/config/supabase_config.dart
lib/main.dart
lib/main_simple.dart
lib/middleware/security_middleware.dart
lib/models/models.dart
lib/models/operacional/contato_model.dart
lib/models/operacional/email_model.dart
lib/models/operacional/empresa_model.dart
lib/models/operacional/endereco_model.dart
lib/models/operacional/funcao_model.dart
lib/models/operacional/midias_model.dart
lib/models/operacional/operacional_models.dart
lib/models/operacional/telefone_model.dart
lib/models/user_model.dart
lib/models/usuarios/access_log_model.dart
lib/models/usuarios/module_model.dart
lib/models/usuarios/permission_model.dart
lib/models/usuarios/profile_model.dart
lib/providers/operacional/contato_provider.dart
lib/providers/operacional/empresa_provider.dart
lib/providers/usuarios/user_provider.dart
lib/router/app_router.dart
lib/router/app_router_simple.dart
lib/screens/home_screen.dart
lib/screens/login_screen.dart
lib/screens/login_screen_simple.dart
lib/screens/operacional/contato_detail_screen.dart
lib/screens/operacional/contato_form_screen.dart
lib/screens/operacional/contato_list_screen.dart
lib/screens/operacional/contato_unified_screen.dart
lib/screens/operacional/empresa_list_screen.dart
lib/screens/operacional/empresa_unified_screen.dart
lib/services/auth_service.dart
lib/services/auth_service_simple.dart
lib/services/backup/audit_service.dart
lib/services/backup/encryption_service.dart
lib/services/backup/permission_service.dart
lib/services/backup/rate_limit_service.dart
lib/services/backup/secure_auth_service.dart
lib/services/operacional/base_service.dart
lib/services/operacional/contato_service.dart
lib/services/operacional/email_service.dart
lib/services/operacional/empresa_service.dart
lib/services/operacional/endereco_service.dart
lib/services/operacional/funcao_service.dart
lib/services/operacional/midias_service.dart
lib/services/operacional/relacionamento_service.dart
lib/services/operacional/search_service.dart
lib/services/operacional/telefone_service.dart
lib/theme/app_theme.dart
lib/utils/validators.dart
lib/widgets/logo_widget.dart
lib/widgets/operacional/contatos_vinculados_widget.dart
lib/widgets/operacional/email_list_widget.dart
lib/widgets/operacional/endereco_list_widget.dart
lib/widgets/operacional/midias_list_widget.dart
lib/widgets/operacional/search_filters_widget.dart
lib/widgets/operacional/telefone_list_widget.dart
```

## 📦 Dependências (pubspec.yaml)
```yaml
name: meu_backend
description: "SocialFlow - Sistema de Gestão"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.0

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.17.2
  flutter_dotenv: ^6.0.1
  go_router: ^14.0.0
  cupertino_icons: ^1.0.8
  flutter_form_builder: ^10.0.0
  flutter_spinkit: ^5.2.1
  provider: ^6.1.5+1
  flutter_local_notifications: ^22.3.0
  encrypt: ^5.0.3
  crypto: ^3.0.7
  universal_html: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/images/
```

## 🚀 main.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'router/app_router_simple.dart';
import 'theme/app_theme.dart';
import 'providers/operacional/contato_provider.dart';
import 'providers/operacional/empresa_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContatoProvider()),
        ChangeNotifierProvider(create: (_) => EmpresaProvider()),
      ],
      child: MaterialApp.router(
        title: 'SocialFlow',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouterSimple.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

## 🗺️ Arquivos de Rota
### lib/router/app_router_simple.dart
```dart
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/operacional/contato_list_screen.dart';
import '../screens/operacional/contato_unified_screen.dart';
import '../screens/operacional/empresa_list_screen.dart';
import '../screens/operacional/empresa_unified_screen.dart';
import '../services/auth_service.dart';

class AppRouterSimple {
  static final AuthService _authService = AuthService();

  static GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = _authService.isAuthenticated;

      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/home';
      }

      if (!isAuthenticated && state.matchedLocation == '/home') {
        return '/login';
      }

      if (!isAuthenticated && state.matchedLocation == '/') {
        return '/login';
      }

      return null;
    },
    routes: [
      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Dashboard
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // ============================================
      // MÓDULO OPERACIONAL - CONTATOS
      // ============================================
      
      // Lista de Contatos
      GoRoute(
        path: '/operacional/contatos',
        name: 'operacional-contatos',
        builder: (context, state) => const ContatoListScreen(),
      ),
      
      // Novo Contato (Unificado)
      GoRoute(
        path: '/operacional/contatos/novo',
        name: 'operacional-contatos-novo',
        builder: (context, state) => const ContatoUnifiedScreen(),
      ),
      
      // Editar Contato (Unificado)
      GoRoute(
        path: '/operacional/contatos/editar/:id',
        name: 'operacional-contatos-editar',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ContatoUnifiedScreen(contatoId: id);
        },
      ),
      
      // ============================================
      // MÓDULO OPERACIONAL - EMPRESAS
      // ============================================
      
      // Lista de Empresas
      GoRoute(
        path: '/operacional/empresas',
        name: 'operacional-empresas',
        builder: (context, state) => const EmpresaListScreen(),
      ),
      
      // Nova Empresa (Unificado)
      GoRoute(
        path: '/operacional/empresas/novo',
        name: 'operacional-empresas-novo',
        builder: (context, state) => const EmpresaUnifiedScreen(),
      ),
      
      // Editar Empresa (Unificado)
      GoRoute(
        path: '/operacional/empresas/editar/:id',
        name: 'operacional-empresas-editar',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EmpresaUnifiedScreen(empresaId: id);
        },
      ),
    ],
  );
}
```

### lib/router/app_router.dart
```dart
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/operacional/contato_list_screen.dart'; // ← NOVA IMPORT
import '../services/auth_service.dart';

class AppRouter {
  static final AuthService _authService = AuthService();

  static GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = _authService.isAuthenticated();

      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/home';
      }

      if (!isAuthenticated && state.matchedLocation == '/home') {
        return '/login';
      }

      if (!isAuthenticated && state.matchedLocation == '/') {
        return '/login';
      }

      return null;
    },
    routes: [
      // Rota de Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Rota do Dashboard
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // ============================================
      // MÓDULO OPERACIONAL
      // ============================================
      GoRoute(
        path: '/operacional/contatos',
        name: 'operacional-contatos',
        builder: (context, state) => const ContatoListScreen(),
      ),
    ],
  );
}```

## 📱 Módulos Existentes
## 🏗️ Models/Entidades
### lib/models/operacional/operacional_models.dart
```dart
/// ============================================
/// EXPORTAÇÃO DE TODOS OS MODELOS OPERACIONAIS
/// ============================================

export 'funcao_model.dart';
export 'contato_model.dart';
export 'empresa_model.dart';
export 'telefone_model.dart';
export 'email_model.dart';
export 'endereco_model.dart';
export 'midias_model.dart';
```

### lib/models/operacional/telefone_model.dart
```dart
/// ============================================
/// MODELO: Telefone
/// ============================================
/// Representa um telefone vinculado a um contato
/// 
/// Tabela: telefone
/// Campos:
///   - id: UUID (PK)
///   - contato_id: UUID (FK para contato)
///   - uso: String (CORPORATIVO, PARTICULAR, COMUNITARIO)
///   - numero: String
///   - obs: Text
///   - atualizado_por: UUID (FK para Users)
///   - atualizado_em: DateTime
/// ============================================

class TelefoneModel {
  final String id;
  final String contatoId;
  final String uso;
  final String numero;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  static const Map<String, String> usoLabels = {
    'CORPORATIVO': 'Corporativo',
    'PARTICULAR': 'Particular',
    'COMUNITARIO': 'Comunitário',
  };

  TelefoneModel({
    required this.id,
    required this.contatoId,
    required this.uso,
    required this.numero,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory TelefoneModel.fromJson(Map<String, dynamic> json) {
    return TelefoneModel(
      id: json['id']?.toString() ?? '',
      contatoId: json['contato_id']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      numero: json['numero']?.toString() ?? '',
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contato_id': contatoId,
      'uso': uso,
      'numero': numero,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  TelefoneModel copyWith({
    String? id,
    String? contatoId,
    String? uso,
    String? numero,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
  }) {
    return TelefoneModel(
      id: id ?? this.id,
      contatoId: contatoId ?? this.contatoId,
      uso: uso ?? this.uso,
```

### lib/models/operacional/empresa_model.dart
```dart
/// ============================================
/// MODELO: Empresa (COMPLETO)
/// ============================================

import 'contato_model.dart';
import 'telefone_model.dart';
import 'email_model.dart';
import 'endereco_model.dart';
import 'midias_model.dart';

class EmpresaModel {
  final String id;
  final String nome;
  final String qualif;
  final String razaoSocial;
  final String tipoContr;
  final String? cnpj;
  final String? ie;
  final String? contatoPrincipalId;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // ⭐ RELACIONAMENTOS
  List<ContatoModel> contatos;
  List<TelefoneModel> telefones;
  List<EmailModel> emails;
  List<EnderecoModel> enderecos;
  List<MidiasModel> midias;

  static const Map<String, String> qualifLabels = {
    'INTERNA': 'Interna',
    'COLIGADA': 'Coligada',
    'OPERACIONAL': 'Operacional',
    'PESSOA_FISICA': 'Pessoa Física',
    'FORNECEDOR': 'Fornecedor',
  };

  static const Map<String, String> tipoContrLabels = {
    'RPA': 'RPA',
    'CNPJ': 'CNPJ',
    'MEI': 'MEI',
    'ADH': 'Ad-Hoc',
  };

  EmpresaModel({
    required this.id,
    required this.nome,
    required this.qualif,
    required this.razaoSocial,
    required this.tipoContr,
    this.cnpj,
    this.ie,
    this.contatoPrincipalId,
    this.obs,
    this.atualizadoPor,
    this.createdAt,
    this.updatedAt,
    this.contatos = const [],
    this.telefones = const [],
    this.emails = const [],
    this.enderecos = const [],
    this.midias = const [],
  });

  factory EmpresaModel.fromJson(Map<String, dynamic> json) {
    return EmpresaModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      qualif: json['qualif']?.toString() ?? 'FORNECEDOR',
      razaoSocial: json['razao_social']?.toString() ?? '',
      tipoContr: json['tipo_contr']?.toString() ?? 'CNPJ',
      cnpj: json['cnpj']?.toString(),
      ie: json['ie']?.toString(),
      contatoPrincipalId: json['contato_principal']?.toString(),
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
```

### lib/models/operacional/email_model.dart
```dart
/// ============================================
/// MODELO: Email
/// ============================================
/// Representa um e-mail vinculado a um contato
/// 
/// Tabela: email
/// Campos:
///   - id: UUID (PK)
///   - contato_id: UUID (FK para contato)
///   - uso: String (CORPORATIVO, PARTICULAR, COMUNITARIO)
///   - endereco: String
///   - obs: Text
///   - atualizado_por: UUID (FK para Users)
///   - atualizado_em: DateTime
/// ============================================

class EmailModel {
  final String id;
  final String contatoId;
  final String uso;
  final String endereco;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  static const Map<String, String> usoLabels = {
    'CORPORATIVO': 'Corporativo',
    'PARTICULAR': 'Particular',
    'COMUNITARIO': 'Comunitário',
  };

  EmailModel({
    required this.id,
    required this.contatoId,
    required this.uso,
    required this.endereco,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      id: json['id']?.toString() ?? '',
      contatoId: json['contato_id']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      endereco: json['endereco']?.toString() ?? '',
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contato_id': contatoId,
      'uso': uso,
      'endereco': endereco,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  EmailModel copyWith({
    String? id,
    String? contatoId,
    String? uso,
    String? endereco,
    String? obs,
    String? atualizadoPor,
    DateTime? atualizadoEm,
  }) {
    return EmailModel(
      id: id ?? this.id,
      contatoId: contatoId ?? this.contatoId,
      uso: uso ?? this.uso,
```

### lib/models/operacional/funcao_model.dart
```dart
/// ============================================
/// MODELO: Funcao
/// ============================================
/// Representa um cargo/função exercida por um contato
/// 
/// Tabela: funcao
/// Campos:
///   - id: UUID (PK)
///   - descricao: String (ex: "Gerente de Projetos")
///   - atualizado_por: UUID (FK para Users)
///   - atualizado_em: DateTime
/// ============================================

class FuncaoModel {
  final String id;
  final String descricao;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  FuncaoModel({
    required this.id,
    required this.descricao,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  /// Converte JSON para objeto
  factory FuncaoModel.fromJson(Map<String, dynamic> json) {
    return FuncaoModel(
      id: json['id']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em'].toString()) 
          : null,
    );
  }

  /// Converte objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  /// Cria cópia com dados atualizados
  FuncaoModel copyWith({
    String? id,
    String? descricao,
    String? atualizadoPor,
    DateTime? atualizadoEm,
  }) {
    return FuncaoModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
```

### lib/models/operacional/midias_model.dart
```dart
/// ============================================
/// MODELO: Midias
/// ============================================

class MidiasModel {
  final String id;
  final String contatoId;
  final String uso;
  final String tipo;
  final String? nomeDoApp;
  final String descricao;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  static const Map<String, String> usoLabels = {
    'CORPORATIVO': 'Corporativo',
    'PARTICULAR': 'Particular',
    'COMUNITARIO': 'Comunitário',
  };

  static const Map<String, String> tipoLabels = {
    'APLICATIVO': 'Aplicativo',
    'SITE': 'Site',
    'MENSAGERIA': 'Mensageria',
  };

  static const List<String> appsComuns = [
    'WhatsApp', 'LinkedIn', 'Instagram', 'Facebook',
    'Twitter', 'YouTube', 'TikTok', 'Telegram',
    'Signal', 'Discord', 'Slack', 'Teams',
  ];

  MidiasModel({
    required this.id,
    required this.contatoId,
    required this.uso,
    required this.tipo,
    this.nomeDoApp,
    required this.descricao,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory MidiasModel.fromJson(Map<String, dynamic> json) {
    return MidiasModel(
      id: json['id']?.toString() ?? '',
      contatoId: json['contato_id']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      tipo: json['tipo']?.toString() ?? 'APLICATIVO',
      nomeDoApp: json['nome_do_app']?.toString(),
      descricao: json['descricao']?.toString() ?? '',
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contato_id': contatoId,
      'uso': uso,
      'tipo': tipo,
      'nome_do_app': nomeDoApp,
      'descricao': descricao,
      'obs': obs,
      'atualizado_por': atualizadoPor,
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  MidiasModel copyWith({
    String? id,
    String? contatoId,
    String? uso,
    String? tipo,
```

### lib/models/operacional/contato_model.dart
```dart
/// ============================================
/// MODELO: Contato (COMPLETO)
/// ============================================

import 'telefone_model.dart';
import 'email_model.dart';
import 'endereco_model.dart';
import 'midias_model.dart';

class ContatoModel {
  final String id;
  final String nome;
  final String tipoVinculo;
  final String? funcaoId;
  final String? empresaId;
  final String? cpf;
  final String? rg;
  final String? genero;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? createdAt;
  final DateTime? atualizadoEm;
  
  // Relacionamentos
  List<TelefoneModel> telefones;
  List<EmailModel> emails;
  List<EnderecoModel> enderecos;
  List<MidiasModel> midias;

  static const Map<String, String> tipoVinculoLabels = {
    'BANCO': 'Banco',
    'INTERNO': 'Interno',
    'EXTERNO': 'Externo',
    'EMPRESA': 'Empresa',
    'PATROCINADOR': 'Patrocinador',
    'OPERACIONAL': 'Operacional',
    'VARIOS': 'Vários',
  };

  static const Map<String, String> generoLabels = {
    'FEMININO': 'Feminino',
    'MASCULINO': 'Masculino',
    'OUTROS': 'Outros',
  };

  ContatoModel({
    required this.id,
    required this.nome,
    required this.tipoVinculo,
    this.funcaoId,
    this.empresaId,
    this.cpf,
    this.rg,
    this.genero,
    this.obs,
    this.atualizadoPor,
    this.createdAt,
    this.atualizadoEm,
    this.telefones = const [],
    this.emails = const [],
    this.enderecos = const [],
    this.midias = const [],
  });

  factory ContatoModel.fromJson(Map<String, dynamic> json) {
    return ContatoModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      tipoVinculo: json['tipo_vinculo']?.toString() ?? 'EXTERNO',
      funcaoId: json['funcao_id']?.toString(),
      empresaId: json['empresa_id']?.toString(),
      cpf: json['cpf']?.toString(),
      rg: json['rg']?.toString(),
      genero: json['genero']?.toString(),
      obs: json['obs']?.toString(),
      atualizadoPor: json['atualizado_por']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : null,
      atualizadoEm: json['atualizado_em'] != null 
```

### lib/models/operacional/endereco_model.dart
```dart
/// ============================================
/// MODELO: Endereco
/// ============================================
/// Representa um endereço vinculado a um contato
/// 
/// Tabela: endereco
/// Campos:
///   - id: UUID (PK)
///   - contato_id: UUID (FK para contato)
///   - logradouro: String
///   - bairro: String
///   - cidade: String
///   - estado: String (UF)
///   - cep: String
///   - obs: Text
///   - atualizado_por: UUID (FK para Users)
///   - atualizado_em: DateTime
/// ============================================

class EnderecoModel {
  final String id;
  final String contatoId;
  final String logradouro;
  final String? bairro;
  final String cidade;
  final String estado;
  final String? cep;
  final String? obs;
  final String? atualizadoPor;
  final DateTime? atualizadoEm;

  // Lista de estados brasileiros
  static const Map<String, String> estados = {
    'AC': 'Acre',
    'AL': 'Alagoas',
    'AP': 'Amapá',
    'AM': 'Amazonas',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'DF': 'Distrito Federal',
    'ES': 'Espírito Santo',
    'GO': 'Goiás',
    'MA': 'Maranhão',
    'MT': 'Mato Grosso',
    'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais',
    'PA': 'Pará',
    'PB': 'Paraíba',
    'PR': 'Paraná',
    'PE': 'Pernambuco',
    'PI': 'Piauí',
    'RJ': 'Rio de Janeiro',
    'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul',
    'RO': 'Rondônia',
    'RR': 'Roraima',
    'SC': 'Santa Catarina',
    'SP': 'São Paulo',
    'SE': 'Sergipe',
    'TO': 'Tocantins',
  };

  EnderecoModel({
    required this.id,
    required this.contatoId,
    required this.logradouro,
    this.bairro,
    required this.cidade,
    required this.estado,
    this.cep,
    this.obs,
    this.atualizadoPor,
    this.atualizadoEm,
  });

  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
      id: json['id']?.toString() ?? '',
      contatoId: json['contato_id']?.toString() ?? '',
      logradouro: json['logradouro']?.toString() ?? '',
```

### lib/models/user_model.dart
```dart
/// Modelo de Usuário do SocialFlow
/// Representa os dados do usuário autenticado no sistema
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.isActive = true,
    this.createdAt,
    this.lastLogin,
  });

  /// Converte um mapa (JSON) para um objeto UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString(),
      role: map['role']?.toString(),
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : null,
      lastLogin: map['last_login'] != null 
          ? DateTime.parse(map['last_login'].toString()) 
          : null,
    );
  }

  /// Converte um objeto UserModel para mapa (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Retorna o nome do usuário ou "Usuário" se não tiver nome
  String get displayName => name ?? email.split('@').first;

  /// Cópia do usuário com dados atualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}```

### lib/models/usuarios/profile_model.dart
```dart
import '../../middleware/security_middleware.dart';

class ProfileModel {
  final String id;
  final String userId;
  final String email;
  final String nome;
  final String? cargo;
  final String? departamento;
  final String? telefone;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.nome,
    this.cargo,
    this.departamento,
    this.telefone,
    this.avatarUrl,
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Instância simples
    final security = SecurityMiddleware();
    
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nome: security.sanitizeInput(json['nome']?.toString() ?? ''),
      cargo: json['cargo'] != null ? security.sanitizeInput(json['cargo'].toString()) : null,
      departamento: json['departamento'] != null ? security.sanitizeInput(json['departamento'].toString()) : null,
      telefone: json['telefone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'].toString()) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'nome': nome,
      'cargo': cargo,
      'departamento': departamento,
      'telefone': telefone,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? nome,
    String? cargo,
```

## 🔧 Services
### lib/services/operacional/relacionamento_service.dart
```dart
/// ============================================
/// SERVIÇO: Relacionamentos
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';
import '../../models/operacional/contato_model.dart';

class RelacionamentoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // MÉTODOS PARA CONTATO
  // ============================================

  Future<List<TelefoneModel>> saveTelefones(
    String contatoId, 
    List<TelefoneModel> telefones
  ) async {
    print('=== SALVANDO TELEFONES (CONTATO) ===');
    print('Contato ID: $contatoId');
    
    final validos = telefones.where((t) => t.numero.isNotEmpty).toList();
    
    await _supabase
        .from('telefone')
        .delete()
        .eq('contato_id', contatoId);

    List<TelefoneModel> salvos = [];
    for (var telefone in validos) {
      final data = {
        'contato_id': contatoId,
        'uso': telefone.uso,
        'numero': telefone.numero,
        'obs': telefone.obs,
      };
      
      try {
        final result = await _supabase
            .from('telefone')
            .insert(data)
            .select()
            .single();
        salvos.add(TelefoneModel.fromJson(result));
      } catch (e) {
        print('Erro ao inserir telefone: $e');
      }
    }
    
    print('Telefones salvos: ${salvos.length}');
    return salvos;
  }

  Future<List<EmailModel>> saveEmails(
    String contatoId, 
    List<EmailModel> emails
  ) async {
    print('=== SALVANDO EMAILS (CONTATO) ===');
    
    final validos = emails.where((e) => e.endereco.isNotEmpty).toList();
    
    await _supabase
        .from('email')
        .delete()
        .eq('contato_id', contatoId);

    List<EmailModel> salvos = [];
    for (var email in validos) {
      final data = {
        'contato_id': contatoId,
        'uso': email.uso,
        'endereco': email.endereco,
        'obs': email.obs,
      };
      
      try {
```

### lib/services/operacional/empresa_service.dart
```dart
/// ============================================
/// SERVIÇO: Empresa
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/empresa_model.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';

class EmpresaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // CRUD PRINCIPAL
  // ============================================

  Future<List<EmpresaModel>> list() async {
    try {
      final response = await _supabase
          .from('empresa')
          .select()
          .order('nome', ascending: true);
      
      return (response as List)
          .map((item) => EmpresaModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar empresas: $e');
    }
  }

  Future<EmpresaModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('empresa')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return EmpresaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar empresa: $e');
    }
  }

  Future<EmpresaModel> create(Map<String, dynamic> data) async {
    try {
      // Criar contato principal
      final contatoData = {
        'nome': data['nome'],
        'tipo_vinculo': 'EMPRESA',
      };
      
      final contatoResponse = await _supabase
          .from('contato')
          .insert(contatoData)
          .select()
          .single();
      
      data['contato_principal'] = contatoResponse['id'];
      
      final response = await _supabase
          .from('empresa')
          .insert(data)
          .select()
          .single();
      
      return EmpresaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar empresa: $e');
    }
  }

  Future<EmpresaModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
```

### lib/services/operacional/search_service.dart
```dart
/// ============================================
/// SERVIÇO: Pesquisa Avançada
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/empresa_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';

class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ContatoModel>> searchContatos({
    String? query,
    String? tipoVinculo,
    String? cidade,
    String? estado,
  }) async {
    try {
      var queryBuilder = _supabase.from('contato').select();
      
      if (tipoVinculo != null && tipoVinculo.isNotEmpty) {
        queryBuilder = queryBuilder.eq('tipo_vinculo', tipoVinculo);
      }

      final response = await queryBuilder;
      List<ContatoModel> contatos = (response as List)
          .map((item) => ContatoModel.fromJson(item))
          .toList();

      // Buscar relacionamentos
      for (var i = 0; i < contatos.length; i++) {
        final telefones = await _getTelefones(contatos[i].id);
        final emails = await _getEmails(contatos[i].id);
        final enderecos = await _getEnderecos(contatos[i].id);
        final midias = await _getMidias(contatos[i].id);
        
        contatos[i] = contatos[i].copyWith(
          telefones: telefones,
          emails: emails,
          enderecos: enderecos,
          midias: midias,
        );
      }

      // Aplicar filtros de pesquisa
      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        contatos = contatos.where((contato) {
          if (contato.nome.toLowerCase().contains(searchLower)) return true;
          if (contato.cpf != null && contato.cpf!.contains(searchLower)) return true;
          
          for (var tel in contato.telefones) {
            if (tel.numero.contains(searchLower)) return true;
          }
          for (var email in contato.emails) {
            if (email.endereco.toLowerCase().contains(searchLower)) return true;
          }
          for (var end in contato.enderecos) {
            if (end.logradouro.toLowerCase().contains(searchLower)) return true;
            if (end.bairro != null && end.bairro!.toLowerCase().contains(searchLower)) return true;
            if (end.cidade.toLowerCase().contains(searchLower)) return true;
            if (end.cep != null && end.cep!.contains(searchLower)) return true;
          }
          for (var midia in contato.midias) {
            if (midia.descricao.toLowerCase().contains(searchLower)) return true;
            if (midia.nomeDoApp != null && midia.nomeDoApp!.toLowerCase().contains(searchLower)) return true;
          }
          return false;
        }).toList();
      }

      if (cidade != null && cidade.isNotEmpty) {
        contatos = contatos.where((contato) {
          return contato.enderecos.any((end) => 
            end.cidade.toLowerCase().contains(cidade.toLowerCase())
          );
```

### lib/services/operacional/endereco_service.dart
```dart
/// ============================================
/// SERVIÇO: Endereco
/// ============================================
/// Gerencia operações CRUD para a tabela endereco
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/endereco_model.dart';

class EnderecoService {
  final BaseService<EnderecoModel> _service = BaseService<EnderecoModel>(
    tableName: 'endereco',
    fromJson: (json) => EnderecoModel.fromJson(json),
  );

  /// Lista todos os endereços
  Future<List<EnderecoModel>> list() async {
    return _service.list();
  }

  /// Busca um endereço por ID
  Future<EnderecoModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria um novo endereço
  Future<EnderecoModel> create(Map<String, dynamic> data) async {
    return _service.create(data);
  }

  /// Atualiza um endereço
  Future<EnderecoModel> update(String id, Map<String, dynamic> data) async {
    return _service.update(id, data);
  }

  /// Deleta um endereço
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  /// Busca endereços por contato
  Future<List<EnderecoModel>> findByContato(String contatoId) async {
    return _service.findBy('contato_id', contatoId);
  }
}
```

### lib/services/operacional/base_service.dart
```dart
/// ============================================
/// SERVIÇO BASE - CRUD GENÉRICO (SIMPLIFICADO)
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';

class BaseService<T> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName;
  final T Function(Map<String, dynamic>) fromJson;

  BaseService({
    required this.tableName,
    required this.fromJson,
  });

  /// ============================================
  /// LISTAR TODOS OS REGISTROS
  /// ============================================
  Future<List<T>> list() async {
    try {
      final response = await _supabase.from(tableName).select();
      return (response as List)
          .map((item) => fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar $tableName: $e');
    }
  }

  /// ============================================
  /// BUSCAR REGISTRO POR ID
  /// ============================================
  Future<T?> getById(String id) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar $tableName: $e');
    }
  }

  /// ============================================
  /// CRIAR NOVO REGISTRO
  /// ============================================
  Future<T> create(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();
      
      return fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar $tableName: $e');
    }
  }

  /// ============================================
  /// ATUALIZAR REGISTRO
  /// ============================================
  Future<T> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      
      return fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar $tableName: $e');
```

### lib/services/operacional/telefone_service.dart
```dart
/// ============================================
/// SERVIÇO: Telefone
/// ============================================
/// Gerencia operações CRUD para a tabela telefone
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/telefone_model.dart';

class TelefoneService {
  final BaseService<TelefoneModel> _service = BaseService<TelefoneModel>(
    tableName: 'telefone',
    fromJson: (json) => TelefoneModel.fromJson(json),
  );

  /// Lista todos os telefones
  Future<List<TelefoneModel>> list() async {
    return _service.list();
  }

  /// Busca um telefone por ID
  Future<TelefoneModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria um novo telefone
  Future<TelefoneModel> create(Map<String, dynamic> data) async {
    return _service.create(data);
  }

  /// Atualiza um telefone
  Future<TelefoneModel> update(String id, Map<String, dynamic> data) async {
    return _service.update(id, data);
  }

  /// Deleta um telefone
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  /// Busca telefones por contato
  Future<List<TelefoneModel>> findByContato(String contatoId) async {
    return _service.findBy('contato_id', contatoId);
  }
}
```

### lib/services/operacional/email_service.dart
```dart
/// ============================================
/// SERVIÇO: Email
/// ============================================
/// Gerencia operações CRUD para a tabela email
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/email_model.dart';

class EmailService {
  final BaseService<EmailModel> _service = BaseService<EmailModel>(
    tableName: 'email',
    fromJson: (json) => EmailModel.fromJson(json),
  );

  /// Lista todos os emails
  Future<List<EmailModel>> list() async {
    return _service.list();
  }

  /// Busca um email por ID
  Future<EmailModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria um novo email
  Future<EmailModel> create(Map<String, dynamic> data) async {
    return _service.create(data);
  }

  /// Atualiza um email
  Future<EmailModel> update(String id, Map<String, dynamic> data) async {
    return _service.update(id, data);
  }

  /// Deleta um email
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  /// Busca emails por contato
  Future<List<EmailModel>> findByContato(String contatoId) async {
    return _service.findBy('contato_id', contatoId);
  }
}
```

### lib/services/operacional/midias_service.dart
```dart
/// ============================================
/// SERVIÇO: Midias
/// ============================================
/// Gerencia operações CRUD para a tabela midias
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/midias_model.dart';

class MidiasService {
  final BaseService<MidiasModel> _service = BaseService<MidiasModel>(
    tableName: 'midias',
    fromJson: (json) => MidiasModel.fromJson(json),
  );

  /// Lista todas as mídias
  Future<List<MidiasModel>> list() async {
    return _service.list();
  }

  /// Busca uma mídia por ID
  Future<MidiasModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria uma nova mídia
  Future<MidiasModel> create(Map<String, dynamic> data) async {
    return _service.create(data);
  }

  /// Atualiza uma mídia
  Future<MidiasModel> update(String id, Map<String, dynamic> data) async {
    return _service.update(id, data);
  }

  /// Deleta uma mídia
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  /// Busca mídias por contato
  Future<List<MidiasModel>> findByContato(String contatoId) async {
    return _service.findBy('contato_id', contatoId);
  }
}
```

### lib/services/operacional/funcao_service.dart
```dart
/// ============================================
/// SERVIÇO: Funcao
/// ============================================
/// Gerencia operações CRUD para a tabela funcao
/// ============================================

import '../operacional/base_service.dart';
import '../../models/operacional/funcao_model.dart';

class FuncaoService {
  final BaseService<FuncaoModel> _service = BaseService<FuncaoModel>(
    tableName: 'funcao',
    fromJson: (json) => FuncaoModel.fromJson(json),
  );

  /// Lista todas as funções
  Future<List<FuncaoModel>> list() async {
    return _service.list();
  }

  /// Busca uma função por ID
  Future<FuncaoModel?> getById(String id) async {
    return _service.getById(id);
  }

  /// Cria uma nova função
  Future<FuncaoModel> create(String descricao) async {
    return _service.create({'descricao': descricao});
  }

  /// Atualiza uma função
  Future<FuncaoModel> update(String id, String descricao) async {
    return _service.update(id, {'descricao': descricao});
  }

  /// Deleta uma função
  Future<void> delete(String id) async {
    await _service.delete(id);
  }
}
```

### lib/services/operacional/contato_service.dart
```dart
/// ============================================
/// SERVIÇO: Contato
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midias_model.dart';

class ContatoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ContatoModel>> list() async {
    try {
      // ⭐ Buscar apenas contatos (excluir empresas)
      final response = await _supabase
          .from('contato')
          .select()
          .neq('tipo_vinculo', 'EMPRESA')  // ⭐ FILTRO: exclui registros do tipo EMPRESA
          .order('nome', ascending: true);
      
      return (response as List)
          .map((item) => ContatoModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar contatos: $e');
    }
  }

  Future<ContatoModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('contato')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar contato: $e');
    }
  }

  Future<ContatoModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('contato')
          .insert(data)
          .select()
          .single();
      
      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar contato: $e');
    }
  }

  Future<ContatoModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('contato')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      
      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar contato: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _supabase
          .from('contato')
          .delete()
```

## 🖥️ Telas/Páginas
### lib/screens/operacional/empresa_unified_screen.dart
```dart
/// ============================================
/// TELA UNIFICADA: Empresa + Relacionamentos
/// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/empresa_provider.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/operacional_models.dart';
import '../../widgets/operacional/telefone_list_widget.dart';
import '../../widgets/operacional/email_list_widget.dart';
import '../../widgets/operacional/endereco_list_widget.dart';
import '../../widgets/operacional/midias_list_widget.dart';
import '../../widgets/operacional/contatos_vinculados_widget.dart';
import '../../theme/app_theme.dart';
import 'contato_unified_screen.dart';

class EmpresaUnifiedScreen extends StatefulWidget {
  final String? empresaId;

  const EmpresaUnifiedScreen({super.key, this.empresaId});

  @override
  State<EmpresaUnifiedScreen> createState() => _EmpresaUnifiedScreenState();
}

class _EmpresaUnifiedScreenState extends State<EmpresaUnifiedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _razaoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _ieController = TextEditingController();
  final _obsController = TextEditingController();

  String _qualif = 'FORNECEDOR';
  String _tipoContr = 'CNPJ';
  bool _isEditing = false;
  bool _isLoading = false;

  List<ContatoModel> _contatos = [];
  List<TelefoneModel> _telefones = [];
  List<EmailModel> _emails = [];
  List<EnderecoModel> _enderecos = [];
  List<MidiasModel> _midias = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.empresaId != null;
    if (_isEditing) {
      _loadEmpresaData();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _razaoController.dispose();
    _cnpjController.dispose();
    _ieController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _loadEmpresaData() async {
    setState(() => _isLoading = true);
    final provider = context.read<EmpresaProvider>();
    await provider.loadEmpresaById(widget.empresaId!);

    final empresa = provider.selectedEmpresa;
    if (empresa != null && mounted) {
      setState(() {
        _nomeController.text = empresa.nome;
        _razaoController.text = empresa.razaoSocial;
        _qualif = empresa.qualif;
        _tipoContr = empresa.tipoContr;
        _cnpjController.text = empresa.cnpj ?? '';
        _ieController.text = empresa.ie ?? '';
```

### lib/screens/operacional/contato_list_screen.dart
```dart
/// ============================================
/// TELA: Lista de Contatos
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/contato_model.dart';
import '../../theme/app_theme.dart';

class ContatoListScreen extends StatefulWidget {
  const ContatoListScreen({super.key});

  @override
  State<ContatoListScreen> createState() => _ContatoListScreenState();
}

class _ContatoListScreenState extends State<ContatoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContatoProvider>().loadContatos();
    });
  }

  // ⭐ CORRIGIDO: Usar context.go com verificação mounted
  void _goBack() {
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos - Operacional'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
          tooltip: 'Voltar para o Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/operacional/contatos/novo'),
            tooltip: 'Novo Contato',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ContatoProvider>().loadContatos(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<ContatoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.contatos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando contatos...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
```

### lib/screens/operacional/empresa_list_screen.dart
```dart
/// ============================================
/// TELA: Lista de Empresas
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/empresa_provider.dart';
import '../../models/operacional/empresa_model.dart';
import '../../theme/app_theme.dart';

class EmpresaListScreen extends StatefulWidget {
  const EmpresaListScreen({super.key});

  @override
  State<EmpresaListScreen> createState() => _EmpresaListScreenState();
}

class _EmpresaListScreenState extends State<EmpresaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmpresaProvider>().loadEmpresas();
    });
  }

  // ⭐ CORRIGIDO: Usar context.go com verificação mounted
  void _goBack() {
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas - Operacional'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
          tooltip: 'Voltar para o Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/operacional/empresas/novo'),
            tooltip: 'Nova Empresa',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<EmpresaProvider>().loadEmpresas(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<EmpresaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.empresas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando empresas...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
```

### lib/screens/operacional/contato_form_screen.dart
```dart
/// ============================================
/// TELA: Formulário de Contato
/// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/contato_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

class ContatoFormScreen extends StatefulWidget {
  final String? contatoId;

  const ContatoFormScreen({super.key, this.contatoId});

  @override
  State<ContatoFormScreen> createState() => _ContatoFormScreenState();
}

class _ContatoFormScreenState extends State<ContatoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _obsController = TextEditingController();

  String _tipoVinculo = 'EXTERNO';
  String? _genero;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.contatoId != null;
    
    if (_isEditing) {
      _loadContatoData();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _loadContatoData() async {
    final provider = context.read<ContatoProvider>();
    await provider.loadContatoById(widget.contatoId!);
    
    final contato = provider.selectedContato;
    if (contato != null && mounted) {
      setState(() {
        _nomeController.text = contato.nome;
        _tipoVinculo = contato.tipoVinculo;
        _genero = contato.genero;
        _cpfController.text = contato.cpf ?? '';
        _rgController.text = contato.rg ?? '';
        _obsController.text = contato.obs ?? '';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'nome': _nomeController.text.trim(),
      'tipo_vinculo': _tipoVinculo,
      'genero': _genero,
      'cpf': _cpfController.text.replaceAll(RegExp(r'\D'), ''),
```

### lib/screens/operacional/contato_unified_screen.dart
```dart
/// ============================================
/// TELA UNIFICADA: Contato + Relacionamentos
/// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../providers/operacional/empresa_provider.dart';
import '../../models/operacional/operacional_models.dart';
import '../../widgets/operacional/telefone_list_widget.dart';
import '../../widgets/operacional/email_list_widget.dart';
import '../../widgets/operacional/endereco_list_widget.dart';
import '../../widgets/operacional/midias_list_widget.dart';
import '../../theme/app_theme.dart';

class ContatoUnifiedScreen extends StatefulWidget {
  final String? contatoId;
  final String? empresaId;

  const ContatoUnifiedScreen({super.key, this.contatoId, this.empresaId});

  @override
  State<ContatoUnifiedScreen> createState() => _ContatoUnifiedScreenState();
}

class _ContatoUnifiedScreenState extends State<ContatoUnifiedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _obsController = TextEditingController();

  String _tipoVinculo = 'EXTERNO';
  String? _genero;
  bool _isEditing = false;
  bool _isLoading = false;

  List<TelefoneModel> _telefones = [];
  List<EmailModel> _emails = [];
  List<EnderecoModel> _enderecos = [];
  List<MidiasModel> _midias = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.contatoId != null;
    if (_isEditing) {
      _loadContatoData();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _loadContatoData() async {
    setState(() => _isLoading = true);
    final provider = context.read<ContatoProvider>();
    await provider.loadContatoById(widget.contatoId!);

    final contato = provider.selectedContato;
    if (contato != null && mounted) {
      setState(() {
        _nomeController.text = contato.nome;
        _tipoVinculo = contato.tipoVinculo;
        _genero = contato.genero;
        _cpfController.text = contato.cpf ?? '';
        _rgController.text = contato.rg ?? '';
        _obsController.text = contato.obs ?? '';
        _telefones = List.from(contato.telefones);
        _emails = List.from(contato.emails);
        _enderecos = List.from(contato.enderecos);
        _midias = List.from(contato.midias);
```

### lib/screens/operacional/contato_detail_screen.dart
```dart
/// ============================================
/// TELA: Detalhes do Contato
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/contato_provider.dart';
import '../../models/operacional/contato_model.dart';
import '../../widgets/operacional/telefone_list_widget.dart';
import '../../widgets/operacional/email_list_widget.dart';
import '../../widgets/operacional/endereco_list_widget.dart';
import '../../widgets/operacional/midias_list_widget.dart';
import '../../theme/app_theme.dart';

class ContatoDetailScreen extends StatefulWidget {
  final String contatoId;

  const ContatoDetailScreen({super.key, required this.contatoId});

  @override
  State<ContatoDetailScreen> createState() => _ContatoDetailScreenState();
}

class _ContatoDetailScreenState extends State<ContatoDetailScreen> {
  late ContatoModel _contato;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<ContatoProvider>();
    await provider.loadContatoById(widget.contatoId);
    if (mounted) {
      setState(() {
        _contato = provider.selectedContato!;
        _isLoading = false;
      });
    }
  }

  void _goBack() {
    if (mounted) {
      context.go('/operacional/contatos');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_contato.nome),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (mounted) {
                context.go('/operacional/contatos/editar/${_contato.id}');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
```

### lib/screens/login_screen_simple.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service_simple.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/logo_widget.dart';

class LoginScreenSimple extends StatefulWidget {
  const LoginScreenSimple({super.key});

  @override
  State<LoginScreenSimple> createState() => _LoginScreenSimpleState();
}

class _LoginScreenSimpleState extends State<LoginScreenSimple> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo(a), ${user.displayName}!'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppTheme.dangerColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
```

### lib/screens/login_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo(a), ${user.displayName}!'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppTheme.dangerColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
```

### lib/screens/home_screen.dart
```dart
/// ============================================
/// TELA: HOME / DASHBOARD
/// ============================================
/// Exibe o menu principal com todas as aplicações
/// do sistema SocialFlow
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String _userName = 'Usuário';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _userName = _authService.getUserName();
    _userEmail = _authService.getUserEmail();
  }

  /// ============================================
  /// LOGOUT
  /// ============================================
  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  /// ============================================
  /// NAVEGAÇÃO PARA MÓDULOS
  /// ============================================
  void _navigateTo(String route) {
    if (mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialFlow'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
```

## 🎨 Temas e Estilos
### lib/theme/app_theme.dart
```dart
import 'package:flutter/material.dart';

/// Tema do SocialFlow
/// Define as cores e estilos padrão do sistema
class AppTheme {
  // Cores primárias
  static const Color primaryColor = Color(0xFF2563EB); // Azul SocialFlow
  static const Color secondaryColor = Color(0xFF7C3AED); // Roxo
  static const Color successColor = Color(0xFF10B981); // Verde
  static const Color dangerColor = Color(0xFFEF4444); // Vermelho
  static const Color warningColor = Color(0xFFF59E0B); // Amarelo

  // Cores de texto
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Cores de fundo
  static const Color backgroundLight = Color(0xFFF3F4F6);
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  /// Tema claro do aplicativo
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: dangerColor,
      surface: backgroundWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
```

## ⚙️ Configurações
### ./web/manifest.json
```
{
    "name": "meu_backend",
    "short_name": "meu_backend",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "A new Flutter project.",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-maskable-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "maskable"
        },
        {
            "src": "icons/Icon-maskable-512.png",
            "sizes": "512x512",
```

### ./analysis_options.yaml
```
# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/flutter.yaml

linter:
  # The lint rules applied to this project can be customized in the
  # section below to disable rules from the `package:flutter_lints/flutter.yaml`
  # included above or to enable additional rules. A list of all available lints
  # and their documentation is published at https://dart.dev/lints.
  #
  # Instead of disabling a lint rule for the entire project in the
  # section below, it can also be suppressed for a single line of code
  # or a specific dart file by using the `// ignore: name_of_lint` and
  # `// ignore_for_file: name_of_lint` syntax on the line or in the file
  # producing the lint.
  rules:
    # avoid_print: false  # Uncomment to disable the `avoid_print` rule
    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule

# Additional information about this file can be found at
# https://dart.dev/guides/language/analysis-options
```

### ./.dart_tool/package_config.json
```
{
  "configVersion": 2,
  "packages": [
    {
      "name": "adaptive_number",
      "rootUri": "file:///Users/khambay/.pub-cache/hosted/pub.dev/adaptive_number-1.0.0",
      "packageUri": "lib/",
      "languageVersion": "2.12"
    },
    {
      "name": "app_links",
      "rootUri": "file:///Users/khambay/.pub-cache/hosted/pub.dev/app_links-7.0.0",
      "packageUri": "lib/",
      "languageVersion": "3.10"
    },
    {
      "name": "app_links_linux",
      "rootUri": "file:///Users/khambay/.pub-cache/hosted/pub.dev/app_links_linux-1.0.3",
      "packageUri": "lib/",
      "languageVersion": "3.2"
    },
    {
      "name": "app_links_platform_interface",
      "rootUri": "file:///Users/khambay/.pub-cache/hosted/pub.dev/app_links_platform_interface-2.0.2",
      "packageUri": "lib/",
      "languageVersion": "3.2"
    },
    {
      "name": "app_links_web",
      "rootUri": "file:///Users/khambay/.pub-cache/hosted/pub.dev/app_links_web-1.0.4",
```

### ./.dart_tool/extension_discovery/vs_code.json
```
{"version":2,"entries":[{"package":"meu_backend","rootUri":"../","packageUri":"lib/"}]}```

### ./.dart_tool/package_graph.json
```
{
  "roots": [
    "meu_backend"
  ],
  "packages": [
    {
      "name": "meu_backend",
      "version": "1.0.0+1",
      "dependencies": [
        "crypto",
        "cupertino_icons",
        "encrypt",
        "flutter",
        "flutter_dotenv",
        "flutter_form_builder",
        "flutter_local_notifications",
        "flutter_spinkit",
        "go_router",
        "provider",
        "supabase_flutter",
        "universal_html"
      ],
      "devDependencies": [
        "flutter_lints",
        "flutter_test"
      ]
    },
    {
      "name": "flutter_lints",
      "version": "5.0.0",
```

