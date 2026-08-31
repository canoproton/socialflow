-- Comando único para verificar tudo
SELECT 
    'fontes_base' AS tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fontes_base') 
        THEN '❌ AINDA EXISTE' 
        ELSE '✅ DELETADA' 
    END AS status
UNION ALL
SELECT 
    'fonte_alocacao',
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fonte_alocacao') 
        THEN '❌ AINDA EXISTE' 
        ELSE '✅ DELETADA' 
    END
UNION ALL
SELECT 
    'fontes_recurso_conta',
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fontes_recurso_conta') 
        THEN '❌ AINDA EXISTE' 
        ELSE '✅ DELETADA' 
    END
UNION ALL
SELECT 
    'fonte_id',
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fonte_id') 
        THEN '❌ AINDA EXISTE' 
        ELSE '✅ DELETADA' 
    END
UNION ALL
SELECT 
    'projeto_abvai_id',
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'projeto_abvai_id') 
        THEN '❌ AINDA EXISTE' 
        ELSE '✅ DELETADA' 
    END
UNION ALL
SELECT 
    'projeto_creta_id',
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'projeto_creta_id') 
        THEN '❌ AINDA EXISTE' 
        ELSE '✅ DELETADA' 
    END;