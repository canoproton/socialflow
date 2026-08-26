-- ============================================
-- SOCIALFLOW - MÓDULO PROJETOS
-- CRIAÇÃO DE TABELAS
-- ============================================

-- 1. TABELA: projeto
CREATE TABLE IF NOT EXISTS projeto (
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

-- 2. TABELA: meta_projeto
CREATE TABLE IF NOT EXISTS meta_projeto (
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

-- 3. TABELA: etapa
CREATE TABLE IF NOT EXISTS etapa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meta_id UUID NOT NULL REFERENCES meta_projeto(id) ON DELETE CASCADE,
    lancamento_etapa_id UUID REFERENCES itemlancamento(id) ON DELETE SET NULL,
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

-- 4. TABELA: unidade_medida
CREATE TABLE IF NOT EXISTS unidade_medida (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(50) NOT NULL,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. TABELA: tipo_ct_partida
CREATE TABLE IF NOT EXISTS tipo_ct_partida (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(100) NOT NULL,
    rubrica_id UUID REFERENCES planocontas(id) ON DELETE SET NULL,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 6. TABELA: contra_partida
CREATE TABLE IF NOT EXISTS contra_partida (
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

-- 7. TABELA: fontes_base
CREATE TABLE IF NOT EXISTS fontes_base (
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

-- 8. TABELA: fonte_alocacao
CREATE TABLE IF NOT EXISTS fonte_alocacao (
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

-- ============================================
-- RLS E PERMISSÕES
-- ============================================
ALTER TABLE projeto ENABLE ROW LEVEL SECURITY;
ALTER TABLE meta_projeto ENABLE ROW LEVEL SECURITY;
ALTER TABLE etapa ENABLE ROW LEVEL SECURITY;
ALTER TABLE unidade_medida ENABLE ROW LEVEL SECURITY;
ALTER TABLE tipo_ct_partida ENABLE ROW LEVEL SECURITY;
ALTER TABLE contra_partida ENABLE ROW LEVEL SECURITY;
ALTER TABLE fontes_base ENABLE ROW LEVEL SECURITY;
ALTER TABLE fonte_alocacao ENABLE ROW LEVEL SECURITY;

-- Conceder permissões
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