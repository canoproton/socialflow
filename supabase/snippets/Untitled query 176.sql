-- Conceder permissões para o role 'authenticated' (usuários logados)
GRANT SELECT, INSERT, UPDATE, DELETE ON funcao TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON contato TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON empresa TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON telefone TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON email TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON endereco TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON midias TO authenticated;

-- Conceder permissões também para o role 'anon' (usuários não logados - apenas leitura)
GRANT SELECT ON funcao TO anon;
GRANT SELECT ON contato TO anon;
GRANT SELECT ON empresa TO anon;
GRANT SELECT ON telefone TO anon;
GRANT SELECT ON email TO anon;
GRANT SELECT ON endereco TO anon;
GRANT SELECT ON midias TO anon;

-- Verificar permissões
SELECT 
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_name IN ('funcao', 'contato', 'empresa', 'telefone', 'email', 'endereco', 'midias')
ORDER BY table_name, grantee;