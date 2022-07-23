import React, { useContext } from "react";

import { LetSeeContext } from "../../letsee/letsee-context";
import { ICardItem } from "../../letsee/letsee-interfaces";
import { ItemCard } from "./cardItem";
interface IProps {
  items: Array<ICardItem>;
}
export const CardItemList = (prop: IProps) => {
  const letSee = useContext(LetSeeContext);

  return (
    <div className="main-requests">
      <div className="search_box">
        <input
          className="textbox"
          id="url_search"
          placeholder="Search in URLs"
          type="text"
        />
      </div>
      <div className="base-url">
        BASE URL:
        <div>
          <strong id="base_url">- base url -</strong>
        </div>
      </div>
      <div id="requests_container">
        {prop.items.map((item) => (
          <ItemCard
            item={item}
            key={item.id}
            onClick={(id: string) => {
              letSee.showRequestDetails(id);
            }}
          />
        ))}
      </div>
      <div className="horizontal-vertical-center" id="empty-box">
        <strong className="empty-text">No Request Received Yet.</strong>
        <div>
          <img className="empty-image" src="/resources/empty.png" alt=""></img>
        </div>
      </div>
      <button id="clear-button" value="Clear">
        Clear
      </button>
    </div>
  );
};
