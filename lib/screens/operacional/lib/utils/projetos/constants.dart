/// ============================================
/// CONSTANTES DO MÓDULO PROJETOS
/// ============================================

class ProjetoConstants {
  // Status do Projeto
  static const String STATUS_ORCAMENTO = 'ORÇAMENTO';
  static const String STATUS_EMITIDO = 'EMITIDO';
  static const String STATUS_APROVADO = 'APROVADO';
  static const String STATUS_INDEFERIDO = 'INDEFERIDO';
  static const String STATUS_EXECUTANDO = 'EXECUTANDO';
  static const String STATUS_FINALIZADO = 'FINALIZADO';

  // Status da Etapa
  static const String ETAPA_STATUS_PLANEJADA = 'PLANEJADA';
  static const String ETAPA_STATUS_ACIONADO = 'ACIONADO';
  static const String ETAPA_STATUS_EXECUCAO = 'EXECUÇÃO';
  static const String ETAPA_STATUS_PENDENTE = 'PENDENTE';
  static const String ETAPA_STATUS_CONCLUIDA = 'CONCLUIDA';
  static const String ETAPA_STATUS_CANCELADA = 'CANCELADA';

  // Formato do Processo (Regra 1)
  static const String PROCESSO_FORMATO = 'XXXXX-XXXXXXXX/XXXX-XX';
  static const String PROCESSO_REGEX = r'^\d{5}-\d{8}/\d{4}-\d{2}$';

  // Tipos de Natureza (Regra 10)
  static const String NATUREZA_DEBITO = 'D';
  static const String NATUREZA_CREDITO = 'C';

  // Status para disparo (Regra 8)
  static const String TICKET_STATUS_ACTIVE = 'ACTIVE';
  static const String TICKET_STATUS_INACTIVE = 'INACTIVE';
  static const String TICKET_STATUS_COMPLETED = 'COMPLETED';
  static const String TICKET_STATUS_ARCHIVED = 'ARCHIVED';

  // Prioridades
  static const String PRIORIDADE_URGENTE = 'URGENT';
  static const String PRIORIDADE_ALTA = 'ALTA';
  static const String PRIORIDADE_MEDIA = 'MÉDIA';
  static const String PRIORIDADE_BAIXA = 'BAIXA';
}