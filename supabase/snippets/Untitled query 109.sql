SELECT 
    fa.id,
    fa.fonte_alocacao_id,
    fa.descricao
FROM fonte_alocacao fa
LEFT JOIN fontes_base f ON f.id = fa.fonte_alocacao_id
WHERE f.id IS NULL;