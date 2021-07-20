import React from "react";
import { Button, Dropdown, Icon, Menu, Segment } from "semantic-ui-react";
import { useAppSelector, useAppDispatch } from '../app/hooks'
import { selectVisible, setMenuVisible } from '../features/UISlice'

export default function NavMenu() {
const visible = useAppSelector(selectVisible)
const dispatch = useAppDispatch()

    return (
        <div>
        <Button primary icon onClick={() => dispatch(setMenuVisible(!visible))}>
          <Icon name='angle double down' size='large' />
        </Button>
        </div>
    )


}
