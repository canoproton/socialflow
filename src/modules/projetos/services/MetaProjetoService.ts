// src/modules/projetos/services/MetaProjetoService.ts

import { supabase } from '@/lib/supabase';
import { IMetaProjeto } from '../types';
import { ProjetoService } from './ProjetoService';

export class MetaProjetoService {
  static async create(meta: Omit<IMetaProjeto, 'id' | 'created_at' | 'updated_at'>) {
    const { data, error } = await supabase
      .from('meta_projetos')
      .insert([meta])
      .select()
      .single();

    if (error) throw error;
    
    // Atualizar total do projeto
    await ProjetoService.atualizarTotais(meta.projeto_id);
    
    return data;
  }

  static async update(id: string, meta: Partial<IMetaProjeto>) {
    // Buscar meta atual para pegar projeto_id
    const { data: metaAtual } = await supabase
      .from('meta_projetos')
      .select('projeto_id')
      .eq('id', id)
      .single();

    const { data, error } = await supabase
      .from('meta_projetos')
      .update(meta)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    
    // Atualizar total do projeto
    if (metaAtual?.projeto_id) {
      await ProjetoService.atualizarTotais(metaAtual.projeto_id);
    }
    
    return data;
  }

  static async delete(id: string) {
    // Buscar meta para pegar projeto_id
    const { data: meta } = await supabase
      .from('meta_projetos')
      .select('projeto_id')
      .eq('id', id)
      .single();

    const { error } = await supabase
      .from('meta_projetos')
      .delete()
      .eq('id', id);

    if (error) throw error;
    
    // Atualizar total do projeto
    if (meta?.projeto_id) {
      await ProjetoService.atualizarTotais(meta.projeto_id);
    }
  }

  static async getByProjeto(projetoId: string) {
    const { data, error } = await supabase
      .from('meta_projetos')
      .select('*')
      .eq('projeto_id', projetoId)
      .order('data_inicio', { ascending: true });

    if (error) throw error;
    return data;
  }

  static async getById(id: string) {
    const { data, error } = await supabase
      .from('meta_projetos')
      .select(`
        *,
        etapas (*)
      `)
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }
}