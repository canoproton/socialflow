// src/modules/projetos/services/ProjetoService.ts

import { supabase } from '@/lib/supabase';
import { IProjeto, IProjetoFormData, IProjetoFilters } from '../types';

export class ProjetoService {
  static async create(projeto: IProjetoFormData) {
    const { data, error } = await supabase
      .from('projetos')
      .insert([{
        ...projeto,
        valor_total_meta: 0,
        valor_total_etapas: 0
      }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async update(id: string, projeto: Partial<IProjetoFormData>) {
    const { data, error } = await supabase
      .from('projetos')
      .update(projeto)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async delete(id: string) {
    const { error } = await supabase
      .from('projetos')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  static async getAll(filters?: IProjetoFilters) {
    let query = supabase
      .from('projetos')
      .select(`
        *,
        clientes (
          id,
          nome,
          email,
          telefone
        )
      `);

    if (filters?.status) {
      query = query.eq('status', filters.status);
    }

    if (filters?.cliente_id) {
      query = query.eq('cliente_id', filters.cliente_id);
    }

    if (filters?.search) {
      query = query.ilike('titulo', `%${filters.search}%`);
    }

    if (filters?.data_inicio) {
      query = query.gte('data_inicio', filters.data_inicio);
    }

    if (filters?.data_fim) {
      query = query.lte('data_fim', filters.data_fim);
    }

    const { data, error } = await query.order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }

  static async getById(id: string) {
    const { data, error } = await supabase
      .from('projetos')
      .select(`
        *,
        clientes (
          id,
          nome,
          email,
          telefone
        ),
        metas:meta_projetos (
          *,
          etapas (*)
        )
      `)
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }

  static async dispararParaTicket(projetoId: string, ticketData: any) {
    const { data, error } = await supabase
      .from('tickets')
      .insert([{
        ...ticketData,
        projeto_id: projetoId,
        origem: 'projeto'
      }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async dispararParaItemLancamento(projetoId: string, itemData: any) {
    const { data, error } = await supabase
      .from('itens_lancamento')
      .insert([{
        ...itemData,
        projeto_id: projetoId,
        origem: 'projeto'
      }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async atualizarTotais(projetoId: string) {
    // Buscar metas do projeto
    const { data: metas } = await supabase
      .from('meta_projetos')
      .select('valor_previsto')
      .eq('projeto_id', projetoId);

    const totalMeta = metas?.reduce((sum, meta) => sum + (meta.valor_previsto || 0), 0) || 0;

    // Buscar etapas de todas as metas
    const { data: metasComEtapas } = await supabase
      .from('meta_projetos')
      .select(`
        id,
        etapas (valor_previsto)
      `)
      .eq('projeto_id', projetoId);

    let totalEtapas = 0;
    metasComEtapas?.forEach(meta => {
      meta.etapas?.forEach((etapa: any) => {
        totalEtapas += etapa.valor_previsto || 0;
      });
    });

    const { error } = await supabase
      .from('projetos')
      .update({
        valor_total_meta: totalMeta,
        valor_total_etapas: totalEtapas
      })
      .eq('id', projetoId);

    if (error) throw error;
  }
}