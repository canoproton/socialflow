-- Ver todos os saldos
SELECT 
    fb.id,
    fb.descricao,
    fb.entidade,
    fb.valor_recurso,
    COALESCE(SUM(fa.valor_alocado), 0) AS total_alocado,
    fb.valor_recurso - COALESCE(SUM(fa.valor_alocado), 0) AS saldo_atual
FROM fontes_base fb
LEFT JOIN fontes_alocacao fa ON fa.fonte_alocacao_id = fb.id
GROUP BY fb.id, fb.descricao, fb.entidade, fb.valor_recurso
ORDER BY fb.descricao;