// src/modules/projetos/components/EtapaFormFrame.tsx

import React, { useState, useEffect } from 'react';
import {
  Box,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Grid,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Typography,
  Alert,
  Snackbar
} from '@mui/material';
import { IEtapa } from '../types';

interface EtapaFormFrameProps {
  open: boolean;
  etapa?: Partial<IEtapa> | null;
  metaId: string;
  onSave: (data: any) => void;
  onCancel: () => void;
}

export const EtapaFormFrame: React.FC<EtapaFormFrameProps> = ({
  open,
  etapa,
  metaId,
  onSave,
  onCancel
}) => {
  const [formData, setFormData] = useState<Partial<IEtapa>>({
    meta_projeto_id: metaId,
    nome: '',
    descricao: '',
    valor_previsto: 0,
    data_inicio: '',
    data_fim: '',
    status: 'pendente',
    ordem: 0
  });

  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (etapa) {
      setFormData(etapa);
    } else {
      setFormData({
        meta_projeto_id: metaId,
        nome: '',
        descricao: '',
        valor_previsto: 0,
        data_inicio: '',
        data_fim: '',
        status: 'pendente',
        ordem: 0
      });
    }
  }, [etapa, metaId]);

  const handleChange = (field: keyof IEtapa, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSubmit = () => {
    // Validações
    if (!formData.nome || !formData.valor_previsto || !formData.data_inicio || !formData.data_fim) {
      setError('Preencha todos os campos obrigatórios');
      return;
    }

    if (new Date(formData.data_fim) < new Date(formData.data_inicio)) {
      setError('Data de fim não pode ser anterior à data de início');
      return;
    }

    onSave(formData);
  };

  return (
    <>
      <Dialog open={open} onClose={onCancel} maxWidth="md" fullWidth>
        <DialogTitle>
          <Typography variant="h6">
            {etapa?.id ? 'Editar Etapa' : 'Nova Etapa'}
          </Typography>
        </DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                required
                label="Nome da Etapa"
                value={formData.nome || ''}
                onChange={(e) => handleChange('nome', e.target.value)}
                placeholder="Ex: Análise de Requisitos"
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                multiline
                rows={2}
                label="Descrição"
                value={formData.descricao || ''}
                onChange={(e) => handleChange('descricao', e.target.value)}
                placeholder="Descreva a etapa detalhadamente..."
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                required
                type="number"
                label="Valor Previsto (R$)"
                value={formData.valor_previsto || ''}
                onChange={(e) => handleChange('valor_previsto', parseFloat(e.target.value) || 0)}
                InputProps={{
                  startAdornment: 'R$',
                  inputProps: { min: 0, step: 0.01 }
                }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth required>
                <InputLabel>Status</InputLabel>
                <Select
                  value={formData.status || 'pendente'}
                  label="Status"
                  onChange={(e) => handleChange('status', e.target.value)}
                >
                  <MenuItem value="pendente">Pendente</MenuItem>
                  <MenuItem value="em_andamento">Em Andamento</MenuItem>
                  <MenuItem value="concluida">Concluída</MenuItem>
                  <MenuItem value="cancelada">Cancelada</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                required
                type="date"
                label="Data Início"
                value={formData.data_inicio || ''}
                onChange={(e) => handleChange('data_inicio', e.target.value)}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                required
                type="date"
                label="Data Fim"
                value={formData.data_fim || ''}
                onChange={(e) => handleChange('data_fim', e.target.value)}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                type="number"
                label="Ordem"
                value={formData.ordem || 0}
                onChange={(e) => handleChange('ordem', parseInt(e.target.value) || 0)}
                InputProps={{ inputProps: { min: 0 } }}
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={onCancel}>Cancelar</Button>
          <Button onClick={handleSubmit} variant="contained" color="primary">
            {etapa?.id ? 'Atualizar' : 'Criar'}
          </Button>
        </DialogActions>
      </Dialog>

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
    </>
  );
};