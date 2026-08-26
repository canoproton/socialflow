-- Conceder permissões para a tabela profiles
GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;

-- Conceder permissões para todas as tabelas do módulo operacional
GRANT SELECT, INSERT, UPDATE, DELETE ON empresa TO authenticated;
GRANT SELECT ON empresa TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON contato TO authenticated;
GRANT SELECT ON contato TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON telefone TO authenticated;
GRANT SELECT ON telefone TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON email TO authenticated;
GRANT SELECT ON email TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON endereco TO authenticated;
GRANT SELECT ON endereco TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON midias TO authenticated;
GRANT SELECT ON midias TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON empresa_contato TO authenticated;
GRANT SELECT ON empresa_contato TO anon;

-- Verificar permissões
SELECT 
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_name IN ('profiles', 'empresa', 'contato', 'telefone', 'email', 'endereco', 'midias', 'empresa_contato')
ORDER BY table_name, grantee;