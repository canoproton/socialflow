-- Remover a coluna email_comm da tabela email
ALTER TABLE email DROP COLUMN IF EXISTS email_comm;

-- Verificar a estrutura da tabela
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'email' 
ORDER BY ordinal_position;