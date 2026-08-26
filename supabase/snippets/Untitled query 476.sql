-- Verificar políticas da tabela profiles
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY policyname;