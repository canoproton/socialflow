-- ============================================
-- SOCIALFLOW - MÓDULO DE USUÁRIOS
-- CRIAÇÃO DE TABELAS COM SEGURANÇA
-- VERSÃO CORRIGIDA
-- ============================================

-- ============================================
-- 1. TABELA: profiles
-- ============================================

DROP TABLE IF EXISTS profiles CASCADE;

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    cargo VARCHAR(50),
    departamento VARCHAR(50),
    telefone VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    login_attempts INTEGER DEFAULT 0,
    blocked_until TIMESTAMP,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 2. TABELA: modules
-- ============================================

DROP TABLE IF EXISTS modules CASCADE;

CREATE TABLE modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nome VARCHAR(50) NOT NULL,
    icone VARCHAR(50),
    descricao TEXT,
    ordem INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 3. TABELA: permissions
-- ============================================

DROP TABLE IF EXISTS permissions CASCADE;

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
    module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    can_read BOOLEAN DEFAULT FALSE,
    can_insert BOOLEAN DEFAULT FALSE,
    can_edit BOOLEAN DEFAULT FALSE,
    can_delete BOOLEAN DEFAULT FALSE,
    can_export BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, module_id)
);

-- ============================================
-- 4. TABELA: access_logs
-- ============================================

DROP TABLE IF EXISTS access_logs CASCADE;

CREATE TABLE access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
    module_id UUID REFERENCES modules(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    details JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    session_id VARCHAR(100),
    device_info JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_is_active ON profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_profiles_login_attempts ON profiles(login_attempts);
CREATE INDEX IF NOT EXISTS idx_permissions_user_id ON permissions(user_id);
CREATE INDEX IF NOT EXISTS idx_permissions_module_id ON permissions(module_id);
CREATE INDEX IF NOT EXISTS idx_access_logs_user_id ON access_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_access_logs_created_at ON access_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_access_logs_action ON access_logs(action);
CREATE INDEX IF NOT EXISTS idx_access_logs_session_id ON access_logs(session_id);

-- ============================================
-- TRIGGERS - Atualizar updated_at automaticamente
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_modules_updated_at ON modules;
CREATE TRIGGER update_modules_updated_at
    BEFORE UPDATE ON modules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_permissions_updated_at ON permissions;
CREATE TRIGGER update_permissions_updated_at
    BEFORE UPDATE ON permissions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================
-- FUNÇÕES DE SEGURANÇA
-- ============================================

CREATE OR REPLACE FUNCTION reset_login_attempts(user_email TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE profiles 
    SET login_attempts = 0, 
        blocked_until = NULL 
    WHERE email = user_email;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_login_attempts(user_email TEXT)
RETURNS INTEGER AS $$
DECLARE
    attempt_count INTEGER;
BEGIN
    UPDATE profiles 
    SET login_attempts = login_attempts + 1 
    WHERE email = user_email
    RETURNING login_attempts INTO attempt_count;
    
    RETURN attempt_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_user_blocked(user_email TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    blocked_until_time TIMESTAMP;
BEGIN
    SELECT blocked_until INTO blocked_until_time 
    FROM profiles 
    WHERE email = user_email;
    
    RETURN blocked_until_time IS NOT NULL AND blocked_until_time > NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- DADOS INICIAIS - MÓDULOS
-- ============================================

INSERT INTO modules (codigo, nome, icone, ordem) VALUES
('DASHBOARD', 'Dashboard', 'dashboard', 0),
('USUARIOS', 'Usuários', 'people', 1),
('PROJETOS', 'Projetos', 'folder', 2),
('TAREFAS', 'Tarefas', 'checklist', 3),
('OPERACIONAL', 'Operacional', 'local_shipping', 4),
('CONTABILIDADE', 'Contabilidade', 'account_balance', 5),
('FINANCEIRO', 'Financeiro', 'attach_money', 6),
('DOCUMENTOS', 'Documentos', 'folder_open', 7),
('IA', 'Inteligência Artificial', 'psychology', 8)
ON CONFLICT (codigo) DO NOTHING;

-- ============================================
-- POLÍTICAS DE SEGURANÇA (RLS)
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE access_logs ENABLE ROW LEVEL SECURITY;

-- POLÍTICAS - PROFILES

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles" ON profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE user_id = auth.uid() 
            AND cargo = 'Administrador'
        )
    );

-- POLÍTICAS - PERMISSIONS

DROP POLICY IF EXISTS "Admins can manage permissions" ON permissions;
CREATE POLICY "Admins can manage permissions" ON permissions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE user_id = auth.uid() 
            AND cargo = 'Administrador'
        )
    );

DROP POLICY IF EXISTS "Users can view own permissions" ON permissions;
CREATE POLICY "Users can view own permissions" ON permissions
    FOR SELECT USING (auth.uid() = user_id);

-- POLÍTICAS - ACCESS_LOGS

DROP POLICY IF EXISTS "Admins can view all logs" ON access_logs;
CREATE POLICY "Admins can view all logs" ON access_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE user_id = auth.uid() 
            AND cargo = 'Administrador'
        )
    );

DROP POLICY IF EXISTS "Users can view own logs" ON access_logs;
CREATE POLICY "Users can view own logs" ON access_logs
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can insert logs" ON access_logs;
CREATE POLICY "System can insert logs" ON access_logs
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================
-- VERIFICAÇÃO - TABELAS CRIADAS
-- ============================================

SELECT 'TABELAS CRIADAS' as Mensagem;
SELECT tablename FROM pg_tables WHERE schemaname = 'public' 
    AND tablename IN ('profiles', 'modules', 'permissions', 'access_logs')
ORDER BY tablename;

SELECT 'MODULOS INSERIDOS' as Mensagem;
SELECT codigo, nome, ordem FROM modules ORDER BY ordem;

SELECT 'POLITICAS RLS' as Mensagem;
SELECT schemaname, tablename, policyname, permissive 
FROM pg_policies 
WHERE tablename IN ('profiles', 'permissions', 'access_logs')
ORDER BY tablename, policyname;