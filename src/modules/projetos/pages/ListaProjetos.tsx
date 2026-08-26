// src/modules/projetos/pages/ListaProjetos.tsx

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useProjeto } from '../hooks/useProjeto';
import {
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  IconButton,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Typography,
  Chip,
  MenuItem,
  FormControl,
  InputLabel,
  Select,
  TablePagination,
  LinearProgress,
  Tooltip,
  InputAdornment
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  Visibility,
  Search,
  Clear,
  TrendingUp,
  TrendingDown,
  CheckCircle,
  CancelOutlined
} from '@mui/icons-material';
import { formatCurrency, getStatusColor, getStatusLabel, formatDate } from '../utils/helpers';

export const ListaProjetos: React.FC = () => {
  const navigate = useNavigate();
  const { projetos, loading, loadProjetos, deleteProjeto } = useProjeto();
  const [filters, setFilters] = useState({
    search: '',
    status: ''
  });
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  useEffect(() => {
    loadProjetos();
  }, []);

  const handleFilterChange = (field: string, value: any) => {
    setFilters(prev => ({ ...prev, [field]: value }));
    setPage(0);
  };

  const handleSearch = () => {
    loadProjetos(filters);
  };

  const handleClearFilters = () => {
    setFilters({ search: '', status: '' });
    loadProjetos();
  };

  const handleDelete = async (id: string, titulo: string) => {
    if (window.confirm(`Tem certeza que deseja excluir o projeto "${titulo}"?`)) {
      try {
        await deleteProjeto(id);
      } catch (err) {
        // Error already handled by provider
      }
    }
  };

  const getStatusIcon = (status: string) => {
    const icons = {
      planejamento: <TrendingUp fontSize="small" color="warning" />,
      em_andamento: <TrendingUp fontSize="small" color="info" />,
      concluido: <CheckCircle fontSize="small" color="success" />,
      cancelado: <CancelOutlined fontSize="small" color="error" />
    };
    return icons[status as keyof typeof icons] || null;
  };

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h5" gutterBottom>
            Projetos
          </Typography>
          <Typography variant="body2" color="textSecondary">
            Gerencie todos os projetos do SocialFlow
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => navigate('/projetos/novo')}
          size="large"
        >
          Novo Projeto
        </Button>
      </Box>

      {/* Filtros */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid item xs={12} sm={5}>
            <TextField
              fullWidth
              size="small"
              label="Buscar projeto"
              value={filters.search}
              onChange={(e) => handleFilterChange('search', e.target.value)}
              placeholder="Título do projeto..."
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Search />
                  </InputAdornment>
                ),
                endAdornment: filters.search && (
                  <InputAdornment position="end">
                    <IconButton size="small" onClick={() => handleFilterChange('search', '')}>
                      <Clear fontSize="small" />
                    </IconButton>
                  </InputAdornment>
                )
              }}
              onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            />
          </Grid>
          <Grid item xs={12} sm={3}>
            <FormControl fullWidth size="small">
              <InputLabel>Status</InputLabel>
              <Select
                value={filters.status}
                label="Status"
                onChange={(e) => handleFilterChange('status', e.target.value)}
              >
                <MenuItem value="">Todos</MenuItem>
                <MenuItem value="planejamento">Planejamento</MenuItem>
                <MenuItem value="em_andamento">Em Andamento</MenuItem>
                <MenuItem value="concluido">Concluído</MenuItem>
                <MenuItem value="cancelado">Cancelado</MenuItem>
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} sm={4}>
            <Box sx={{ display: 'flex', gap: 1 }}>
              <Button
                variant="contained"
                onClick={handleSearch}
                startIcon={<Search />}
                fullWidth
              >
                Filtrar
              </Button>
              <Button
                variant="outlined"
                onClick={handleClearFilters}
                startIcon={<Clear />}
              >
                Limpar
              </Button>
            </Box>
          </Grid>
        </Grid>
      </Paper>

      {/* Tabela */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Projeto</TableCell>
              <TableCell>Cliente</TableCell>
              <TableCell align="right">Valor Meta</TableCell>
              <TableCell align="right">Valor Etapas</TableCell>
              <TableCell>Período</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="center">Ações</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={7} sx={{ p: 0 }}>
                  <LinearProgress />
                </TableCell>
              </TableRow>
            ) : projetos.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} align="center" sx={{ py: 6 }}>
                  <Typography variant="body1" color="textSecondary" gutterBottom>
                    Nenhum projeto encontrado
                  </Typography>
                  <Button
                    variant="outlined"
                    startIcon={<Add />}
                    onClick={() => navigate('/projetos/novo')}
                    sx={{ mt: 1 }}
                  >
                    Criar primeiro projeto
                  </Button>
                </TableCell>
              </TableRow>
            ) : (
              projetos.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((projeto) => (
                <TableRow key={projeto.id} hover>
                  <TableCell>
                    <Typography variant="body2" fontWeight="bold">
                      {projeto.titulo}
                    </Typography>
                    {projeto.descricao && (
                      <Typography variant="caption" color="textSecondary" display="block" noWrap sx={{ maxWidth: 200 }}>
                        {projeto.descricao}
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    {projeto.clientes?.nome || 'N/A'}
                    {projeto.clientes?.email && (
                      <Typography variant="caption" color="textSecondary" display="block">
                        {projeto.clientes.email}
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell align="right">
                    <Typography variant="body2" fontWeight="500">
                      {formatCurrency(projeto.valor_total_meta)}
                    </Typography>
                  </TableCell>
                  <TableCell align="right">
                    <Typography variant="body2" fontWeight="500">
                      {formatCurrency(projeto.valor_total_etapas)}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="caption" display="block">
                      <strong>Início:</strong> {formatDate(projeto.data_inicio)}
                    </Typography>
                    <Typography variant="caption" display="block">
                      <strong>Fim:</strong> {formatDate(projeto.data_fim)}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      icon={getStatusIcon(projeto.status)}
                      label={getStatusLabel(projeto.status)}
                      color={getStatusColor(projeto.status) as any}
                      size="small"
                    />
                  </TableCell>
                  <TableCell align="center">
                    <Box sx={{ display: 'flex', justifyContent: 'center', gap: 0.5 }}>
                      <Tooltip title="Visualizar">
                        <IconButton
                          size="small"
                          onClick={() => navigate(`/projetos/${projeto.id}`)}
                          color="primary"
                        >
                          <Visibility fontSize="small" />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Editar">
                        <IconButton
                          size="small"
                          onClick={() => navigate(`/projetos/editar/${projeto.id}`)}
                          color="info"
                        >
                          <Edit fontSize="small" />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Excluir">
                        <IconButton
                          size="small"
                          onClick={() => handleDelete(projeto.id, projeto.titulo)}
                          color="error"
                        >
                          <Delete fontSize="small" />
                        </IconButton>
                      </Tooltip>
                    </Box>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
        <TablePagination
          rowsPerPageOptions={[5, 10, 25, 50]}
          component="div"
          count={projetos.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={(e, newPage) => setPage(newPage)}
          onRowsPerPageChange={(e) => {
            setRowsPerPage(parseInt(e.target.value, 10));
            setPage(0);
          }}
          labelRowsPerPage="Itens por página"
          labelDisplayedRows={({ from, to, count }) => `${from}-${to} de ${count}`}
        />
      </TableContainer>

      {/* Estatísticas */}
      {projetos.length > 0 && (
        <Grid container spacing={2} sx={{ mt: 1 }}>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography variant="caption" color="textSecondary">
                  Total de Projetos
                </Typography>
                <Typography variant="h5">
                  {projetos.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography variant="caption" color="textSecondary">
                  Em Andamento
                </Typography>
                <Typography variant="h5" color="info.main">
                  {projetos.filter(p => p.status === 'em_andamento').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography variant="caption" color="textSecondary">
                  Concluídos
                </Typography>
                <Typography variant="h5" color="success.main">
                  {projetos.filter(p => p.status === 'concluido').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography variant="caption" color="textSecondary">
                  Valor Total
                </Typography>
                <Typography variant="h5" color="primary.main">
                  {formatCurrency(projetos.reduce((sum, p) => sum + (p.valor_total_meta || 0), 0))}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      )}
    </Box>
  );
};