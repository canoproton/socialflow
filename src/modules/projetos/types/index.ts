// src/modules/projetos/types/index.ts

export interface IMetaProjeto {
  id: string;
  projeto_id: string;
  nome: string;
  descricao?: string;
  valor_previsto: number;
  valor_realizado?: number;
  valor_total_etapas?: number;
  data_inicio: string;
  data_fim: string;
  status: 'pendente' | 'em_andamento' | 'concluida' | 'cancelada';
  created_at: string;
  updated_at: string;
  etapas?: IEtapa[];
}

export interface IEtapa {
  id: string;
  meta_projeto_id: string;
  nome: string;
  descricao?: string;
  valor_previsto: number;
  valor_realizado?: number;
  data_inicio: string;
  data_fim: string;
  status: 'pendente' | 'em_andamento' | 'concluida' | 'cancelada';
  ordem: number;
  created_at: string;
  updated_at: string;
}

export interface IProjeto {
  id: string;
  titulo: string;
  descricao?: string;
  cliente_id: string;
  valor_total_meta?: number;
  valor_total_etapas?: number;
  data_inicio: string;
  data_fim: string;
  status: 'planejamento' | 'em_andamento' | 'concluido' | 'cancelado';
  created_at: string;
  updated_at: string;
  metas?: IMetaProjeto[];
  clientes?: {
    nome: string;
    email: string;
    telefone?: string;
  };
}

export interface IProjetoFormData {
  titulo: string;
  descricao?: string;
  cliente_id: string;
  data_inicio: string;
  data_fim: string;
  status: IProjeto['status'];
}

export interface IProjetoFilters {
  search?: string;
  status?: string;
  cliente_id?: string;
  data_inicio?: string;
  data_fim?: string;
}