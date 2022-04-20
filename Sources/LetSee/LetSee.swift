final class LetSee {
    private var webServer: WebServer
    init(_ baseUrl: String = "") {
        self.webServer = .init(apiBaseUrl: baseUrl)
    }
}
