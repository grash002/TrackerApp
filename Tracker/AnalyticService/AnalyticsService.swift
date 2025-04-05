import AppMetricaCore

final class AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: Configuration.apiKey) else { return }
        AppMetrica.activate(with: configuration)
    }
    
    static func report(event: String, params: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { (error) in
            print("DID FAIL REPORT EVENT: %@", event)
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

