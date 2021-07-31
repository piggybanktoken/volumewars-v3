import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState, AppThunk } from '../app/store';

export interface UIState {
  menuVisible: boolean,
  attackModal: {
    team: string,
    open: boolean
  }
}

const initialState: UIState = {
  menuVisible: false,
  attackModal: {
    team: "0",
    open: false,
  }
};

export const UISlice = createSlice({
  name: 'UI',
  initialState,
  // The `reducers` field lets us define reducers and generate associated actions
  reducers: {
    setMenuVisible: (state, action: PayloadAction<boolean>) => {
      state.menuVisible = action.payload
    },
    openAttackModal: (state, action: PayloadAction<string>) => {
      state.attackModal.open = true
      state.attackModal.team = action.payload
    },
    closeAttackModal: (state, action: PayloadAction<{}>) => {
      state.attackModal.open = false
    }
  }
});

export const { setMenuVisible, openAttackModal, closeAttackModal } = UISlice.actions;

// The function below is called a selector and allows us to select a value from
// the state. Selectors can also be defined inline where they're used instead of
// in the slice file. For example: `useSelector((state: RootState) => state.ui.menuVisible)`
export const selectVisible = (state: RootState) => state.ui.menuVisible

export const selectAttackModalOpen = (state: RootState) => state.ui.attackModal.open

export const selectAttackModalTeam = (state: RootState) => state.ui.attackModal.team


export default UISlice.reducer;
