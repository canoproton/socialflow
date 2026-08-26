// src/modules/projetos/components/MetaFormFrame.tsx

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
import { IMetaProjeto } from '../types';

interface MetaFormFrameProps {
  open: boolean;
  meta?: Partial<IMetaProjeto> | null;
  projetoId: string;
  onSave: (data: any) => void;
  onCancel: () => void;
}

export const MetaFormFrame: React.FC<MetaFormFrameProps> = ({
  open,
  meta,
  projetoId,
  onSave,
  onCancel
}) => {
  const [formData, setFormData] = useState<Partial<IMetaProjeto>>({
    projeto_id: projetoId,
    nome: '',
    descricao: '',
    valor_previsto: 0,
    data_inicio: '',
    data_fim: '',
    status: 'pendente'
  });

  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (meta) {
      setFormData(meta);
    } else {
      setFormData({
        projeto_id: projetoId,
        nome: '',
        descricao: '',
        valor_previsto: 0,
        data_inicio: '',
        data_fim: '',
        status: 'pendente'
      });
    }
  }, [meta, projetoId]);

  const handleChange = (field: keyof IMetaProjeto, value: any) => {
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
            {meta?.id ? 'Editar Meta' : 'Nova Meta'}
          </Typography>
        </DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                required
                label="Nome da Meta"
                value={formData.nome || ''}
                onChange={(e) => handleChange('nome', e.target.value)}
                placeholder="Ex: Desenvolvimento do Módulo X"
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                multiline
                rows={3}
                label="Descrição"
                value={formData.descricao || ''}
                onChange={(e) => handleChange('descricao', e.target.value)}
                placeholder="Descreva a meta detalhadamente..."
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
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={onCancel}>Cancelar</Button>
          <Button onClick={handleSubmit} variant="contained" color="primary">
            {meta?.id ? 'Atualizar' : 'Criar'}
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