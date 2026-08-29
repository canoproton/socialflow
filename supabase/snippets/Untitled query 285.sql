-- 1. Verifica a estrutura completa da tabela fonte_alocacao
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'fonte_alocacao'
ORDER BY ordinal_position;

-- 2. Verifica todas as alocações com os nomes corretos das colunas
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

-- 3. Verifica os totais por fonte
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

-- 4. Verifica os totais por projeto
SELECT 
    p.id,
    p.descricao,
    COALESCE(SUM(fa.valor_alocado), 0) as total_aportado
FROM projeto p
LEFT JOIN fonte_alocacao fa ON fa.destino_alocao_id = p.id
GROUP BY p.id, p.descricao
ORDER BY p.descricao;

-- 5. Verifica a estrutura das chaves estrangeiras
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name as foreign_table_name,
    ccu.column_name as foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'fonte_alocacao'
AND tc.constraint_type = 'FOREIGN KEY';