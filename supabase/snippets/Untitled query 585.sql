SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('telefone', 'email', 'endereco', 'midias') 
ORDER BY table_name, ordinal_position;
