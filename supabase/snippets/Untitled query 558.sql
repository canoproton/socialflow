-- Verifica todas as alocações com nomes das fontes
SELECT 
    fa.id,
    f.descricao as fonte,
    fa.descricao as alocacao,
    fa.valor_alocado,
    p.descricao as projeto,
    fa.data_alocacao
FROM fonte_alocacao fa
JOIN fontes_base f ON f.id = fa.fonte_alocacao_id
LEFT JOIN projeto p ON p.id = fa.destino_alocao
ORDER BY f.descricao, fa.data_alocacao;