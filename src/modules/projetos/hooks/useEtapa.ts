// src/modules/projetos/hooks/useEtapa.ts

import { useState, useCallback } from 'react';
import { EtapaService } from '../services/EtapaService';
import { IEtapa } from '../types';

export const useEtapa = () => {
  const [etapas, setEtapas] = useState<IEtapa[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadEtapasByMeta = useCallback(async (metaId: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await EtapaService.getByMeta(metaId);
      setEtapas(data);
      return data;
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao carregar etapas:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const createEtapa = useCallback(async (data: any) => {
    setLoading(true);
    setError(null);
    try {
      const newEtapa = await EtapaService.create(data);
      setEtapas(prev => [...prev, newEtapa]);
      return newEtapa;
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao criar etapa:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const updateEtapa = useCallback(async (id: string, data: any) => {
    setLoading(true);
    setError(null);
    try {
      const updated = await EtapaService.update(id, data);
      setEtapas(prev => prev.map(e => e.id === id ? updated : e));
      return updated;
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao atualizar etapa:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const deleteEtapa = useCallback(async (id: string) => {
    setLoading(true);
    setError(null);
    try {
      await EtapaService.delete(id);
      setEtapas(prev => prev.filter(e => e.id !== id));
    } catch (err: any) {
      setError(err.message);
      console.error('Erro ao deletar etapa:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    etapas,
    loading,
    error,
    loadEtapasByMeta,
    createEtapa,
    updateEtapa,
    deleteEtapa
  };
};