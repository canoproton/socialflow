-- Remover políticas de permissions
DROP POLICY IF EXISTS "Admins can manage permissions" ON permissions;
DROP POLICY IF EXISTS "Users can view own permissions" ON permissions;

-- Remover políticas de access_logs
DROP POLICY IF EXISTS "Admins can view all logs" ON access_logs;
DROP POLICY IF EXISTS "Users can view own logs" ON access_logs;
DROP POLICY IF EXISTS "System can insert logs" ON access_logs;

-- Remover políticas de módulos operacionais
DROP POLICY IF EXISTS "Admin acesso total funcao" ON funcao;
DROP POLICY IF EXISTS "Admin acesso total contato" ON contato;
DROP POLICY IF EXISTS "Admin acesso total empresa" ON empresa;
DROP POLICY IF EXISTS "Admin acesso total telefone" ON telefone;
DROP POLICY IF EXISTS "Admin acesso total email" ON email;
DROP POLICY IF EXISTS "Admin acesso total endereco" ON endereco;
DROP POLICY IF EXISTS "Admin acesso total midias" ON midias;
DROP POLICY IF EXISTS "Usuarios podem ler funcao" ON funcao;
DROP POLICY IF EXISTS "Usuarios podem ler contato" ON contato;
DROP POLICY IF EXISTS "Usuarios podem ler empresa" ON empresa;
DROP POLICY IF EXISTS "Usuarios podem ler telefone" ON telefone;
DROP POLICY IF EXISTS "Usuarios podem ler email" ON email;
DROP POLICY IF EXISTS "Usuarios podem ler endereco" ON endereco;
DROP POLICY IF EXISTS "Usuarios podem ler midias" ON midias;
DROP POLICY IF EXISTS "Usuarios podem inserir funcao" ON funcao;
DROP POLICY IF EXISTS "Usuarios podem inserir contato" ON contato;
DROP POLICY IF EXISTS "Usuarios podem inserir empresa" ON empresa;
DROP POLICY IF EXISTS "Usuarios podem inserir telefone" ON telefone;
DROP POLICY IF EXISTS "Usuarios podem inserir email" ON email;
DROP POLICY IF EXISTS "Usuarios podem inserir endereco" ON endereco;
DROP POLICY IF EXISTS "Usuarios podem inserir midias" ON midias;
DROP POLICY IF EXISTS "Usuarios podem atualizar funcao" ON funcao;
DROP POLICY IF EXISTS "Usuarios podem atualizar contato" ON contato;
DROP POLICY IF EXISTS "Usuarios podem atualizar empresa" ON empresa;
DROP POLICY IF EXISTS "Usuarios podem atualizar telefone" ON telefone;
DROP POLICY IF EXISTS "Usuarios podem atualizar email" ON email;
DROP POLICY IF EXISTS "Usuarios podem atualizar endereco" ON endereco;
DROP POLICY IF EXISTS "Usuarios podem atualizar midias" ON midias;