import React from "react";
import { Button, Dropdown, Icon, Menu, Segment } from "semantic-ui-react";
// TODO Make work

export default function NavMenu() {

    const [visible, setVisible] = React.useState(false)

    return (
        <div>
        <Button primary icon onClick={() => setVisible(!visible)}>
          <Icon name='angle double down' size='large' />
        </Button>
        </div>
    )


}
