import React from "react"; // we need this to make JSX compile
import { ICardItem } from "../../letsee/letsee-interfaces";
interface IProps {
  item: ICardItem;
  onClick: (id: string) => void;
}
export const ItemCard = (card: IProps) => {
  const classname = card.item.waiting
    ? " pending-response "
    : card.item.isSuccess
    ? "success"
    : "failure";
  const success = card.item.waiting
    ? ""
    : card.item.isSuccess
    ? "SUCCESS"
    : "FAILED";

  return (
    <div
      className={classname + "animatable request card"}
      id={card.item.id}
      request-id={card.item.id}
      onClick={(e) => card.onClick(card.item.id)}
    >
      <div className="url">
        <h3>${card.item.method}</h3>
        <h2>${card.item.url}</h2>
      </div>
      <div className="meta">
        <div className="response">
          <span className="length">${card.item.requestLength}</span>
          <span className="response_length">
            <strong>${card.item.responseLength}</strong>
          </span>
        </div>
        <div className="date-container">
          <span className="time">
            <strong>${card.item.tookTime}</strong>ms
          </span>
          <span className="date">${card.item.tookTime}</span>
          <button className="copy" title="copy">
            copy
          </button>
        </div>
      </div>
    </div>
  );
};
