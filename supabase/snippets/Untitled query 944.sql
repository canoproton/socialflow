WITH totais_aportados AS (
    SELECT 
        destino_alocao_id as projeto_id,
        SUM(valor_alocado) as total_aportado
    FROM fonte_alocacao
    GROUP BY destino_alocao_id
)
UPDATE projeto p
SET valor_total_aportado = COALESCE(ta.total_aportado, 0)
FROM totais_aportados ta
WHERE p.id = ta.projeto_id;