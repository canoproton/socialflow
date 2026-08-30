SELECT 
    f.id,
    f.descricao as fonte,
    f.entidade,
    f.valor_recurso as valor_total,
    COALESCE(SUM(fa.valor_alocado), 0) as total_alocado,
    f.valor_recurso - COALESCE(SUM(fa.valor_alocado), 0) as saldo
FROM fontes_base f
LEFT JOIN fonte_alocacao fa ON fa.fonte_alocacao_id = f.id
GROUP BY f.id, f.descricao, f.entidade, f.valor_recurso
ORDER BY f.descricao;