SELECT 
    t.table_schema,
    t.table_name,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default,
    c.character_maximum_length,
    c.numeric_precision,
    c.numeric_scale
FROM information_schema.tables t
INNER JOIN information_schema.columns c 
    ON t.table_name = c.table_name 
    AND t.table_schema = c.table_schema
WHERE t.table_type = 'BASE TABLE'
    AND t.table_schema NOT IN ('information_schema', 'pg_catalog')
ORDER BY t.table_schema, t.table_name, c.ordinal_position;