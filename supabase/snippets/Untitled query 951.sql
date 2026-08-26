-- Adicionar campo nome_do_app
ALTER TABLE midias ADD COLUMN IF NOT EXISTS nome_do_app VARCHAR(50);

-- Verificar
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'midias' 
ORDER BY ordinal_position;