class ModuleModel {
  final String id;
  final String codigo;
  final String nome;
  final String? icone;
  final String? descricao;
  final int ordem;
  final bool isActive;

  ModuleModel({
    required this.id,
    required this.codigo,
    required this.nome,
    this.icone,
    this.descricao,
    this.ordem = 0,
    this.isActive = true,
  });

  static List<ModuleModel> get defaultModules {
    return [
      ModuleModel(id: '', codigo: 'DASHBOARD', nome: 'Dashboard', icone: 'dashboard', ordem: 0),
      ModuleModel(id: '', codigo: 'USUARIOS', nome: 'Usuários', icone: 'people', ordem: 1),
      ModuleModel(id: '', codigo: 'PROJETOS', nome: 'Projetos', icone: 'folder', ordem: 2),
      ModuleModel(id: '', codigo: 'TAREFAS', nome: 'Tarefas', icone: 'checklist', ordem: 3),
      ModuleModel(id: '', codigo: 'OPERACIONAL', nome: 'Operacional', icone: 'local_shipping', ordem: 4),
      ModuleModel(id: '', codigo: 'CONTABILIDADE', nome: 'Contabilidade', icone: 'account_balance', ordem: 5),
      ModuleModel(id: '', codigo: 'FINANCEIRO', nome: 'Financeiro', icone: 'attach_money', ordem: 6),
      ModuleModel(id: '', codigo: 'DOCUMENTOS', nome: 'Documentos', icone: 'folder_open', ordem: 7),
      ModuleModel(id: '', codigo: 'IA', nome: 'IA', icone: 'psychology', ordem: 8),
    ];
  }

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      icone: json['icone']?.toString(),
      descricao: json['descricao']?.toString(),
      ordem: json['ordem']?.toInt() ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'icone': icone,
      'descricao': descricao,
      'ordem': ordem,
      'is_active': isActive,
    };
  }
}
