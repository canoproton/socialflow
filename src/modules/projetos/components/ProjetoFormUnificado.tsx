// src/modules/projetos/components/ProjetoFormUnificado.tsx

import React, { useState, useEffect } from 'react';
import {
  Box,
  Paper,
  Grid,
  TextField,
  Button,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Divider,
  Card,
  CardContent,
  IconButton,
  Alert,
  Snackbar,
  Chip,
  LinearProgress,
  Tooltip
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  Save,
  Cancel,
  Refresh,
  TrendingUp,
  TrendingDown
} from '@mui/icons-material';
import { useProjeto } from '../hooks/useProjeto';
import { MetaProjetoService } from '../services/MetaProjetoService';
import { EtapaService } from '../services/EtapaService';
import { MetaFormFrame } from './MetaFormFrame';
import { EtapaFormFrame } from './EtapaFormFrame';
import { formatCurrency, getStatusColor, getStatusLabel, formatDate } from '../utils/helpers';
import { IMetaProjeto, IEtapa } from '../types';

interface ProjetoFormUnificadoProps {
  projetoId?: string;
  onSave: () => void;
  onCancel: () => void;
}

export const ProjetoFormUnificado: React.FC<ProjetoFormUnificadoProps> = ({
  projetoId,
  onSave,
  onCancel
}) => {
  const { selectedProjeto, loadProjetoById, createProjeto, updateProjeto, loading } = useProjeto();
  
  const [formData, setFormData] = useState<any>({
    titulo: '',
    descricao: '',
    cliente_id: '',
    data_inicio: '',
    data_fim: '',
    status: 'planejamento'
  });

  const [metas, setMetas] = useState<IMetaProjeto[]>([]);
  const [metaDialogOpen, setMetaDialogOpen] = useState(false);
  const [etapaDialogOpen, setEtapaDialogOpen] = useState(false);
  const [currentMeta, setCurrentMeta] = useState<Partial<IMetaProjeto> | null>(null);
  const [currentEtapa, setCurrentEtapa] = useState<Partial<IEtapa> | null>(null);
  const [selectedMetaId, setSelectedMetaId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    if (projetoId) {
      loadProjetoById(projetoId);
    }
  }, [projetoId]);

  useEffect(() => {
    if (selectedProjeto) {
      setFormData({
        titulo: selectedProjeto.titulo || '',
        descricao: selectedProjeto.descricao || '',
        cliente_id: selectedProjeto.cliente_id || '',
        data_inicio: selectedProjeto.data_inicio || '',
        data_fim: selectedProjeto.data_fim || '',
        status: selectedProjeto.status || 'planejamento'
      });
      setMetas(selectedProjeto.metas || []);
    }
  }, [selectedProjeto]);

  const handleFormChange = (field: string, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    
    try {
      if (projetoId) {
        await updateProjeto(projetoId, formData);
      } else {
        const newProjeto = await createProjeto(formData);
        projetoId = newProjeto.id;
      }
      setSuccess(true);
      setTimeout(() => {
        onSave();
      }, 1500);
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleMetaSave = async (metaData: any) => {
    try {
      if (currentMeta?.id) {
        await MetaProjetoService.update(currentMeta.id, metaData);
        setMetas(prev => prev.map(m => 
          m.id === currentMeta.id ? { ...m, ...metaData } : m
        ));
      } else {
        const newMeta = await MetaProjetoService.create({
          ...metaData,
          projeto_id: projetoId!
        });
        setMetas(prev => [...prev, newMeta]);
      }
      setMetaDialogOpen(false);
      setCurrentMeta(null);
      // Recarregar projeto
      if (projetoId) await loadProjetoById(projetoId);
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleEtapaSave = async (etapaData: any) => {
    try {
      if (currentEtapa?.id) {
        await EtapaService.update(currentEtapa.id, etapaData);
        // Atualizar a lista de metas
        if (projetoId) {
          const updated = await loadProjetoById(projetoId);
          setMetas(updated.metas || []);
        }
      } else {
        await EtapaService.create({
          ...etapaData,
          meta_projeto_id: selectedMetaId!
        });
        if (projetoId) {
          const updated = await loadProjetoById(projetoId);
          setMetas(updated.metas || []);
        }
      }
      setEtapaDialogOpen(false);
      setCurrentEtapa(null);
      setSelectedMetaId(null);
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleMetaDelete = async (id: string) => {
    if (window.confirm('Tem certeza que deseja excluir esta meta?')) {
      try {
        await MetaProjetoService.delete(id);
        setMetas(prev => prev.filter(m => m.id !== id));
        if (projetoId) await loadProjetoById(projetoId);
      } catch (err: any) {
        setError(err.message);
      }
    }
  };

  const handleEtapaDelete = async (id: string) => {
    if (window.confirm('Tem certeza que deseja excluir esta etapa?')) {
      try {
        await EtapaService.delete(id);
        if (projetoId) {
          const updated = await loadProjetoById(projetoId);
          setMetas(updated.metas || []);
        }
      } catch (err: any) {
        setError(err.message);
      }
    }
  };

  const totalMetas = metas.reduce((sum, meta) => sum + (meta.valor_previsto || 0), 0);
  const totalEtapas = metas.reduce((sum, meta) => sum + (meta.valor_total_etapas || 0), 0);

  return (
    <Box sx={{ p: 3 }}>
      <form onSubmit={handleSubmit}>
        {/* Dados do Projeto */}
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" gutterBottom>
            Dados do Projeto
          </Typography>
          <Divider sx={{ mb: 3 }} />
          
          <Grid container spacing={3}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                required
                label="Título do Projeto"
                value={formData.titulo}
                onChange={(e) => handleFormChange('titulo', e.target.value)}
                placeholder="Ex: Desenvolvimento Sistema X"
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                multiline
                rows={3}
                label="Descrição"
                value={formData.descricao || ''}
                onChange={(e) => handleFormChange('descricao', e.target.value)}
                placeholder="Descreva o projeto..."
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                required
                type="date"
                label="Data de Início"
                value={formData.data_inicio}
                onChange={(e) => handleFormChange('data_inicio', e.target.value)}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                required
                type="date"
                label="Data de Término"
                value={formData.data_fim}
                onChange={(e) => handleFormChange('data_fim', e.target.value)}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth required>
                <InputLabel>Status</InputLabel>
                <Select
                  value={formData.status}
                  label="Status"
                  onChange={(e) => handleFormChange('status', e.target.value)}
                >
                  <MenuItem value="planejamento">Planejamento</MenuItem>
                  <MenuItem value="em_andamento">Em Andamento</MenuItem>
                  <MenuItem value="concluido">Concluído</MenuItem>
                  <MenuItem value="cancelado">Cancelado</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                required
                label="ID do Cliente"
                value={formData.cliente_id}
                onChange={(e) => handleFormChange('cliente_id', e.target.value)}
                placeholder="UUID do cliente"
              />
            </Grid>
            <Grid item xs={12}>
              <Box sx={{ display: 'flex', gap: 3, p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
                <Box>
                  <Typography variant="caption" color="textSecondary">
                    Total Metas
                  </Typography>
                  <Typography variant="h6" color="primary">
                    {formatCurrency(totalMetas)}
                  </Typography>
                </Box>
                <Box>
                  <Typography variant="caption" color="textSecondary">
                    Total Etapas
                  </Typography>
                  <Typography variant="h6" color="secondary">
                    {formatCurrency(totalEtapas)}
                  </Typography>
                </Box>
              </Box>
            </Grid>
          </Grid>
        </Paper>

        {/* Metas */}
        <Paper sx={{ p: 3, mb: 3 }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="h6">Metas do Projeto</Typography>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={() => {
                setCurrentMeta(null);
                setMetaDialogOpen(true);
              }}
              disabled={!projetoId}
            >
              Adicionar Meta
            </Button>
          </Box>
          <Divider sx={{ mb: 2 }} />
          
          {metas.length === 0 ? (
            <Typography color="textSecondary" align="center" sx={{ py: 4 }}>
              Nenhuma meta cadastrada. Clique em "Adicionar Meta" para começar.
            </Typography>
          ) : (
            <Grid container spacing={2}>
              {metas.map((meta) => (
                <Grid item xs={12} key={meta.id}>
                  <Card variant="outlined">
                    <CardContent>
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <Box sx={{ flex: 1 }}>
                          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                            <Typography variant="subtitle1" fontWeight="bold">
                              {meta.nome}
                            </Typography>
                            <Chip
                              label={getStatusLabel(meta.status)}
                              color={getStatusColor(meta.status) as any}
                              size="small"
                            />
                          </Box>
                          {meta.descricao && (
                            <Typography variant="body2" color="textSecondary" gutterBottom>
                              {meta.descricao}
                            </Typography>
                          )}
                          <Box sx={{ display: 'flex', gap: 3, mt: 1 }}>
                            <Typography variant="caption" display="block">
                              <strong>Valor:</strong> {formatCurrency(meta.valor_previsto)}
                            </Typography>
                            <Typography variant="caption" display="block">
                              <strong>Período:</strong> {formatDate(meta.data_inicio)} - {formatDate(meta.data_fim)}
                            </Typography>
                            {meta.valor_total_etapas !== undefined && (
                              <Typography variant="caption" display="block">
                                <strong>Etapas:</strong> {formatCurrency(meta.valor_total_etapas)}
                              </Typography>
                            )}
                          </Box>
                        </Box>
                        <Box>
                          <Tooltip title="Adicionar Etapa">
                            <IconButton
                              size="small"
                              onClick={() => {
                                setSelectedMetaId(meta.id);
                                setCurrentEtapa(null);
                                setEtapaDialogOpen(true);
                              }}
                            >
                              <Add fontSize="small" />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="Editar Meta">
                            <IconButton
                              size="small"
                              onClick={() => {
                                setCurrentMeta(meta);
                                setMetaDialogOpen(true);
                              }}
                            >
                              <Edit fontSize="small" />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="Excluir Meta">
                            <IconButton
                              size="small"
                              onClick={() => handleMetaDelete(meta.id)}
                              color="error"
                            >
                              <Delete fontSize="small" />
                            </IconButton>
                          </Tooltip>
                        </Box>
                      </Box>

                      {/* Etapas da Meta */}
                      {meta.etapas && meta.etapas.length > 0 && (
                        <Box sx={{ mt: 2, pl: 3, borderLeft: '2px solid', borderColor: 'grey.300' }}>
                          <Typography variant="caption" fontWeight="bold" display="block" sx={{ mb: 1 }}>
                            Etapas ({meta.etapas.length})
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
                                  <Typography variant="caption" color="textSecondary">
                                    {formatDate(etapa.data_inicio)} - {formatDate(etapa.data_fim)}
                                  </Typography>
                                </Box>
                              </Box>
                              <Box>
                                <IconButton
                                  size="small"
                                  onClick={() => {
                                    setCurrentEtapa(etapa);
                                    setSelectedMetaId(etapa.meta_projeto_id);
                                    setEtapaDialogOpen(true);
                                  }}
                                >
                                  <Edit fontSize="small" />
                                </IconButton>
                                <IconButton
                                  size="small"
                                  onClick={() => handleEtapaDelete(etapa.id)}
                                  color="error"
                                >
                                  <Delete fontSize="small" />
                                </IconButton>
                              </Box>
                            </Box>
                          ))}
                        </Box>
                      )}
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
          )}
        </Paper>

        {/* Botões de Ação */}
        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
          <Button
            variant="outlined"
            onClick={onCancel}
            startIcon={<Cancel />}
          >
            Cancelar
          </Button>
          <Button
            type="submit"
            variant="contained"
            disabled={loading}
            startIcon={<Save />}
          >
            {loading ? 'Salvando...' : 'Salvar Projeto'}
          </Button>
        </Box>
      </form>

      {/* Modals */}
      <MetaFormFrame
        open={metaDialogOpen}
        meta={currentMeta}
        projetoId={projetoId || ''}
        onSave={handleMetaSave}
        onCancel={() => {
          setMetaDialogOpen(false);
          setCurrentMeta(null);
        }}
      />

      <EtapaFormFrame
        open={etapaDialogOpen}
        etapa={currentEtapa}
        metaId={selectedMetaId || ''}
        onSave={handleEtapaSave}
        onCancel={() => {
          setEtapaDialogOpen(false);
          setCurrentEtapa(null);
          setSelectedMetaId(null);
        }}
      />

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
          Projeto salvo com sucesso!
        </Alert>
      </Snackbar>
    </Box>
  );
};