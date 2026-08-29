WITH 
  fonte_convênio AS (SELECT id FROM fontes_base WHERE descricao = 'Convênio GDF' LIMIT 1),
  projeto_abvai AS (SELECT id FROM projeto WHERE descricao = 'projeto abvai' LIMIT 1),
  projeto_creta AS (SELECT id FROM projeto WHERE descricao = 'projeto creta' LIMIT 1)
INSERT INTO fonte_alocacao (id, fonte_alocacao_id, destino_alocao_id, descricao, valor_alocado, saldo_recurso, data_alocacao)
SELECT 
  uuid_generate_v4(),
  (SELECT id FROM fonte_convênio),
  (SELECT id FROM projeto_abvai),
  'emenda parlamentar',
  85000.00,
  15000.00,
  '2026-08-28 10:30:00'::timestamp
UNION ALL
SELECT 
  uuid_generate_v4(),
  (SELECT id FROM fonte_convênio),
  (SELECT id FROM projeto_creta),
  'reforço',
  15000.00,
  0.00,
  '2026-08-28 11:00:00'::timestamp;