-- ============================================
-- SOCIALFLOW - TABELAS AUXILIARES (ORDEM CORRETA)
-- ============================================

-- ============================================
-- 1. PRIMEIRO: TABELAS SEM DEPENDÊNCIAS
-- ============================================

-- 1.1 TABELA: banco (não depende de ninguém)
DROP TABLE IF EXISTS banco CASCADE;
CREATE TABLE banco (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    code_swift VARCHAR(20),
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 1.2 TABELA: rubrica (não depende de ninguém)
DROP TABLE IF EXISTS rubrica CASCADE;
CREATE TABLE rubrica (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(100) NOT NULL,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 1.3 TABELA: fontes_base (não depende de ninguém)
DROP TABLE IF EXISTS fontes_base CASCADE;
CREATE TABLE fontes_base (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(200) NOT NULL,
    entidade VARCHAR(100) NOT NULL,
    valor_recurso DOUBLE PRECISION DEFAULT 0,
    remanejamento DOUBLE PRECISION DEFAULT 0,
    data_aprovacao TIMESTAMP,
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 1.4 TABELA: unidade_medida (não depende de ninguém)
DROP TABLE IF EXISTS unidade_medida CASCADE;
CREATE TABLE unidade_medida (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(50) NOT NULL,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 2. SEGUNDO: TABELAS QUE DEPENDEM DE EMPRESA E CONTATO
-- ============================================

-- 2.1 TABELA: cbanc (depende de banco e empresa)
DROP TABLE IF EXISTS cbanc CASCADE;
CREATE TABLE cbanc (
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

-- ============================================
-- 3. TERCEIRO: TABELAS QUE DEPENDEM DE PLANOCONTAS
-- ============================================

-- 3.1 TABELA: planocontas (depende de rubrica)
DROP TABLE IF EXISTS planocontas CASCADE;
CREATE TABLE planocontas (
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

-- 3.2 TABELA: centros_custo (depende de projeto, mas projeto ainda não existe)
DROP TABLE IF EXISTS centros_custo CASCADE;
CREATE TABLE centros_custo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL UNIQUE,
    responsavel_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    projeto_id UUID, -- Será adicionado depois
    ativo BOOLEAN DEFAULT TRUE,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3.3 TABELA: unidade_cc (depende de centros_custo)
DROP TABLE IF EXISTS unidade_cc CASCADE;
CREATE TABLE unidade_cc (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    centro_custo_id UUID REFERENCES centros_custo(id) ON DELETE CASCADE,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    descricao VARCHAR(100) NOT NULL UNIQUE,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 4. QUARTO: TABELAS DO MÓDULO PROJETOS
-- ============================================

-- 4.1 TABELA: projeto
DROP TABLE IF EXISTS projeto CASCADE;
CREATE TABLE projeto (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(200) NOT NULL,
    processo VARCHAR(22),
    proponente_id UUID REFERENCES empresa(id) ON DELETE SET NULL,
    conta_id UUID REFERENCES cbanc(id) ON DELETE SET NULL,
    data_entrega TIMESTAMP,
    valor_estimado DOUBLE PRECISION DEFAULT 0,
    data_aprovacao TIMESTAMP,
    valor_aprovado DOUBLE PRECISION DEFAULT 0,
    valor_total_aportado DOUBLE PRECISION DEFAULT 0,
    valor_total_metas DOUBLE PRECISION DEFAULT 0,
    saldo_projeto DOUBLE PRECISION DEFAULT 0,
    gerente_projeto_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    status_projeto VARCHAR(20) DEFAULT 'ORCAMENTO',
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4.2 TABELA: meta_projeto
DROP TABLE IF EXISTS meta_projeto CASCADE;
CREATE TABLE meta_projeto (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    projeto_id UUID NOT NULL REFERENCES projeto(id) ON DELETE CASCADE,
    sequencia INTEGER DEFAULT 0,
    descricao TEXT,
    indicador TEXT,
    unidade VARCHAR(50),
    quantifiq TEXT,
    publico TEXT,
    local TEXT,
    prova TEXT,
    vl_meta_aprov DOUBLE PRECISION DEFAULT 0,
    valor_total_etapas DOUBLE PRECISION DEFAULT 0,
    saldo_meta DOUBLE PRECISION DEFAULT 0,
    supervisor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4.3 TABELA: etapa
DROP TABLE IF EXISTS etapa CASCADE;
CREATE TABLE etapa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meta_id UUID NOT NULL REFERENCES meta_projeto(id) ON DELETE CASCADE,
    lancamento_etapa_id UUID, -- REFERENCES itemlancamento(id) será adicionado depois
    sequencia INTEGER DEFAULT 0,
    descricao TEXT,
    rubrica_id UUID REFERENCES planocontas(id) ON DELETE SET NULL,
    executor_id UUID REFERENCES empresa(id) ON DELETE SET NULL,
    area_id UUID REFERENCES centros_custo(id) ON DELETE SET NULL,
    unidade_etapa_id UUID REFERENCES unidade_cc(id) ON DELETE SET NULL,
    data_inicio TIMESTAMP,
    data_vencimento TIMESTAMP,
    valor_unitario DOUBLE PRECISION DEFAULT 0,
    unidade_pgto_id UUID REFERENCES unidade_medida(id) ON DELETE SET NULL,
    quantidade DOUBLE PRECISION DEFAULT 0,
    valor_etapa DOUBLE PRECISION DEFAULT 0,
    status VARCHAR(20) DEFAULT 'PLANEJADA',
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4.4 TABELA: tipo_ct_partida
DROP TABLE IF EXISTS tipo_ct_partida CASCADE;
CREATE TABLE tipo_ct_partida (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(100) NOT NULL,
    rubrica_id UUID REFERENCES planocontas(id) ON DELETE SET NULL,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4.5 TABELA: contra_partida
DROP TABLE IF EXISTS contra_partida CASCADE;
CREATE TABLE contra_partida (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    projeto_id UUID REFERENCES projeto(id) ON DELETE CASCADE,
    tipo_id UUID REFERENCES tipo_ct_partida(id) ON DELETE SET NULL,
    descricao TEXT,
    valor DOUBLE PRECISION DEFAULT 0,
    quantidade DOUBLE PRECISION DEFAULT 0,
    valor_total_cp DOUBLE PRECISION DEFAULT 0,
    dataentrega TIMESTAMP,
    status VARCHAR(20) DEFAULT 'PENDENTE',
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4.6 TABELA: fonte_alocacao
DROP TABLE IF EXISTS fonte_alocacao CASCADE;
CREATE TABLE fonte_alocacao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fonte_alocacao_id UUID NOT NULL REFERENCES fontes_base(id) ON DELETE CASCADE,
    destino_alocao_id UUID NOT NULL REFERENCES projeto(id) ON DELETE CASCADE,
    descricao TEXT,
    valor_alocado DOUBLE PRECISION DEFAULT 0,
    saldo_recurso DOUBLE PRECISION DEFAULT 0,
    data_alocacao TIMESTAMP DEFAULT NOW(),
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 5. QUINTO: TABELAS QUE DEPENDEM DE OUTRAS QUE FORAM CRIADAS
-- ============================================

-- 5.1 TABELA: fontes_recurso_conta
DROP TABLE IF EXISTS fontes_recurso_conta CASCADE;
CREATE TABLE fontes_recurso_conta (
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

-- 5.2 TABELA: itemlancamento
DROP TABLE IF EXISTS itemlancamento CASCADE;
CREATE TABLE itemlancamento (
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

-- ============================================
-- 6. ATUALIZAR CENTROS_CUSTO COM PROJETO_ID
-- ============================================
ALTER TABLE centros_custo ADD COLUMN IF NOT EXISTS projeto_id UUID REFERENCES projeto(id) ON DELETE SET NULL;

-- ============================================
-- 7. ATUALIZAR ETAPA COM LANCAMENTO_ETAPA_ID
-- ============================================
ALTER TABLE etapa ADD COLUMN IF NOT EXISTS lancamento_etapa_id UUID REFERENCES itemlancamento(id) ON DELETE SET NULL;

-- ============================================
-- ÍNDICES
-- ============================================
CREATE INDEX idx_projeto_proponente ON projeto(proponente_id);
CREATE INDEX idx_projeto_gerente ON projeto(gerente_projeto_id);
CREATE INDEX idx_projeto_status ON projeto(status_projeto);
CREATE INDEX idx_meta_projeto_projeto ON meta_projeto(projeto_id);
CREATE INDEX idx_etapa_meta ON etapa(meta_id);
CREATE INDEX idx_etapa_status ON etapa(status);
CREATE INDEX idx_contra_partida_projeto ON contra_partida(projeto_id);
CREATE INDEX idx_fonte_alocacao_fonte ON fonte_alocacao(fonte_alocacao_id);
CREATE INDEX idx_fonte_alocacao_destino ON fonte_alocacao(destino_alocao_id);
CREATE INDEX idx_cbanc_beneficiario ON cbanc(beneficiario_id);
CREATE INDEX idx_cbanc_banco ON cbanc(banco_id);
CREATE INDEX idx_planocontas_pai ON planocontas(conta_pai_id);
CREATE INDEX idx_itemlancamento_conta ON itemlancamento(conta_corrente_id);
CREATE INDEX idx_itemlancamento_centro ON itemlancamento(centro_custo_id);
CREATE INDEX idx_itemlancamento_fonte ON itemlancamento(fonte_recurso_id);

-- ============================================
-- PERMISSÕES RLS
-- ============================================
ALTER TABLE banco ENABLE ROW LEVEL SECURITY;
ALTER TABLE cbanc ENABLE ROW LEVEL SECURITY;
ALTER TABLE planocontas ENABLE ROW LEVEL SECURITY;
ALTER TABLE rubrica ENABLE ROW LEVEL SECURITY;
ALTER TABLE centros_custo ENABLE ROW LEVEL SECURITY;
ALTER TABLE unidade_cc ENABLE ROW LEVEL SECURITY;
ALTER TABLE itemlancamento ENABLE ROW LEVEL SECURITY;
ALTER TABLE fontes_recurso_conta ENABLE ROW LEVEL SECURITY;
ALTER TABLE projeto ENABLE ROW LEVEL SECURITY;
ALTER TABLE meta_projeto ENABLE ROW LEVEL SECURITY;
ALTER TABLE etapa ENABLE ROW LEVEL SECURITY;
ALTER TABLE unidade_medida ENABLE ROW LEVEL SECURITY;
ALTER TABLE tipo_ct_partida ENABLE ROW LEVEL SECURITY;
ALTER TABLE contra_partida ENABLE ROW LEVEL SECURITY;
ALTER TABLE fontes_base ENABLE ROW LEVEL SECURITY;
ALTER TABLE fonte_alocacao ENABLE ROW LEVEL SECURITY;

-- Conceder permissões
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
GRANT SELECT, INSERT, UPDATE, DELETE ON projeto TO authenticated;
GRANT SELECT ON projeto TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON meta_projeto TO authenticated;
GRANT SELECT ON meta_projeto TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON etapa TO authenticated;
GRANT SELECT ON etapa TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON unidade_medida TO authenticated;
GRANT SELECT ON unidade_medida TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON tipo_ct_partida TO authenticated;
GRANT SELECT ON tipo_ct_partida TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON contra_partida TO authenticated;
GRANT SELECT ON contra_partida TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON fontes_base TO authenticated;
GRANT SELECT ON fontes_base TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON fonte_alocacao TO authenticated;
GRANT SELECT ON fonte_alocacao TO anon;

-- ============================================
-- DADOS INICIAIS
-- ============================================
INSERT INTO rubrica (descricao) VALUES
('Serviços Técnicos'),
('Materiais de Consumo'),
('Equipamentos'),
('Mão de Obra'),
('Despesas Administrativas')
ON CONFLICT (id) DO NOTHING;

INSERT INTO planocontas (codigo, descricao, tipo_conta, natureza, nivel) VALUES
('6.01.001.0001', 'Custo do Projeto - Serviços', 'CUSTO', 'DEBITO', 4),
('6.01.001.0002', 'Custo do Projeto - Materiais', 'CUSTO', 'DEBITO', 4),
('6.01.001.0003', 'Custo do Projeto - Equipamentos', 'CUSTO', 'DEBITO', 4),
('5.01.001.0001', 'Despesa Administrativa - Pessoal', 'DESPESA', 'DEBITO', 4),
('5.01.001.0002', 'Despesa Administrativa - Geral', 'DESPESA', 'DEBITO', 4)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO unidade_medida (descricao) VALUES
('Unidade'),
('Quilograma'),
('Hora'),
('Dia'),
('Mês'),
('Serviço'),
('Projeto')
ON CONFLICT (id) DO NOTHING;

INSERT INTO tipo_ct_partida (descricao) VALUES
('Recurso Financeiro'),
('Mão de Obra'),
('Material'),
('Equipamento'),
('Serviço Terceirizado')
ON CONFLICT (id) DO NOTHING;