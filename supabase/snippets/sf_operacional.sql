-- ============================================
-- SOCIALFLOW - MÓDULO OPERACIONAL
-- CRIAÇÃO DE TABELAS - VERSÃO CORRIGIDA
-- ============================================

-- 1. TABELA: funcao
CREATE TABLE IF NOT EXISTS funcao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao VARCHAR(100) NOT NULL,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- 2. TABELA: contato
CREATE TABLE IF NOT EXISTS contato (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    tipo_vinculo VARCHAR(20) NOT NULL,
    funcao_id UUID REFERENCES funcao(id) ON DELETE SET NULL,
    empresa_id UUID,  -- Será criado depois com relacionamento
    cpf VARCHAR(14),
    rg VARCHAR(20),
    genero VARCHAR(10),
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- 3. TABELA: empresa
CREATE TABLE IF NOT EXISTS empresa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    qualif VARCHAR(20) NOT NULL,
    razao_social VARCHAR(100) NOT NULL,
    tipo_contr VARCHAR(20) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    ie VARCHAR(20),
    contato_principal UUID REFERENCES contato(id) ON DELETE SET NULL,  -- Contato principal da empresa
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- 4. TABELA: empresa_contato (Relacionamento N:N entre Empresa e Contato)
CREATE TABLE IF NOT EXISTS empresa_contato (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresa(id) ON DELETE CASCADE,
    contato_id UUID NOT NULL REFERENCES contato(id) ON DELETE CASCADE,
    tipo_relacao VARCHAR(20), -- Ex: 'PROPONENTE', 'EXECUTOR', 'FORNECEDOR'
    observacao TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW(),
    UNIQUE(empresa_id, contato_id)
);

-- 5. TABELA: telefone
CREATE TABLE IF NOT EXISTS telefone (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contato_id UUID NOT NULL REFERENCES contato(id) ON DELETE CASCADE,
    uso VARCHAR(20) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- 6. TABELA: email
CREATE TABLE IF NOT EXISTS email (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contato_id UUID NOT NULL REFERENCES contato(id) ON DELETE CASCADE,
    uso VARCHAR(20) NOT NULL,
    endereco VARCHAR(100) NOT NULL,
    email_comm VARCHAR(100),
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- 7. TABELA: endereco
CREATE TABLE IF NOT EXISTS endereco (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contato_id UUID NOT NULL REFERENCES contato(id) ON DELETE CASCADE,
    logradouro VARCHAR(200) NOT NULL,
    bairro VARCHAR(100),
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    cep VARCHAR(10),
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- 8. TABELA: midias
CREATE TABLE IF NOT EXISTS midias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contato_id UUID NOT NULL REFERENCES contato(id) ON DELETE CASCADE,
    uso VARCHAR(20) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    descricao VARCHAR(200) NOT NULL,
    obs TEXT,
    atualizado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- ÍNDICES
-- ============================================

CREATE INDEX idx_contato_funcao ON contato(funcao_id);
CREATE INDEX idx_contato_empresa ON contato(empresa_id);
CREATE INDEX idx_telefone_contato ON telefone(contato_id);
CREATE INDEX idx_email_contato ON email(contato_id);
CREATE INDEX idx_endereco_contato ON endereco(contato_id);
CREATE INDEX idx_midias_contato ON midias(contato_id);
CREATE INDEX idx_empresa_contato_principal ON empresa(contato_principal);
CREATE INDEX idx_empresa_contato_empresa ON empresa_contato(empresa_id);
CREATE INDEX idx_empresa_contato_contato ON empresa_contato(contato_id);

-- ============================================
-- RLS - SEGURANÇA
-- ============================================

ALTER TABLE funcao ENABLE ROW LEVEL SECURITY;
ALTER TABLE contato ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresa ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresa_contato ENABLE ROW LEVEL SECURITY;
ALTER TABLE telefone ENABLE ROW LEVEL SECURITY;
ALTER TABLE email ENABLE ROW LEVEL SECURITY;
ALTER TABLE endereco ENABLE ROW LEVEL SECURITY;
ALTER TABLE midias ENABLE ROW LEVEL SECURITY;

-- Políticas básicas: Admin tem acesso total
CREATE POLICY "Admin acesso total funcao" ON funcao FOR ALL USING (auth.uid() IN (SELECT user_id FROM profiles WHERE cargo = 'Administrador'));
CREATE POLICY "Admin acesso total contato" ON contato FOR ALL USING (auth.uid() IN (SELECT user_id FROM profiles WHERE cargo = 'Administrador'));
CREATE POLICY "Admin acesso total empresa" ON empresa FOR ALL USING (auth.uid() IN (SELECT user_id FROM profiles WHERE cargo = 'Administrador'));
CREATE POLICY "Admin acesso total empresa_contato" ON empresa_contato FOR ALL USING (auth.uid() IN (SELECT user_id FROM profiles WHERE cargo = 'Administrador'));
CREATE POLICY "Admin acesso total telefone" ON telefone FOR ALL USING (auth.uid() IN (SELECT user_id FROM profiles WHERE cargo = 'Administrador'));
CREATE POLICY "Admin acesso total email" ON email FOR ALL USING (auth.uid() IN (SELECT user_id FROM profiles WHERE cargo = 'Administrador'));
CREATE POLICY "Admin acesso total endereco" ON endereco FOR ALL USING (auth.uid() IN (SELECT user_id FROM profiles WHERE cargo = 'Administrador'));
CREATE POLICY "Admin acesso total midias" ON midias FOR ALL USING (auth.uid() IN (SELECT user_id FROM profiles WHERE cargo = 'Administrador'));

-- Políticas de leitura para todos os usuários autenticados
CREATE POLICY "Usuarios podem ler funcao" ON funcao FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem ler contato" ON contato FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem ler empresa" ON empresa FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem ler empresa_contato" ON empresa_contato FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem ler telefone" ON telefone FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem ler email" ON email FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem ler endereco" ON endereco FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem ler midias" ON midias FOR SELECT USING (auth.uid() IS NOT NULL);

-- Políticas de inserção/atualização para todos os usuários autenticados
CREATE POLICY "Usuarios podem inserir funcao" ON funcao FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem inserir contato" ON contato FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem inserir empresa" ON empresa FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem inserir empresa_contato" ON empresa_contato FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem inserir telefone" ON telefone FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem inserir email" ON email FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem inserir endereco" ON endereco FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem inserir midias" ON midias FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Usuarios podem atualizar funcao" ON funcao FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem atualizar contato" ON contato FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem atualizar empresa" ON empresa FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem atualizar empresa_contato" ON empresa_contato FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem atualizar telefone" ON telefone FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem atualizar email" ON email FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem atualizar endereco" ON endereco FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Usuarios podem atualizar midias" ON midias FOR UPDATE USING (auth.uid() IS NOT NULL);

-- ============================================
-- DADOS INICIAIS - FUNÇÕES
-- ============================================

INSERT INTO funcao (descricao) VALUES
('Diretor'),
('Gerente de Projetos'),
('Analista de Projetos'),
('Coordenador'),
('Assistente Administrativo'),
('Analista Financeiro'),
('Contador'),
('Advogado'),
('Consultor'),
('Técnico'),
('Estagiário')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- VERIFICAÇÃO
-- ============================================

SELECT '=== TABELAS CRIADAS ===' as Mensagem;
SELECT tablename FROM pg_tables WHERE schemaname = 'public' 
    AND tablename IN ('funcao', 'contato', 'empresa', 'empresa_contato', 
                      'telefone', 'email', 'endereco', 'midias')
ORDER BY tablename;