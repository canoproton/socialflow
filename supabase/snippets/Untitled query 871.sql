-- Verificar se existe uma coluna chamada 'fonte_id' ou similar
SELECT 
    column_name
FROM information_schema.columns 
WHERE table_name = 'fonte_alocacao'
    AND column_name LIKE '%fonte%'
ORDER BY column_name;