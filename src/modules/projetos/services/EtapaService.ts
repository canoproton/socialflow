// src/modules/projetos/services/EtapaService.ts

import { supabase } from '@/lib/supabase';
import { IEtapa } from '../types';
import { ProjetoService } from './ProjetoService';

export class EtapaService {
  static async create(etapa: Omit<IEtapa, 'id' | 'created_at' | 'updated_at'>) {
    const { data, error } = await supabase
      .from('etapas')
      .insert([etapa])
      .select()
      .single();

    if (error) throw error;
    
    // Atualizar valor total das etapas na meta
    await this.atualizarTotalEtapas(etapa.meta_projeto_id);
    
    return data;
  }

  static async update(id: string, etapa: Partial<IEtapa>) {
    // Buscar etapa atual para pegar meta_projeto_id
    const { data: etapaAtual } = await supabase
      .from('etapas')
      .select('meta_projeto_id')
      .eq('id', id)
      .single();

    const { data, error } = await supabase
      .from('etapas')
      .update(etapa)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    
    // Atualizar total das etapas na meta
    if (etapaAtual?.meta_projeto_id) {
      await this.atualizarTotalEtapas(etapaAtual.meta_projeto_id);
    }
    
    return data;
  }

  static async delete(id: string) {
    // Buscar etapa para pegar meta_projeto_id
    const { data: etapa } = await supabase
      .from('etapas')
      .select('meta_projeto_id')
      .eq('id', id)
      .single();

    const { error } = await supabase
      .from('etapas')
      .delete()
      .eq('id', id);

    if (error) throw error;
    
    // Atualizar total das etapas na meta
    if (etapa?.meta_projeto_id) {
      await this.atualizarTotalEtapas(etapa.meta_projeto_id);
    }
  }

  static async getByMeta(metaId: string) {
    const { data, error } = await supabase
      .from('etapas')
      .select('*')
      .eq('meta_projeto_id', metaId)
      .order('ordem', { ascending: true });

    if (error) throw error;
    return data;
  }

  static async getById(id: string) {
    const { data, error } = await supabase
      .from('etapas')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }

  private static async atualizarTotalEtapas(metaId: string) {
    const { data: etapas } = await supabase
      .from('etapas')
      .select('valor_previsto')
      .eq('meta_projeto_id', metaId);

    const total = etapas?.reduce((sum, etapa) => sum + (etapa.valor_previsto || 0), 0) || 0;

    // Atualizar meta
    const { data: meta } = await supabase
      .from('meta_projetos')
      .update({ valor_total_etapas: total })
      .eq('id', metaId)
      .select('projeto_id')
      .single();

    // Atualizar projeto
    if (meta?.projeto_id) {
      await ProjetoService.atualizarTotais(meta.projeto_id);
    }
  }
}