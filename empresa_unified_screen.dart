Future<void> _salvar() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final data = {
      'nome': _nomeController.text,
      'razaoSocial': _razaoController.text,
      'qualif': _qualif,
      'tipoContr': _tipoContr,
      'cnpj': _cnpjController.text,
      'ie': _ieController.text,
      'obs': _obsController.text,
      'contatos': _contatos,
      'telefones': _telefones,
      'emails': _emails,
      'enderecos': _enderecos,
      'midias': _midias,
    };

    final provider = context.read<EmpresaProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateEmpresa(widget.empresaId!, data);
    } else {
      success = await provider.createEmpresa(data);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Empresa atualizada!' : 'Empresa criada!'),
          backgroundColor: Colors.green,
        ),
      );
      // ⭐ CORRIGIDO: redireciona para /operacional (singular)
      context.go('/operacional');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}