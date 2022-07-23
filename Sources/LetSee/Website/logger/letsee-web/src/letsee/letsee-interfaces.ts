export interface IRequest {
    method: string,
    status_code: number,
    content_length: number,
    headers: Array<IKeyValue>,
    body?: string,
    took_time?: string,
    url?: string
}

export interface IKeyValue {
    key: string, 
    value: string
}

export interface ICardItem {
    id: string,
    url: string,
    method: string,
    waiting: boolean,
    isSuccess: boolean,
    status_code: number,
    tookTime: string,
    requestLength: string,
    responseLength: string
}

export interface ConnectionConfig{"webSocketPort": number, "baseURL": string}