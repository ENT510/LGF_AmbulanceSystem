import React, { useEffect, useState } from "react";
import { Button } from "@mantine/core";
import Shop from "./Menu";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { isEnvBrowser } from "../utils/misc";
import "./index.scss";

import { fetchNui } from "../utils/fetchNui";

const App: React.FC = () => {
  const [deathScrinVisible, setDeathScreenVisible] = useState(false);
  const [deathSeconds, setDeathSeconds] = useState(60);

  useNuiEvent<any>("openDeathScreen", (data) => {
    setDeathSeconds(data.DeathSeconds);
    setDeathScreenVisible(data?.Display);
  });


  return (
    <>
      <Shop
        visible={deathScrinVisible}
        deathSeconds={deathSeconds}
        binderRevive={"E"}
      />
  
      {isEnvBrowser() && (
        <div style={{ position: "fixed", top: 10, right: 10, zIndex: 1000 }}>
          <Button
            onClick={() => setDeathScreenVisible((prev) => !prev)}
            variant="default"
            color="orange"
          >
            Toggle Shop
          </Button>

        </div>
      )}
    </>
  );
};

export default App;
