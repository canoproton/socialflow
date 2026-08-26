-- Verificar permissões da tabela contato
SELECT 
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_name = 'contato'
ORDER BY grantee, privilege_type;