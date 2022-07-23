import React, { useState } from "react";
import "./App.css";
import "./letsee/letsee";
import { ItemDetails } from "./components/details/itemDetails";
import { CardItemList } from "./components/card/cardItemList";
import { LetSeeContext } from "./letsee/letsee-context";
import LetSee from "./letsee/letsee";
const letsee = new LetSee();
function App() {
  const [requestDetails, setRequestDetails] = useState(letsee.showDetails);
  const [cards] = useState(letsee.cards);
  letsee.subscribe(setRequestDetails, async (ls) =>
    setRequestDetails(ls.showDetails)
  );

  return (
    <div className="App">
      <LetSeeContext.Provider value={letsee}>
        {requestDetails ? <ItemDetails item={requestDetails!} /> : ""}
        <CardItemList items={cards} />
      </LetSeeContext.Provider>
    </div>
  );
}

export default App;
