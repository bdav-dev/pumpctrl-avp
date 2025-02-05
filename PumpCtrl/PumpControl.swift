import Foundation

struct FlowrateResponse: Codable {
    let flowrate: Float
}

let flowrateURLSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.httpMaximumConnectionsPerHost = 55
    return URLSession(configuration: configuration)
}()

let pumpIntensityURLSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.httpMaximumConnectionsPerHost = 15
    return URLSession(configuration: configuration)
}()

func getFlowrate(url: String) async -> Float? {
    let url = URL(
        string: formatUrlString(url) + "flowrate"
    )
    
    guard let url = url else {
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    do {
        let (data, _) = try await flowrateURLSession.data(for: request)
        let flowrateResponse = try JSONDecoder().decode(FlowrateResponse.self, from: data)
        return flowrateResponse.flowrate
    } catch {
        return nil
    }
}

func setPumpIntensity(url: String, intensity: Float) async {
    let url = URL(
        string: formatUrlString(url) + "pumpctrl"
    )
    
    guard let url = url else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let bodyData: [String: Any] = ["pumpSetting": intensity]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyData, options: []) else {
        return
    }
    request.httpBody = httpBody
    
    let _ = try? await pumpIntensityURLSession.data(for: request)
}



func formatUrlString(_ url: String) -> String {
    if !url.hasSuffix("/") {
        return url + "/"
    }
    
    return url
}
