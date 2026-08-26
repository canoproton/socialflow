-- ============================================
-- TABELAS AUXILIARES PARA O MÓDULO PROJETOS
-- ============================================

-- 1. TABELA: banco
CREATE TABLE IF NOT EXISTS banco (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    code_swift VARCHAR(20),
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. TABELA: cbanc
CREATE TABLE IF NOT EXISTS cbanc (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    beneficiario_id UUID REFERENCES empresa(id) ON DELETE SET NULL,
    banco_id UUID REFERENCES banco(id) ON DELETE SET NULL,
    agencia VARCHAR(20),
    tipo VARCHAR(20) DEFAULT 'PJ',
    numero_conta VARCHAR(30) NOT NULL UNIQUE,
    iban VARCHAR(34),
    identificador VARCHAR(50),
    contato_id UUID REFERENCES contato(id) ON DELETE SET NULL,
    obs TEXT,
    desativada BOOLEAN DEFAULT FALSE,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. TABELA: planocontas (necessária para rubrica)
CREATE TABLE IF NOT EXISTS planocontas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(20) NOT NULL UNIQUE,
    rubrica_id UUID REFERENCES rubrica(id) ON DELETE SET NULL,
    descricao TEXT,
    tipo_conta VARCHAR(20) DEFAULT 'DESPESA',
    natureza VARCHAR(10) DEFAULT 'DEBITO',
    nivel INTEGER DEFAULT 1,
    conta_pai_id UUID REFERENCES planocontas(id) ON DELETE SET NULL,
    categoria_contabil VARCHAR(30),
    vinculavel_projeto BOOLEAN DEFAULT TRUE,
    vinculavel_fonte BOOLEAN DEFAULT FALSE,
    limite_orcamentario DOUBLE PRECISION DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    bloqueio_edicao BOOLEAN DEFAULT FALSE,
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. TABELA: rubrica (necessária para planocontas)
CREATE TABLE IF NOT EXISTS rubrica (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(100) NOT NULL,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. TABELA: centros_custo
CREATE TABLE IF NOT EXISTS centros_custo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL UNIQUE,
    responsavel_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    projeto_id UUID REFERENCES projeto(id) ON DELETE SET NULL,
    ativo BOOLEAN DEFAULT TRUE,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 6. TABELA: unidade_cc
CREATE TABLE IF NOT EXISTS unidade_cc (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    centro_custo_id UUID REFERENCES centros_custo(id) ON DELETE CASCADE,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    descricao VARCHAR(100) NOT NULL UNIQUE,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 7. TABELA: itemlancamento (necessária para etapa)
CREATE TABLE IF NOT EXISTS itemlancamento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    relacionamento_id UUID,
    conta_corrente_id UUID REFERENCES cbanc(id) ON DELETE SET NULL,
    descricao TEXT NOT NULL,
    valor_lancamento DOUBLE PRECISION DEFAULT 0,
    saldo_pos_lanc DOUBLE PRECISION DEFAULT 0,
    data_lancamento TIMESTAMP DEFAULT NOW(),
    efetivado BOOLEAN DEFAULT FALSE,
    data_efetivacao TIMESTAMP,
    centro_custo_id UUID REFERENCES centros_custo(id) ON DELETE SET NULL,
    fonte_recurso_id UUID REFERENCES fontes_recurso_conta(id) ON DELETE SET NULL,
    rubrica_id UUID REFERENCES rubrica(id) ON DELETE SET NULL,
    natureza VARCHAR(1) DEFAULT 'D',
    executor_id UUID REFERENCES empresa(id) ON DELETE SET NULL,
    obs TEXT,
    autorizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    autorizado_em TIMESTAMP,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 8. TABELA: fontes_recurso_conta
CREATE TABLE IF NOT EXISTS fontes_recurso_conta (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conta_id UUID REFERENCES planocontas(id) ON DELETE CASCADE,
    fonte_recurso_id UUID REFERENCES fontes_base(id) ON DELETE CASCADE,
    percentual_disponivel DOUBLE PRECISION DEFAULT 100,
    restricao_uso TEXT,
    doc_necessaria JSONB DEFAULT '[]',
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- ÍNDICES
-- ============================================
CREATE INDEX idx_cbanc_beneficiario ON cbanc(beneficiario_id);
CREATE INDEX idx_cbanc_banco ON cbanc(banco_id);
CREATE INDEX idx_planocontas_pai ON planocontas(conta_pai_id);
CREATE INDEX idx_itemlancamento_conta ON itemlancamento(conta_corrente_id);
CREATE INDEX idx_itemlancamento_centro ON itemlancamento(centro_custo_id);
CREATE INDEX idx_itemlancamento_fonte ON itemlancamento(fonte_recurso_id);

-- ============================================
-- PERMISSÕES
-- ============================================
ALTER TABLE banco ENABLE ROW LEVEL SECURITY;
ALTER TABLE cbanc ENABLE ROW LEVEL SECURITY;
ALTER TABLE planocontas ENABLE ROW LEVEL SECURITY;
ALTER TABLE rubrica ENABLE ROW LEVEL SECURITY;
ALTER TABLE centros_custo ENABLE ROW LEVEL SECURITY;
ALTER TABLE unidade_cc ENABLE ROW LEVEL SECURITY;
ALTER TABLE itemlancamento ENABLE ROW LEVEL SECURITY;
ALTER TABLE fontes_recurso_conta ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE, DELETE ON banco TO authenticated;
GRANT SELECT ON banco TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON cbanc TO authenticated;
GRANT SELECT ON cbanc TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON planocontas TO authenticated;
GRANT SELECT ON planocontas TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON rubrica TO authenticated;
GRANT SELECT ON rubrica TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON centros_custo TO authenticated;
GRANT SELECT ON centros_custo TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON unidade_cc TO authenticated;
GRANT SELECT ON unidade_cc TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON itemlancamento TO authenticated;
GRANT SELECT ON itemlancamento TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON fontes_recurso_conta TO authenticated;
GRANT SELECT ON fontes_recurso_conta TO anon;

-- ============================================
-- DADOS INICIAIS
-- ============================================
INSERT INTO rubrica (descricao) VALUES
('Serviços Técnicos'),
('Materiais de Consumo'),
('Equipamentos'),
('Mão de Obra'),
('Despesas Administrativas');

INSERT INTO planocontas (codigo, descricao, tipo_conta, natureza, nivel) VALUES
('6.01.001.0001', 'Custo do Projeto - Serviços', 'CUSTO', 'DEBITO', 4),
('6.01.001.0002', 'Custo do Projeto - Materiais', 'CUSTO', 'DEBITO', 4),
('6.01.001.0003', 'Custo do Projeto - Equipamentos', 'CUSTO', 'DEBITO', 4),
('5.01.001.0001', 'Despesa Administrativa - Pessoal', 'DESPESA', 'DEBITO', 4),
('5.01.001.0002', 'Despesa Administrativa - Geral', 'DESPESA', 'DEBITO', 4);