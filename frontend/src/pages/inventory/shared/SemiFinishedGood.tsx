import { TextField, InputAdornment } from '@material-ui/core';
import { Card } from '../../../components';
import Recipe from './Recipe';

export default function SemiFinishedGood() {
  return (
    <Card>
      <p>Semi-Finished Good</p>
      <label htmlFor="cost">Manufacturing Cost</label>
      <TextField
        type="number"
        inputProps={{ min: '0.01', step: '0.01' }}
        id="cost"
        name="cost"
        variant="outlined"
        required
        fullWidth
        InputProps={{
          startAdornment: <InputAdornment position="start">$</InputAdornment>
        }}
      />

      <Recipe />

      <label htmlFor="manufacturing-time">Manufacturing Time</label>
      <TextField
        required
        type="number"
        inputProps={{ min: '0.01', step: '0.01' }}
        id="manufacturing-time"
        name="manufacturing-time"
        variant="outlined"
        fullWidth
        InputProps={{
          endAdornment: <InputAdornment position="end">minutes</InputAdornment>
        }}
      />
    </Card>
  );
}
