/// ============================================
/// WIDGET: Pesquisa com Filtros
/// ============================================

import 'package:flutter/material.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/empresa_model.dart';
import '../../theme/app_theme.dart';

class SearchFiltersWidget extends StatefulWidget {
  final Function({
    String? query,
    String? tipoVinculo,
    String? qualif,
    String? cidade,
    String? estado,
  }) onSearch;
  final bool isEmpresa;

  const SearchFiltersWidget({
    super.key,
    required this.onSearch,
    this.isEmpresa = false,
  });

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  final TextEditingController _queryController = TextEditingController();
  String? _tipoVinculo;
  String? _qualif;
  String? _cidade;
  String? _estado;
  bool _showFilters = false;

  void _performSearch() {
    widget.onSearch(
      query: _queryController.text.isNotEmpty ? _queryController.text : null,
      tipoVinculo: _tipoVinculo,
      qualif: _qualif,
      cidade: _cidade,
      estado: _estado,
    );
  }

  void _clearFilters() {
    setState(() {
      _queryController.clear();
      _tipoVinculo = null;
      _qualif = null;
      _cidade = null;
      _estado = null;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Barra de pesquisa
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText: widget.isEmpresa 
                          ? 'Buscar empresa por nome, CNPJ, contato, endereço...'
                          : 'Buscar contato por nome, CPF, telefone, email...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _queryController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _queryController.clear());
                                _performSearch();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onChanged: (_) => _performSearch(),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list : Icons.filter_list_off,
                    color: _showFilters ? AppTheme.primaryColor : AppTheme.textLight,
                  ),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  tooltip: 'Filtros',
                ),
                if (_showFilters)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpar'),
                  ),
              ],
            ),
            
            // Filtros
            if (_showFilters) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Filtro por tipo de vínculo (Contato)
                  if (!widget.isEmpresa)
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        value: _tipoVinculo,
                        decoration: const InputDecoration(
                          labelText: 'Tipo Vínculo',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos')),
                          ...ContatoModel.tipoVinculoLabels.entries.map((entry) {
                            return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _tipoVinculo = value);
                          _performSearch();
                        },
                      ),
                    ),
                  
                  // Filtro por qualificação (Empresa)
                  if (widget.isEmpresa)
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        value: _qualif,
                        decoration: const InputDecoration(
                          labelText: 'Qualificação',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos')),
                          ...EmpresaModel.qualifLabels.entries.map((entry) {
                            return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _qualif = value);
                          _performSearch();
                        },
                      ),
                    ),
                  
                  // Filtro por cidade
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      onChanged: (value) {
                        setState(() => _cidade = value.isNotEmpty ? value : null);
                        _performSearch();
                      },
                    ),
                  ),
                  
                  // Filtro por estado
                  SizedBox(
                    width: 150,
                    child: DropdownButtonFormField<String>(
                      value: _estado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todos')),
                        ...EnderecoModel.estados.entries.map((entry) {
                          return DropdownMenuItem(value: entry.key, child: Text(entry.key));
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _estado = value);
                        _performSearch();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
