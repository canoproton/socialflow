-- Verifica todas as alocações com nomes corretos
SELECT 
    fa.id,
    f.descricao as fonte,
    fa.descricao as alocacao,
    fa.valor_alocado,
    p.descricao as projeto,
    fa.data_alocacao
FROM fonte_alocacao fa
JOIN fontes_base f ON f.id = fa.fonte_alocacao_id
LEFT JOIN projeto p ON p.id = fa.destino_alocao_id
ORDER BY f.descricao, fa.data_alocacao;

-- Verifica os totais por fonte
SELECT 
    f.id,
    f.descricao,
    f.valor_recurso,
    COALESCE(SUM(fa.valor_alocado), 0) as total_alocado,
    f.valor_recurso - COALESCE(SUM(fa.valor_alocado), 0) as saldo
FROM fontes_base f
LEFT JOIN fonte_alocacao fa ON fa.fonte_alocacao_id = f.id
GROUP BY f.id, f.descricao, f.valor_recurso
ORDER BY f.descricao;