-- Substitua os IDs abaixo pelos IDs reais dos usuários
INSERT INTO profiles (user_id, nome, email, cargo, departamento, is_active) VALUES
    ('69161380-95f0-44a7-acac-df82fa01c504', 'Administrador do Sistema', 'admin@socialflow.com', 'Administrador', 'TI', true),
    ('3f6480a6-0c31-404a-aba5-2d2200da21f4', 'João Gerente', 'gerente@socialflow.com', 'Gerente de Projetos', 'Operações', true),
    ('1b7cb5c6-9872-4c61-bc58-38c6b32d891c', 'Maria Analista', 'analista@socialflow.com', 'Analista de Projetos', 'Projetos', true),
    ('c4499de6-cdfc-4246-8ae8-a619e8b37c6f', 'Carlos Financeiro', 'financeiro@socialflow.com', 'Analista Financeiro', 'Financeiro', true),
    ('c480ad0d-9133-4286-aece-fd8bee3baeb5', 'Pedro Usuário', 'usuario@socialflow.com', 'Assistente', 'Operações', true)
ON CONFLICT (user_id) DO UPDATE SET 
    nome = EXCLUDED.nome,
    email = EXCLUDED.email,
    cargo = EXCLUDED.cargo,
    departamento = EXCLUDED.departamento;