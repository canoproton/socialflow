SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('funcao', 'contato', 'empresa', 'empresa_contato', 
                  'telefone', 'email', 'endereco', 'midias')
ORDER BY tablename;