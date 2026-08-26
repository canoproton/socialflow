// src/routes/index.tsx

import { createBrowserRouter } from 'react-router-dom';
import { ProjetoProvider } from '@/modules/projetos/providers/ProjetoProvider';
import { ListaProjetos } from '@/modules/projetos/pages/ListaProjetos';
import { ProjetoFormUnificado } from '@/modules/projetos/components/ProjetoFormUnificado';
import { VisualizarProjeto } from '@/modules/projetos/pages/VisualizarProjeto';
import { MainLayout } from '@/components/layout/MainLayout';

// Se você tiver um Dashboard, importe aqui
import { Dashboard } from '@/pages/Dashboard';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <MainLayout />, // Seu layout principal
    children: [
      {
        index: true,
        element: <Dashboard /> // Página inicial
      },
      // ... outras rotas existentes
      
      // ROTA PROJETOS - ADICIONE ISSO
      {
        path: 'projetos',
        element: (
          <ProjetoProvider>
            <Outlet />
          </ProjetoProvider>
        ),
        children: [
          {
            index: true,
            element: <ListaProjetos />
          },
          {
            path: 'novo',
            element: (
              <ProjetoFormUnificado 
                onSave={() => navigate('/projetos')}
                onCancel={() => navigate('/projetos')}
              />
            )
          },
          {
            path: 'editar/:id',
            element: (
              <ProjetoFormUnificado 
                projetoId={id}
                onSave={() => navigate('/projetos')}
                onCancel={() => navigate('/projetos')}
              />
            )
          },
          {
            path: ':id',
            element: <VisualizarProjeto />
          }
        ]
      }
    ]
  }
]);

// IMPORTANTE: Se você não tiver o useNavigate disponível, use isso:
// Em vez de navigate('/projetos'), use:
// import { useNavigate } from 'react-router-dom';
// const navigate = useNavigate();