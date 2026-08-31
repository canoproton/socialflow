-- ==========================================
-- SEED - Dados Iniciais para Teste
-- ==========================================

-- Inserir tipos de documento
INSERT INTO documento_tipo (codigo, nome, descricao, categoria, obrigatorio, validade_requerida, extensoes_permitidas, tamanho_maximo_mb) VALUES
    ('CNPJ', 'CNPJ', 'Cadastro Nacional de Pessoa Jurídica', 'FISCAL', TRUE, FALSE, '.pdf,.jpg,.jpeg,.png', 10),
    ('CONTR_SOC', 'Contrato Social', 'Documento de constituição da empresa', 'SOCIAL', TRUE, FALSE, '.pdf,.doc,.docx', 15),
    ('EDITAL', 'Edital de Convocação', 'Documento de convocação para projetos', 'EDITAL', TRUE, FALSE, '.pdf', 20),
    ('PROJETO', 'Projeto Técnico', 'Documento de descrição do projeto', 'PROJETO', TRUE, FALSE, '.pdf,.docx', 30),
    ('TERMO', 'Termo de Referência', 'Documento de especificações técnicas', 'TECNICO', TRUE, FALSE, '.pdf,.docx', 20),
    ('ALVARÁ', 'Alvará de Funcionamento', 'Licença municipal de funcionamento', 'ADMINISTRATIVO', FALSE, TRUE, '.pdf,.jpg,.jpeg,.png', 10),
    ('CERTIDAO', 'Certidão Negativa', 'Certidão de débitos', 'FISCAL', FALSE, TRUE, '.pdf', 5);

-- Inserir fonte de exemplo
INSERT INTO fontes_base (descricao, entidade, valor_recurso, remanejamento, data_aprovacao, obs) VALUES
    ('Convênio GDF 2026', 'Secretaria da Cultura do DF', 100000.00, 10.0, '2026-08-28 10:30:00', 'Convênio firmado para projetos culturais');

-- Inserir alocação inicial (lançamento de saldo)
DO $$
DECLARE
    fonte_id UUID;
BEGIN
    SELECT id INTO fonte_id FROM fontes_base WHERE descricao = 'Convênio GDF 2026' LIMIT 1;

    IF fonte_id IS NOT NULL THEN
        INSERT INTO fontes_alocacao (fonte_alocacao_id, destino_tipo, destino_id, descricao, valor_alocado, saldo_recurso, data_alocacao, obs) VALUES
            (fonte_id, 'projeto', 'bff950ae-147c-489b-829e-14ba63c7b398', 'Lançamento inicial - Convênio GDF 2026', 100000.00, 100000.00, '2026-08-28 10:30:00', 'Lançamento automático da fonte de recurso');
    END IF;
END $$;