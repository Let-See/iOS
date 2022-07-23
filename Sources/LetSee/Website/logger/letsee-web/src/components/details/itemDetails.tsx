import React from "react";
import { IEvent } from "../../letsee/letsee-event";

interface IProps {
  item: IEvent;
}

export const ItemDetails = (prop: IProps) => {
  return (
    <div className="main-viewer">
      <div className="wrapper data-container fade-animatable">
        <ul className="tabs clearfix" data-tabgroup="first-tab-group">
          <li>
            <a href="#response_container">Response Data</a>
          </li>
          <li>
            <a className="active" href="#request_container">
              Request Data
            </a>
          </li>
          <li>
            <a href="#response_headers">Response Headers</a>
          </li>
          <li>
            <a href="#request_headers">Request Headers</a>
          </li>
        </ul>
        <section className="tabgroup fade-animatable" id="first-tab-group">
          <div className="tab-container fade-animatable" id="request_container">
            <div id="request_params_container">
              <div id="request_url">{prop.item.request.url}</div>
              <div id="params_title">Query Parameters</div>
              <div id="request_params">{prop.item.request.url}</div>
            </div>
            <div id="request_data">{prop.item.request.body}</div>
          </div>
          <div
            className="tab-container fade-animatable"
            id="response_container"
          >
            <div id="response_data">{prop.item.response?.body}</div>
          </div>
          <div className="tab-container fade-animatable" id="request_headers">
            {prop.item.request.headers.map((k, v) => `<p>${k}: ${v}</p>`)}
          </div>
          <div className="tab-container fade-animatable" id="response_headers">
            {prop.item.response?.headers.map((k, v) => `<p>${k}: ${v}</p>`)}
          </div>
        </section>
      </div>
    </div>
  );
};
