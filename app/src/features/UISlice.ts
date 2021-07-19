import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState, AppThunk } from '../app/store';

export interface UIState {
  menuVisible: boolean;
}

const initialState: UIState = {
  menuVisible: false
};

export const UISlice = createSlice({
  name: 'UI',
  initialState,
  // The `reducers` field lets us define reducers and generate associated actions
  reducers: {
    setMenuVisible: (state, action: PayloadAction<boolean>) => {
      state.menuVisible = action.payload
    }
  }
});

export const { setMenuVisible } = UISlice.actions;

// The function below is called a selector and allows us to select a value from
// the state. Selectors can also be defined inline where they're used instead of
// in the slice file. For example: `useSelector((state: RootState) => state.counter.value)`
export const selectVisible = (state: RootState) => state.ui.menuVisible

export default UISlice.reducer;
