-- 1. Estrutura da tabela fontes_base
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'fontes_base'
ORDER BY ordinal_position;

-- 2. Estrutura da tabela fonte_alocacao
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'fonte_alocacao'
ORDER BY ordinal_position;

-- 3. Verifica as chaves estrangeiras
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
WHERE tc.table_name IN ('fontes_base', 'fonte_alocacao')
AND tc.constraint_type = 'FOREIGN KEY';

-- 4. Dados atuais das fontes
SELECT 
    id,
    descricao,
    entidade,
    valor_recurso,
    remanejamento,
    data_aprovacao,
    obs
FROM fontes_base
ORDER BY descricao;

-- 5. Dados atuais das alocações
SELECT 
    id,
    fonte_alocacao_id,
    destino_alocao_id,
    descricao,
    valor_alocado,
    data_alocacao,
    obs
FROM fonte_alocacao
ORDER BY data_alocacao;

-- 6. Verifica se o campo saldo_recurso existe
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'fonte_alocacao' 
AND column_name = 'saldo_recurso';

-- 7. Calcula o saldo real por fonte (para comparação)
SELECT 
    f.id as fonte_id,
    f.descricao as fonte_nome,
    f.entidade,
    f.valor_recurso as valor_total,
    COALESCE(SUM(fa.valor_alocado), 0) as total_alocado,
    f.valor_recurso - COALESCE(SUM(fa.valor_alocado), 0) as saldo_real
FROM fontes_base f
LEFT JOIN fonte_alocacao fa ON fa.fonte_alocacao_id = f.id
GROUP BY f.id, f.descricao, f.entidade, f.valor_recurso
ORDER BY f.descricao;

-- 8. Extrato detalhado por fonte (para verificar a ordem)
SELECT 
    f.descricao as fonte,
    fa.data_alocacao,
    p.descricao as projeto_destino,
    fa.descricao as alocacao_desc,
    fa.valor_alocado,
    f.valor_recurso as saldo_inicial,
    -- Saldo acumulado (calculado na ordem correta)
    f.valor_recurso - COALESCE((
        SELECT SUM(fa2.valor_alocado) 
        FROM fonte_alocacao fa2 
        WHERE fa2.fonte_alocacao_id = f.id 
        AND fa2.data_alocacao <= fa.data_alocacao
    ), 0) as saldo_acumulado
FROM fontes_base f
LEFT JOIN fonte_alocacao fa ON fa.fonte_alocacao_id = f.id
LEFT JOIN projeto p ON p.id = fa.destino_alocao_id
ORDER BY f.descricao, fa.data_alocacao;