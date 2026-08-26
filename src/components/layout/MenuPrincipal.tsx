// src/components/layout/MenuPrincipal.tsx

import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  ListItemButton,
  Divider,
  Box,
  Typography,
  Tooltip
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  Folder as ProjetosIcon,
  Receipt as FinanceiroIcon,
  People as ClientesIcon,
  Settings as SettingsIcon,
  BarChart as RelatoriosIcon,
  EventNote as CalendarioIcon,
  Assignment as TarefasIcon
} from '@mui/icons-material';

// Definição dos itens do menu
const menuItems = [
  {
    id: 'dashboard',
    label: 'Dashboard',
    icon: <DashboardIcon />,
    path: '/'
  },
  {
    id: 'projetos',
    label: 'Projetos',
    icon: <ProjetosIcon />,
    path: '/projetos'
  },
  {
    id: 'financeiro',
    label: 'Financeiro',
    icon: <FinanceiroIcon />,
    path: '/financeiro'
  },
  {
    id: 'clientes',
    label: 'Clientes',
    icon: <ClientesIcon />,
    path: '/clientes'
  },
  {
    id: 'tarefas',
    label: 'Tarefas',
    icon: <TarefasIcon />,
    path: '/tarefas'
  },
  {
    id: 'calendario',
    label: 'Calendário',
    icon: <CalendarioIcon />,
    path: '/calendario'
  },
  {
    id: 'relatorios',
    label: 'Relatórios',
    icon: <RelatoriosIcon />,
    path: '/relatorios'
  },
  {
    id: 'configuracoes',
    label: 'Configurações',
    icon: <SettingsIcon />,
    path: '/configuracoes'
  }
];

interface MenuPrincipalProps {
  open: boolean; // Para menu collapsed/expandido
}

export const MenuPrincipal: React.FC<MenuPrincipalProps> = ({ open }) => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleNavigation = (path: string) => {
    navigate(path);
  };

  return (
    <Box sx={{ width: '100%' }}>
      {/* Logo/Título do sistema */}
      <Box sx={{ p: 2, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Typography variant="h6" noWrap sx={{ fontWeight: 'bold' }}>
          {open ? 'SocialFlow' : 'SF'}
        </Typography>
      </Box>
      
      <Divider />
      
      <List sx={{ mt: 1 }}>
        {menuItems.map((item) => {
          const isActive = location.pathname === item.path || 
                          (item.path !== '/' && location.pathname.startsWith(item.path));
          
          return (
            <ListItem key={item.id} disablePadding sx={{ display: 'block' }}>
              <Tooltip title={!open ? item.label : ''} placement="right">
                <ListItemButton
                  selected={isActive}
                  onClick={() => handleNavigation(item.path)}
                  sx={{
                    minHeight: 48,
                    justifyContent: open ? 'initial' : 'center',
                    px: 2.5,
                    '&.Mui-selected': {
                      backgroundColor: 'primary.main',
                      '&:hover': {
                        backgroundColor: 'primary.dark',
                      },
                      '& .MuiListItemIcon-root': {
                        color: 'white',
                      },
                      '& .MuiListItemText-root': {
                        color: 'white',
                      }
                    }
                  }}
                >
                  <ListItemIcon
                    sx={{
                      minWidth: 0,
                      mr: open ? 3 : 'auto',
                      justifyContent: 'center',
                      color: isActive ? 'primary.main' : 'inherit'
                    }}
                  >
                    {item.icon}
                  </ListItemIcon>
                  {open && (
                    <ListItemText 
                      primary={item.label} 
                      sx={{ 
                        opacity: open ? 1 : 0,
                        '& .MuiTypography-root': {
                          fontWeight: isActive ? 'bold' : 'normal'
                        }
                      }}
                    />
                  )}
                </ListItemButton>
              </Tooltip>
            </ListItem>
          );
        })}
      </List>
    </Box>
  );
};