// src/modules/projetos/utils/helpers.ts

export const formatCurrency = (value: number): string => {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(value || 0);
};

export const getStatusColor = (status: string): string => {
  const colors = {
    planejamento: 'warning',
    em_andamento: 'info',
    concluido: 'success',
    cancelado: 'error',
    pendente: 'warning',
    concluida: 'success',
    cancelada: 'error'
  };
  return colors[status as keyof typeof colors] || 'default';
};

export const getStatusLabel = (status: string): string => {
  const labels = {
    planejamento: 'Planejamento',
    em_andamento: 'Em Andamento',
    concluido: 'Concluído',
    cancelado: 'Cancelado',
    pendente: 'Pendente',
    concluida: 'Concluída',
    cancelada: 'Cancelada'
  };
  return labels[status as keyof typeof labels] || status;
};

export const formatDate = (date: string): string => {
  return new Date(date).toLocaleDateString('pt-BR');
};

export const calcularProgresso = (total: number, realizado: number): number => {
  if (total === 0) return 0;
  return Math.round((realizado / total) * 100);
};