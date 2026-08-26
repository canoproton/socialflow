// src/modules/projetos/providers/ProjetoProvider.tsx

import React, { useState, useCallback, ReactNode } from 'react';
import { ProjetoContext } from './ProjetoContext';
import { ProjetoService } from '../services/ProjetoService';
import { IProjeto, IProjetoFilters } from '../types';

interface ProjetoProviderProps {
  children: ReactNode;
}

export const ProjetoProvider: React.FC<ProjetoProviderProps> = ({ children }) => {
  const [projetos, setProjetos] = useState<IProjeto[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedProjeto, setSelectedProjeto] = useState<IProjeto | null>(null);

  const loadProjetos = useCallback(async (filters?: IProjetoFilters) => {
    setLoading(true);
    setError(null);
    try {
      const data = await ProjetoService.getAll(filters);
      setProjetos(data);
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao carregar projetos:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const loadProjetoById = useCallback(async (id: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await ProjetoService.getById(id);
      setSelectedProjeto(data);
      return data;
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao carregar projeto:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const createProjeto = useCallback(async (data: any) => {
    setLoading(true);
    setError(null);
    try {
      const newProjeto = await ProjetoService.create(data);
      setProjetos(prev => [newProjeto, ...prev]);
      return newProjeto;
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao criar projeto:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const updateProjeto = useCallback(async (id: string, data: any) => {
    setLoading(true);
    setError(null);
    try {
      const updated = await ProjetoService.update(id, data);
      setProjetos(prev => prev.map(p => p.id === id ? updated : p));
      if (selectedProjeto?.id === id) {
        setSelectedProjeto(updated);
      }
      return updated;
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao atualizar projeto:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [selectedProjeto]);

  const deleteProjeto = useCallback(async (id: string) => {
    setLoading(true);
    setError(null);
    try {
      await ProjetoService.delete(id);
      setProjetos(prev => prev.filter(p => p.id !== id));
      if (selectedProjeto?.id === id) {
        setSelectedProjeto(null);
      }
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao deletar projeto:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [selectedProjeto]);

  const refresh = useCallback(async () => {
    await loadProjetos();
  }, [loadProjetos]);

  const value = {
    projetos,
    loading,
    error,
    selectedProjeto,
    loadProjetos,
    loadProjetoById,
    createProjeto,
    updateProjeto,
    deleteProjeto,
    setSelectedProjeto,
    refresh
  };

  return (
    <ProjetoContext.Provider value={value}>
      {children}
    </ProjetoContext.Provider>
  );
};