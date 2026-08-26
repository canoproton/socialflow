// src/modules/projetos/index.ts

export * from './types';
export * from './services/ProjetoService';
export * from './services/MetaProjetoService';
export * from './services/EtapaService';
export * from './providers/ProjetoProvider';
export * from './hooks/useProjeto';
export * from './hooks/useEtapa';
export * from './utils/helpers';

// Components
export { ProjetoFormUnificado } from './components/ProjetoFormUnificado';
export { MetaFormFrame } from './components/MetaFormFrame';
export { EtapaFormFrame } from './components/EtapaFormFrame';

// Pages
export { ListaProjetos } from './pages/ListaProjetos';
export { VisualizarProjeto } from './pages/VisualizarProjeto';