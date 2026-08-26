// src/modules/projetos/pages/VisualizarProjeto.tsx

import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Box,
  Paper,
  Typography,
  Grid,
  Chip,
  Divider,
  Button,
  Card,
  CardContent,
  IconButton,
  Stepper,
  Step,
  StepLabel,
  LinearProgress,
  Alert,
  Snackbar,
  Tooltip
} from '@mui/material';
import {
  ArrowBack,
  Edit,
  Delete,
  Print,
  Share,
  TrendingUp,
  TrendingDown,
  CheckCircle,
  CancelOutlined,
  Schedule
} from '@mui/icons-material';
import { useProjeto } from '../hooks/useProjeto';
import { formatCurrency, getStatusColor, getStatusLabel, formatDate } from '../utils/helpers';
import { ProjetoService } from '../services/ProjetoService';

export const VisualizarProjeto: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { selectedProjeto, loadProjetoById, deleteProjeto, loading } = useProjeto();
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    if (id) {
      loadProjetoById(id);
    }
  }, [id]);

  const handleDelete = async () => {
    if (window.confirm(`Tem certeza que deseja excluir o projeto "${selectedProjeto?.titulo}"?`)) {
      try {
        await deleteProjeto(selectedProjeto!.id);
        setSuccess(true);
        setTimeout(() => navigate('/projetos'), 1500);
      } catch (err: any) {
        setError(err.message);
      }
    }
  };

  const handleDispararTicket = async () => {
    try {
      await ProjetoService.dispararParaTicket(selectedProjeto!.id, {
        titulo: `Ticket - ${selectedProjeto?.titulo}`,
        descricao: selectedProjeto?.descricao,
        cliente_id: selectedProjeto?.cliente_id,
        valor: selectedProjeto?.valor_total_meta
      });
      setSuccess(true);
    } catch (err: any) {
      setError(err.message);
    }
  };

  if (loading) {
    return (
      <Box sx={{ p: 3 }}>
        <LinearProgress />
      </Box>
    );
  }

  if (!selectedProjeto) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">Projeto não encontrado</Alert>
        <Button
          variant="contained"
          onClick={() => navigate('/projetos')}
          sx={{ mt: 2 }}
        >
          Voltar para lista
        </Button>
      </Box>
    );
  }

  const totalMetas = selectedProjeto.metas?.reduce((sum, meta) => sum + (meta.valor_previsto || 0), 0) || 0;
  const totalEtapas = selectedProjeto.metas?.reduce((sum, meta) => 
    sum + (meta.etapas?.reduce((s, e) => s + (e.valor_previsto || 0), 0) || 0), 0
  ) || 0;

  const etapasConcluidas = selectedProjeto.metas?.reduce((sum, meta) =>
    sum + (meta.etapas?.filter(e => e.status === 'concluida').length || 0), 0
  ) || 0;

  const totalEtapasCount = selectedProjeto.metas?.reduce((sum, meta) =>
    sum + (meta.etapas?.length || 0), 0
  ) || 0;

  const progresso = totalEtapasCount > 0 ? (etapasConcluidas / totalEtapasCount) * 100 : 0;

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 3 }}>
        <Box>
          <Button
            startIcon={<ArrowBack />}
            onClick={() => navigate('/projetos')}
            sx={{ mb: 1 }}
          >
            Voltar
          </Button>
          <Typography variant="h5" gutterBottom>
            {selectedProjeto.titulo}
          </Typography>
          <Box sx={{ display: 'flex', gap: 1, alignItems: 'center', flexWrap: 'wrap' }}>
            <Chip
              label={getStatusLabel(selectedProjeto.status)}
              color={getStatusColor(selectedProjeto.status) as any}
            />
            <Typography variant="body2" color="textSecondary">
              Cliente: {selectedProjeto.clientes?.nome || 'N/A'}
            </Typography>
            <Typography variant="body2" color="textSecondary">
              {formatDate(selectedProjeto.data_inicio)} - {formatDate(selectedProjeto.data_fim)}
            </Typography>
          </Box>
        </Box>
        <Box sx={{ display: 'flex', gap: 1 }}>
          <Tooltip title="Gerar Ticket">
            <Button
              variant="outlined"
              startIcon={<Share />}
              onClick={handleDispararTicket}
              size="small"
            >
              Ticket
            </Button>
          </Tooltip>
          <Tooltip title="Imprimir">
            <IconButton onClick={() => window.print()}>
              <Print />
            </IconButton>
          </Tooltip>
          <Tooltip title="Editar">
            <IconButton
              onClick={() => navigate(`/projetos/editar/${selectedProjeto.id}`)}
              color="primary"
            >
              <Edit />
            </IconButton>
          </Tooltip>
          <Tooltip title="Excluir">
            <IconButton onClick={handleDelete} color="error">
              <Delete />
            </IconButton>
          </Tooltip>
        </Box>
      </Box>

      {/* Resumo */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="caption" color="textSecondary">
                Valor Total Metas
              </Typography>
              <Typography variant="h5" color="primary">
                {formatCurrency(totalMetas)}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="caption" color="textSecondary">
                Valor Total Etapas
              </Typography>
              <Typography variant="h5" color="secondary">
                {formatCurrency(totalEtapas)}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="caption" color="textSecondary">
                Progresso
              </Typography>
              <Typography variant="h5">
                {Math.round(progresso)}%
              </Typography>
              <LinearProgress
                variant="determinate"
                value={progresso}
                sx={{ mt: 1 }}
              />
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="caption" color="textSecondary">
                Metas / Etapas
              </Typography>
              <Typography variant="h5">
                {selectedProjeto.metas?.length || 0} / {totalEtapasCount}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Descrição */}
      {selectedProjeto.descricao && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            Descrição do Projeto
          </Typography>
          <Typography variant="body2" color="textSecondary">
            {selectedProjeto.descricao}
          </Typography>
        </Paper>
      )}

      {/* Metas e Etapas */}
      <Typography variant="h6" gutterBottom sx={{ mt: 3 }}>
        Metas e Etapas
      </Typography>
      
      {selectedProjeto.metas?.length === 0 ? (
        <Paper sx={{ p: 4, textAlign: 'center' }}>
          <Typography color="textSecondary">
            Nenhuma meta cadastrada para este projeto.
          </Typography>
        </Paper>
      ) : (
        selectedProjeto.metas?.map((meta, index) => (
          <Paper key={meta.id} sx={{ p: 3, mb: 2 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
              <Box>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Typography variant="subtitle1" fontWeight="bold">
                    {index + 1}. {meta.nome}
                  </Typography>
                  <Chip
                    label={getStatusLabel(meta.status)}
                    color={getStatusColor(meta.status) as any}
                    size="small"
                  />
                </Box>
                {meta.descricao && (
                  <Typography variant="body2" color="textSecondary">
                    {meta.descricao}
                  </Typography>
                )}
                <Box sx={{ display: 'flex', gap: 2, mt: 1 }}>
                  <Typography variant="caption" display="block">
                    <strong>Valor:</strong> {formatCurrency(meta.valor_previsto)}
                  </Typography>
                  <Typography variant="caption" display="block">
                    <strong>Período:</strong> {formatDate(meta.data_inicio)} - {formatDate(meta.data_fim)}
                  </Typography>
                </Box>
              </Box>
            </Box>

            {/* Etapas da Meta */}
            {meta.etapas && meta.etapas.length > 0 && (
              <Box sx={{ pl: 3, borderLeft: '2px solid', borderColor: 'grey.300' }}>
                <Typography variant="caption" fontWeight="bold" display="block" sx={{ mb: 1 }}>
                  Etapas:
                </Typography>
                {meta.etapas.map((etapa) => (
                  <Box
                    key={etapa.id}
                    sx={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                      p: 1,
                      '&:hover': { bgcolor: 'grey.50' },
                      borderRadius: 1
                    }}
                  >
                    <Box>
                      <Typography variant="body2">
                        {etapa.ordem}. {etapa.nome}
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 2 }}>
                        <Typography variant="caption" color="textSecondary">
                          {formatCurrency(etapa.valor_previsto)}
                        </Typography>
                        <Chip
                          label={getStatusLabel(etapa.status)}
                          color={getStatusColor(etapa.status) as any}
                          size="small"
                          variant="outlined"
                        />
                      </Box>
                    </Box>
                    <Typography variant="caption" color="textSecondary">
                      {formatDate(etapa.data_inicio)} - {formatDate(etapa.data_fim)}
                    </Typography>
                  </Box>
                ))}
              </Box>
            )}
          </Paper>
        ))
      )}

      {/* Feedback */}
      <Snackbar
        open={!!error}
        autoHideDuration={6000}
        onClose={() => setError(null)}
        anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
      >
        <Alert severity="error" onClose={() => setError(null)}>
          {error}
        </Alert>
      </Snackbar>

      <Snackbar
        open={success}
        autoHideDuration={3000}
        onClose={() => setSuccess(false)}
        anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
      >
        <Alert severity="success">
          Operação realizada com sucesso!
        </Alert>
      </Snackbar>
    </Box>
  );
};