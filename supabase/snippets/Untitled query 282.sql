SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('projeto', 'meta_projeto', 'etapa', 'unidade_medida', 
                  'tipo_ct_partida', 'contra_partida', 'fontes_base', 'fonte_alocacao',
                  'banco', 'cbanc', 'planocontas', 'rubrica', 'centros_custo', 
                  'unidade_cc', 'itemlancamento', 'fontes_recurso_conta')
ORDER BY tablename;