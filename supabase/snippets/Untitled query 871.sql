-- Verificar TODAS as colunas da tabela fonte_alocacao
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'fonte_alocacao'
ORDER BY ordinal_position;