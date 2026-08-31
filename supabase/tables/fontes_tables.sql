-- ==========================================
-- MÓDULO FONTES DE RECURSOS
-- ==========================================

-- 1. Criar ENUM para destino_tipo
CREATE TYPE destino_tipo_enum AS ENUM (
    'projeto',
    'rubrica'
);

-- 2. Criar ENUM para status do documento
CREATE TYPE documento_status_enum AS ENUM (
    'RASCUNHO',
    'PENDENTE',
    'APROVADO',
    'REJEITADO',
    'VENCIDO',
    'ENTREGUE',
    'ARQUIVADO'
);

-- 3. Criar ENUM para categoria do documento
CREATE TYPE documento_categoria_enum AS ENUM (
    'FISCAL',
    'EDITAL',
    'CONTRA_PARTIDA',
    'CONTRATUAL',
    'SOCIAL',
    'FINANCEIRO',
    'TECNICO',
    'ADMINISTRATIVO',
    'PROJETO',
    'OUTROS'
);

-- ==========================================
-- TABELA: fontes_base
-- ==========================================
CREATE TABLE fontes_base (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao TEXT NOT NULL,
    entidade TEXT NOT NULL,
    valor_recurso DOUBLE PRECISION NOT NULL DEFAULT 0,
    remanejamento DOUBLE PRECISION DEFAULT 0,
    data_aprovacao TIMESTAMP,
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT valor_recurso_positivo CHECK (valor_recurso >= 0),
    CONSTRAINT remanejamento_percentual CHECK (remanejamento >= 0 AND remanejamento <= 100)
);

-- Índices
CREATE INDEX idx_fontes_base_atualizado_por ON fontes_base(atualizado_por);
CREATE INDEX idx_fontes_base_entidade ON fontes_base(entidade);
CREATE INDEX idx_fontes_base_data_aprovacao ON fontes_base(data_aprovacao);

-- RLS (Row Level Security)
ALTER TABLE fontes_base ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for authenticated users" ON fontes_base
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON fontes_base
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON fontes_base
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON fontes_base
    FOR DELETE USING (auth.role() = 'authenticated');


-- ==========================================
-- TABELA: fontes_alocacao
-- ==========================================
CREATE TABLE fontes_alocacao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fonte_alocacao_id UUID NOT NULL REFERENCES fontes_base(id) ON DELETE CASCADE,
    destino_tipo destino_tipo_enum NOT NULL,
    destino_id UUID NOT NULL,
    descricao TEXT NOT NULL,
    valor_alocado DOUBLE PRECISION NOT NULL DEFAULT 0,
    saldo_recurso DOUBLE PRECISION NOT NULL DEFAULT 0,
    data_alocacao TIMESTAMP DEFAULT NOW(),
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT valor_alocado_positivo CHECK (valor_alocado >= 0),
    CONSTRAINT saldo_nao_negativo CHECK (saldo_recurso >= 0)
);

-- Índices
CREATE INDEX idx_fontes_alocacao_fonte ON fontes_alocacao(fonte_alocacao_id);
CREATE INDEX idx_fontes_alocacao_destino ON fontes_alocacao(destino_tipo, destino_id);
CREATE INDEX idx_fontes_alocacao_data ON fontes_alocacao(data_alocacao);

-- RLS
ALTER TABLE fontes_alocacao ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for authenticated users" ON fontes_alocacao
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON fontes_alocacao
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON fontes_alocacao
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON fontes_alocacao
    FOR DELETE USING (auth.role() = 'authenticated');


-- ==========================================
-- TABELA: documento_tipo
-- ==========================================
CREATE TABLE documento_tipo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(100) UNIQUE NOT NULL,
    descricao TEXT,
    categoria documento_categoria_enum NOT NULL,
    obrigatorio BOOLEAN DEFAULT FALSE,
    validade_requerida BOOLEAN DEFAULT FALSE,
    prazo_validade_meses INTEGER,
    extensoes_permitidas TEXT DEFAULT '.pdf,.jpg,.jpeg,.png',
    tamanho_maximo_mb INTEGER DEFAULT 10,
    ativo BOOLEAN DEFAULT TRUE,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_documento_tipo_categoria ON documento_tipo(categoria);
CREATE INDEX idx_documento_tipo_ativo ON documento_tipo(ativo);

-- RLS
ALTER TABLE documento_tipo ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for authenticated users" ON documento_tipo
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON documento_tipo
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON documento_tipo
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON documento_tipo
    FOR DELETE USING (auth.role() = 'authenticated');


-- ==========================================
-- TABELA: documento_shelter
-- ==========================================
CREATE TABLE documento_shelter (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dominio_tipo VARCHAR(30) NOT NULL CHECK (dominio_tipo IN (
        'projeto', 'rubrica', 'fontes_base', 'fontes_alocacao',
        'empresa', 'contato', 'centros_custo', 'unidade_cc'
    )),
    dominio_id UUID NOT NULL,
    tipo_id UUID NOT NULL REFERENCES documento_tipo(id) ON DELETE RESTRICT,
    numero VARCHAR(100) UNIQUE,
    arquivo TEXT NOT NULL,
    nome_original TEXT NOT NULL,
    descricao TEXT,
    data_emissao TIMESTAMP,
    valido_ate TIMESTAMP,
    prazo_entrega TIMESTAMP,
    data_apresentacao TIMESTAMP,
    status documento_status_enum DEFAULT 'RASCUNHO',
    obs TEXT,
    hash_arquivo VARCHAR(64) DEFAULT '',
    tamanho_bytes BIGINT,
    versao INTEGER DEFAULT 1,
    documento_anterior_id UUID REFERENCES documento_shelter(id) ON DELETE SET NULL,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_documento_shelter_dominio ON documento_shelter(dominio_tipo, dominio_id);
CREATE INDEX idx_documento_shelter_tipo ON documento_shelter(tipo_id);
CREATE INDEX idx_documento_shelter_status ON documento_shelter(status);

-- RLS
ALTER TABLE documento_shelter ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for authenticated users" ON documento_shelter
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON documento_shelter
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON documento_shelter
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON documento_shelter
    FOR DELETE USING (auth.role() = 'authenticated');


-- ==========================================
-- FUNCTION: Calcular saldo da alocação
-- ==========================================
CREATE OR REPLACE FUNCTION calcular_saldo_alocacao()
RETURNS TRIGGER AS $$
DECLARE
    ultimo_saldo DOUBLE PRECISION;
BEGIN
    -- 1. Buscar o último saldo para esta fonte
    SELECT COALESCE(saldo_recurso, 0) INTO ultimo_saldo
    FROM fontes_alocacao
    WHERE fonte_alocacao_id = NEW.fonte_alocacao_id
    ORDER BY data_alocacao DESC, created_at DESC
    LIMIT 1;

    -- 2. Se não houver lançamentos anteriores, usar valor_recurso da fonte_base
    IF ultimo_saldo IS NULL OR ultimo_saldo = 0 THEN
        SELECT valor_recurso INTO ultimo_saldo
        FROM fontes_base
        WHERE id = NEW.fonte_alocacao_id;
    END IF;

    -- 3. Validar se o saldo é suficiente
    IF NEW.valor_alocado > ultimo_saldo THEN
        RAISE EXCEPTION 'Saldo insuficiente. Disponível: %, Solicitado: %',
            ultimo_saldo, NEW.valor_alocado;
    END IF;

    -- 4. Calcular o novo saldo
    NEW.saldo_recurso := ultimo_saldo - NEW.valor_alocado;

    -- 5. Validar se o saldo não ficou negativo
    IF NEW.saldo_recurso < 0 THEN
        RAISE EXCEPTION 'Saldo não pode ser negativo. Saldo após lançamento: %',
            NEW.saldo_recurso;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para executar o cálculo automaticamente
DROP TRIGGER IF EXISTS trg_calcular_saldo_alocacao ON fontes_alocacao;
CREATE TRIGGER trg_calcular_saldo_alocacao
BEFORE INSERT ON fontes_alocacao
FOR EACH ROW
EXECUTE FUNCTION calcular_saldo_alocacao();


-- ==========================================
-- VIEW: vw_saldo_recurso
-- ==========================================
CREATE OR REPLACE VIEW vw_saldo_recurso AS
SELECT
    fb.id AS fonte_id,
    fb.descricao,
    fb.entidade,
    fb.valor_recurso,
    COALESCE(SUM(fa.valor_alocado), 0) AS total_alocado,
    fb.valor_recurso - COALESCE(SUM(fa.valor_alocado), 0) AS saldo_recurso
FROM fontes_base fb
LEFT JOIN fontes_alocacao fa ON fa.fonte_alocacao_id = fb.id
GROUP BY fb.id, fb.descricao, fb.entidade, fb.valor_recurso;