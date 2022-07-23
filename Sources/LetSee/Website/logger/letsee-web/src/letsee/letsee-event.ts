import { IRequest } from "./letsee-interfaces";

export interface IEvent {
    id: string,
    response?: IRequest,
    type: string, 
    request: IRequest,
    waiting: boolean,
    isSuccess(): boolean
}

export default class LetSeeEvent implements IEvent {
    id: string;
    response?: IRequest | undefined;
    type: string;
    request: IRequest;
    waiting: boolean;
    isSuccess(): boolean {
        const statusCode = this.response?.status_code || this.request?.status_code || 400
        return statusCode >= 200 && statusCode < 300;
    }

    constructor(event: IEvent) {
        this.id = event.id;
        this.response = event.response;
        this.type = event.type;
        this.request = event.request;
        this.waiting = event.waiting;
    }
}