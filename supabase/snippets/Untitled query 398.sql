SELECT 
    f.descricao as fonte,
    f.entidade,
    f.valor_recurso as valor_total_fonte,
    fa.descricao as alocacao,
    fa.valor_alocado,
    fa.saldo_recurso,
    fa.data_alocacao,
    p.descricao as projeto_destino,
    p.valor_total_aportado
FROM fontes_base f
JOIN fonte_alocacao fa ON fa.fonte_alocacao_id = f.id
JOIN projeto p ON p.id = fa.destino_alocao_id
ORDER BY f.descricao, fa.data_alocacao;