// src/modules/projetos/providers/ProjetoContext.tsx

import { createContext } from 'react';
import { IProjeto, IProjetoFilters } from '../types';

export interface ProjetoContextType {
  projetos: IProjeto[];
  loading: boolean;
  error: string | null;
  selectedProjeto: IProjeto | null;
  loadProjetos: (filters?: IProjetoFilters) => Promise<void>;
  loadProjetoById: (id: string) => Promise<void>;
  createProjeto: (data: any) => Promise<IProjeto>;
  updateProjeto: (id: string, data: any) => Promise<IProjeto>;
  deleteProjeto: (id: string) => Promise<void>;
  setSelectedProjeto: (projeto: IProjeto | null) => void;
  refresh: () => Promise<void>;
}

export const ProjetoContext = createContext<ProjetoContextType | undefined>(undefined);