/// ============================================
/// TELA: Lista de Alocações (com Extrato Bancário)
/// REGRA 7
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/fonte_alocacao_model.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../models/projetos/projeto_model.dart';
import '../../services/projetos/fontes_base_service.dart';
import '../../services/projetos/projeto_service.dart';
import '../../theme/app_theme.dart';

class FonteAlocacaoListScreen extends StatefulWidget {
  final String? fonteId;

  const FonteAlocacaoListScreen({super.key, this.fonteId});

  @override
  State<FonteAlocacaoListScreen> createState() => _FonteAlocacaoListScreenState();
}

class _FonteAlocacaoListScreenState extends State<FonteAlocacaoListScreen> {
  final FontesBaseService _service = FontesBaseService();
  final ProjetoService _projetoService = ProjetoService();
  
  List<FonteAlocacaoModel> _alocacoes = [];
  List<FontesBaseModel> _fontes = [];
  List<Projeto> _projetos = [];
  FontesBaseModel? _fonteSelecionada;
  bool _isLoading = false;
  String? _error;

  // ⭐ FILTROS
  String? _fonteFilter;
  String? _entidadeFilter;
  DateTime? _dataInicioFilter;
  DateTime? _dataFimFilter;
  bool _apenasComSaldo = false;

  // ⭐ CONTROLLERS
  final TextEditingController _entidadeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fonteFilter = widget.fonteId;
    _carregarDados();
    _carregarFontesEProjetos();
  }

  Future<void> _carregarFontesEProjetos() async {
    try {
      _fontes = await _service.list();
      _projetos = await _projetoService.list();
      setState(() {});
    } catch (e) {
      print('Erro ao carregar fontes/projetos: $e');
    }
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ⭐ BUSCAR ALOÇAÇÕES COM FILTROS
      if (_fonteFilter != null) {
        _fonteSelecionada = _fontes.firstWhere(
          (f) => f.id == _fonteFilter,
          orElse: () => _fontes.first,
        );
        _alocacoes = await _service.getAlocacoes(_fonteFilter!);
      } else {
        _alocacoes = await _service.getAllAlocacoes();
        _fonteSelecionada = null;
      }

      // ⭐ APLICAR FILTROS ADICIONAIS
      _alocacoes = _alocacoes.where((aloc) {
        // Filtro por entidade
        if (_entidadeFilter != null && _entidadeFilter!.isNotEmpty) {
          final fonte = _fontes.firstWhere(
            (f) => f.id == aloc.fonteAlocacaoId,
            orElse: () => FontesBaseModel(
              id: '',
              descricao: '',
              entidade: '',
              valorRecurso: 0,
            ),
          );
          if (!fonte.entidade.toLowerCase().contains(_entidadeFilter!.toLowerCase())) {
            return false;
          }
        }

        // Filtro por data
        if (_dataInicioFilter != null && aloc.dataAlocacao != null) {
          if (aloc.dataAlocacao!.isBefore(_dataInicioFilter!)) {
            return false;
          }
        }
        if (_dataFimFilter != null && aloc.dataAlocacao != null) {
          if (aloc.dataAlocacao!.isAfter(_dataFimFilter!)) {
            return false;
          }
        }

        return true;
      }).toList();

      // ⭐ ORDENAR POR DATA (mais antiga primeiro - extrato)
      _alocacoes.sort((a, b) {
        if (a.dataAlocacao == null && b.dataAlocacao == null) return 0;
        if (a.dataAlocacao == null) return 1;
        if (b.dataAlocacao == null) return -1;
        return a.dataAlocacao!.compareTo(b.dataAlocacao!);
      });

      // ⭐ ATUALIZAR SALDO DA FONTE SELECIONADA
      if (_fonteSelecionada != null) {
        double totalAlocado = 0;
        for (var aloc in _alocacoes) {
          totalAlocado += aloc.valorAlocado;
        }
        _fonteSelecionada!.atualizarTotais(totalAlocado);
      }

      print('📋 [ALOCACAO_LIST] Carregadas ${_alocacoes.length} alocações');
    } catch (e) {
      _error = e.toString();
      print('❌ [ALOCACAO_LIST] Erro: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getNomeProjeto(String projetoId) {
    if (projetoId.isEmpty) return 'Não definido';
    final projeto = _projetos.firstWhere(
      (p) => p.id == projetoId,
      orElse: () => Projeto(
        id: projetoId,
        descricao: 'Projeto não encontrado',
        statusProjeto: 'ORÇAMENTO',
        metas: [],
      ),
    );
    return projeto.descricao ?? 'Projeto sem título';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _fonteFilter != null && _fonteSelecionada != null
              ? 'Extrato - ${_fonteSelecionada!.descricao}'
              : 'Todas as Alocações',
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/projetos/fontes'),
          tooltip: 'Voltar',
        ),
        actions: [
          if (_fonteFilter != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.go('/projetos/fontes/alocacao/novo?fonteId=${_fonteFilter}');
              },
              tooltip: 'Nova Alocação',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // ⭐ FILTROS
          _buildFiltros(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  // ============================================
  // FILTROS
  // ============================================

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ⭐ FILTRO POR FONTE
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _fonteFilter,
                  hint: const Text('Fonte de Recurso'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todas as fontes'),
                    ),
                    ..._fontes.map((fonte) {
                      return DropdownMenuItem(
                        value: fonte.id,
                        child: Text(
                          '${fonte.descricao} (${_formatCurrency(fonte.saldo)})',
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _fonteFilter = value;
                      _carregarDados();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              // ⭐ FILTRO RÁPIDO
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: null,
                  hint: const Text('Filtro Rápido'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'todas',
                      child: Text('Todas as fontes'),
                    ),
                    const DropdownMenuItem(
                      value: 'com_saldo',
                      child: Text('Fontes com saldo'),
                    ),
                    const DropdownMenuItem(
                      value: 'sem_saldo',
                      child: Text('Fontes sem saldo'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == 'com_saldo') {
                      setState(() => _apenasComSaldo = true);
                    } else if (value == 'sem_saldo') {
                      setState(() => _apenasComSaldo = false);
                    } else {
                      setState(() => _apenasComSaldo = false);
                    }
                    _carregarDados();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // ⭐ FILTRO POR ENTIDADE
              Expanded(
                child: TextField(
                  controller: _entidadeController,
                  decoration: InputDecoration(
                    hintText: 'Filtrar por Entidade',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                    prefixIcon: const Icon(Icons.business, size: 18),
                    suffixIcon: _entidadeController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _entidadeController.clear();
                              setState(() {
                                _entidadeFilter = null;
                                _carregarDados();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _entidadeFilter = value.isNotEmpty ? value : null;
                      _carregarDados();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              // ⭐ DATA INÍCIO
              Expanded(
                child: InkWell(
                  onTap: () => _selecionarData(
                    context,
                    (date) {
                      setState(() {
                        _dataInicioFilter = date;
                        _carregarDados();
                      });
                    },
                    _dataInicioFilter,
                    'Data Início',
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _dataInicioFilter != null
                                ? 'Início: ${_formatDate(_dataInicioFilter)}'
                                : 'Data Início',
                            style: TextStyle(
                              color: _dataInicioFilter != null
                                  ? Colors.black
                                  : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (_dataInicioFilter != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 14, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _dataInicioFilter = null;
                                _carregarDados();
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ⭐ DATA FIM
              Expanded(
                child: InkWell(
                  onTap: () => _selecionarData(
                    context,
                    (date) {
                      setState(() {
                        _dataFimFilter = date;
                        _carregarDados();
                      });
                    },
                    _dataFimFilter,
                    'Data Fim',
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _dataFimFilter != null
                                ? 'Fim: ${_formatDate(_dataFimFilter)}'
                                : 'Data Fim',
                            style: TextStyle(
                              color: _dataFimFilter != null
                                  ? Colors.black
                                  : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (_dataFimFilter != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 14, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _dataFimFilter = null;
                                _carregarDados();
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarData(
    BuildContext context,
    Function(DateTime) onSelected,
    DateTime? current,
    String label,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  // ============================================
  // BODY
  // ============================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_alocacoes.isEmpty && _fonteSelecionada == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 64, color: AppTheme.textLight),
            SizedBox(height: 16),
            Text('Nenhuma alocação encontrada'),
            SizedBox(height: 8),
            Text(
              'Selecione uma fonte ou ajuste os filtros',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _alocacoes.length + 1, // +1 para o saldo inicial
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSaldoInicial();
        }
        final alocacaoIndex = index - 1;
        final alocacao = _alocacoes[alocacaoIndex];
        return _buildExtratoItem(alocacao, alocacaoIndex);
      },
    );
  }

  // ⭐ SALDO INICIAL
  Widget _buildSaldoInicial() {
    // ⭐ PEGAR O VALOR TOTAL DO RECURSO
    final valorTotal = _fonteSelecionada?.valorRecurso ?? 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.blue.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SALDO INICIAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    _fonteSelecionada != null
                        ? '${_fonteSelecionada!.descricao} - ${_fonteSelecionada!.entidade}'
                        : 'Entrada do recurso na fonte',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(valorTotal),
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Saldo: ${_formatCurrency(valorTotal)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ ITEM DO EXTRATO
  Widget _buildExtratoItem(FonteAlocacaoModel alocacao, int index) {
    // ⭐ CALCULAR SALDO ACUMULADO - COMEÇANDO DO VALOR TOTAL
    double saldo = _fonteSelecionada?.valorRecurso ?? 0;
    
    // ⭐ SUBTRAIR AS ALOÇAÇÕES ANTERIORES
    for (var i = 0; i <= index && i < _alocacoes.length; i++) {
      saldo -= _alocacoes[i].valorAlocado;
    }

    // ⭐ CALCULAR PERCENTUAL ALOCADO
    final valorTotal = _fonteSelecionada?.valorRecurso ?? 0;
    final percentual = valorTotal > 0 ? (alocacao.valorAlocado / valorTotal) * 100 : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            // ⭐ CONTEÚDO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alocacao.descricao,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Destino: ${_getNomeProjeto(alocacao.destinoAlocacaoId)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (alocacao.dataAlocacao != null)
                    Text(
                      _formatDate(alocacao.dataAlocacao),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            
            // ⭐ VALORES
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- ${_formatCurrency(alocacao.valorAlocado)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${percentual.toStringAsFixed(1)}% do total',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Saldo: ${_formatCurrency(saldo)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: saldo >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            
            // ⭐ BOTÃO EXCLUIR
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _confirmDelete(alocacao),
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(FonteAlocacaoModel alocacao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir esta alocação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.deleteAlocacao(alocacao.id);
                await _carregarDados();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alocação excluída com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}