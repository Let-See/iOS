import LetSeeEvent, { IEvent } from "./letsee-event"
import { ConnectionConfig, ICardItem } from "./letsee-interfaces"
import WS from "WebSocket"
export default class LetSee {
    readonly baseURL?: string
    private _events: Array<IEvent> = []
    private _cards: Array<ICardItem> = []
    private observers: Array<[Object, (letSee: LetSee)=>{}]> = []
    private _showDetails: IEvent | null  = null
    private ws?: WebSocket 
    private wsRestartTimer?: NodeJS.Timer
    set showDetails(newValue: IEvent | null) {
        if (newValue === this._showDetails) {return}
        this._showDetails = newValue
        this.observers.forEach(ob => ob[1](this))
    }
    get showDetails(): IEvent | null {
        return this._showDetails 
    }

    set cards(newValue: Array<ICardItem>) {
        this._cards = newValue
        this.observers.forEach(ob => ob[1](this))
    }
    get cards(): Array<ICardItem> {
        return this._cards 
    }

    set events(newValue: Array<IEvent>) {
        this._events = newValue
        this.observers.forEach(ob => ob[1](this))
    }
    get events(): Array<IEvent> {
        return this._events 
    }
    
    constructor(baseURL?: string){
        this.baseURL = baseURL
        const tempEvent = new LetSeeEvent({"id":"7E2D89A8-42C4-42FC-BE3D-1BAA8886C8CE","response":{"method": "" ,"body":"{\"email\":{\"title\":\"Email us\",\"sub_title\":\"Get in touch by email\",\"email\":\"service@1sell.com\"},\"phone\":{\"title\":\"Order by phone\",\"sub_title\":\"Available every day\",\"phone_number\":\"+974 7774 9351\"}}","headers":[{"key":"Server","value":"cloudflare"},{"key":"Content-Type","value":"application/json"},{"key":"grpc-metadata-content-type","value":"application/grpc+proto"},{"key":"expect-ct","value":"max-age=604800, report-uri='https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct'"},{"key":"report-to","value":"{'endpoints':[{'url':'https://a.nel.cloudflare.com/report/v3?s=XX2Z3So39a4bbuP3%2F01upNIei626NYLfkRZ9%2B2CPPmdq9dpfyqOg5FzwRCFR5rjYeTgGJfdclpBP8%2F1%2BI%2FyuQAA5lbyM0ctEMj2Oej6pki3BMZhEP9I%2BVjbCqS7cStpadbgzjz99gA%3D%3D'}],'group':'cf-nel','max_age':604800}"},{"key":"Date","value":"Fri, 22 Jul 2022 18:51:21 GMT"},{"key":"nel","value":"{'success_fraction':0,'report_to':'cf-nel','max_age':604800}"},{"key":"Vary","value":"Origin"},{"key":"grpc-metadata-date","value":"Fri, 22 Jul 2022 18:51:21 GMT"},{"key":"Content-Encoding","value":"br"},{"key":"cf-ray","value":"72ee5e052e2d7531-LHR"},{"key":"grpc-metadata-grpc-accept-encoding","value":"identity,deflate,gzip"},{"key":"cf-cache-status","value":"DYNAMIC"},{"key":"Via","value":"1.1 google"}],"status_code":200,"content_length":120,"took_time":"-"},"type":"response","request":{"method":"GET","status_code":0,"content_length":0,"headers":[{"key":"OS-Version","value":"15.5"},{"key":"Accept","value":"application/json"},{"key":"User-Agent","value":"App/1.3.3 (org.metatude.onesell.qa; build:92; iOS 15.5.0) Alamofire/5.6.1"},{"key":"OS","value":"iOS"},{"key":"Accept-Encoding","value":"gzip, deflate, br"},{"key":"Build","value":"92"},{"key":"LETSEE-LOGGER-ID","value":"7E2D89A8-42C4-42FC-BE3D-1BAA8886C8CE"},{"key":"Accept-Language","value":"en"},{"key":"Authorization","value":"Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImJmMWMyNzQzYTJhZmY3YmZmZDBmODRhODY0ZTljMjc4ZjMxYmM2NTQiLCJ0eXAiOiJKV1QifQ.eyJwcm92aWRlcl9pZCI6ImFub255bW91cyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9vbmUtc2VsbC1zdGFnaW5nIiwiYXVkIjoib25lLXNlbGwtc3RhZ2luZyIsImF1dGhfdGltZSI6MTY1ODUxNTgyOSwidXNlcl9pZCI6ImU1azVmd3o3TWFXMXdCUEVyTXg4cWN3YlNaVDIiLCJzdWIiOiJlNWs1Znd6N01hVzF3QlBFck14OHFjd2JTWlQyIiwiaWF0IjoxNjU4NTE1ODgwLCJleHAiOjE2NTg1MTk0ODAsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnt9LCJzaWduX2luX3Byb3ZpZGVyIjoiYW5vbnltb3VzIn19.JmjYOPBgBUTa196bO4VnnS1dVbk9c4sWjgi6ny7oXRZaaBVMgHNbeQl6qcqlLVy2yUeeBTV-zQKZxQaNuEGfJhI71xSAQb7qfnJzM6RsbKsm3rx4wQxBUWhUvkP3Cjpcwex83lG3y7eCIDmL49hVR19ahtPF408B5Rf9UCAkAP1sVIGnT8Wec4UOP5zHP45g0PfpBBwyXaKAtQ0lJpG2e1KNGkD8KioJdaiWrrzLw8bNttOv3SpObAe02j-QFeoJ9-Oe32F0BpQY07llbZHgZCsF9K-ETaAwS-HTq3P5rRoJY5HPkacbqHcUu2KuTRVZjhCxznWVyLrgW8xPCoyc6A"},{"key":"Version","value":"1.3.3"},{"key":"Content-Type","value":"application/json"},{"key":"Device-Type","value":"iPhone 12 Pro Max"},{"key":"Theme","value":"automatic"}],"body":"{}","took_time":"-","url":"https://api-staging.1sell.com/contacts"},"waiting":false, isSuccess: ()=> true})
        this.events = [tempEvent]
        this.cards = [this.makeCardItem(this.events[0])]
        this.showDetails = null
        this.observers = []

        this.getConfig()
    }

    subscribe(obj: Object,cb: (letSee: LetSee)=>{}) {
        this.observers.push([obj,cb])
    }

    ubsubscribe(obj: Object) {
        this.observers = this.observers.filter((item) => item[0] === obj)
    }

    search(query: string): Array<IEvent> {
        let q = query.toLowerCase()
        return this.events.filter(item => item.id.toLowerCase().includes(q) || item.request.url?.toLowerCase().includes(q))
    }

    clear() {
        this.events = []
    }

    beutifyBody(body: string) {
        try {
            return (
                '<pre><code class="json">' +
                JSON.stringify(JSON.parse(body), null, 2) +
                "</code></pre>"
            );
        } catch (error) {
            return body;
        }    
    }

    getCurrentTime(): String {
        var today = new Date();
        var date =
            today.getFullYear() +
            "-" +
            (today.getMonth() + 1) +
            "-" +
            today.getDate();
        var time =
            today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        return date + " " + time;
    }

    onReceive(event: IEvent) {
        let e = new LetSeeEvent(event)
        this._events.push(e)
        this.events = this._events
        let cardItem = this.makeCardItem(e)
        this._cards.push(cardItem)
        this.cards = this._cards
    }

    private makeCardItem(event: IEvent): ICardItem {
        const request = event.request;
        const response = event.response;
        const id = event.id;
        const url = this.replaceBaseURL(request.url)
        const method = request.method;
        const waiting = event.waiting;
        const isSuccess = event.isSuccess()
        const status_code = response?.status_code ?? request.status_code
        const tookTime = `${response?.took_time ?? "-"}`
        const responseLength = response?.content_length ?? 0
        const requestLength = request.content_length ?? 0
        const responseContentLength = responseLength > 1000 ? this.byteToKB(responseLength) + " kilobytes" : responseLength + " bytes";
        const requestContentLength = responseLength > 1000 ? this.byteToKB(requestLength) + " kilobytes" : requestLength + " bytes";

        return {
            id,
            url,
            method,
            waiting,
            isSuccess,
            status_code,
            tookTime,
            requestLength: requestContentLength,
            responseLength: responseContentLength
        }
    }

    private byteToKB(bytes: number): number {
        return bytes / 1000
    }

    private replaceBaseURL(url?: string): string {
        if (url == null) {return ""}
        if (this.baseURL != null) {
            return url.replace(this.baseURL, "<strong> {BASE_URL} </strong>/");
        } else {
            return url
        }
    }

    showRequestDetails(id: string){
        let selectedEvent = this.events.filter(request => request.id === id)[0]
        this.showDetails = this.showDetails === selectedEvent ? null : selectedEvent
    }

    private getConfig() {
        fetch(new  URL("config",window.location.href))
        .then(configs => configs.json())
        .then((configs: ConnectionConfig) => {
            console.log(configs)
            this.connectWS(configs)
        })
    }

    private connectWS(configs: ConnectionConfig) {
        const location = window.location
        let timer = this.wsRestartTimer
        var wesocketAddress =
        "ws://" + location.hostname + ":" + configs.webSocketPort + "/ws";
        // Let us open a web socket
        const websocket= new WebSocket(wesocketAddress)

        websocket.onopen = () => {
            timer = undefined
            websocket.send('{"connected": true}');
        };
        const receive = this.onReceive
        websocket.onmessage = function(evt) {
            var data = evt.data;
            var received_msg: IEvent = JSON.parse(data);
            receive(received_msg)
        };

        const reset = this.connectWS
        websocket.onclose = function() {
            timer = undefined
            // websocket is closed.
            timer = setTimeout(()=> {
                reset(configs)
            }, 3000);
        };
        
        this.ws = websocket
    }
}