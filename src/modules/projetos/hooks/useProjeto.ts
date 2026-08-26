// src/modules/projetos/hooks/useProjeto.ts

import { useContext } from 'react';
import { ProjetoContext, ProjetoContextType } from '../providers/ProjetoContext';

export const useProjeto = (): ProjetoContextType => {
  const context = useContext(ProjetoContext);
  if (!context) {
    throw new Error('useProjeto must be used within a ProjetoProvider');
  }
  return context;
};