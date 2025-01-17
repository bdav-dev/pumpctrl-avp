import Foundation

struct FlowrateResponse: Codable {
    let flowrate: Float
}

func getFlowrate() async -> Float? {
    let urlString = "http://192.168.220.1:1880/flowrate"
    let url = URL(string: urlString)
    
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"

    do {
        let (data, _) = try await URLSession.shared.data(for: request);
        let flowrateResponse = try JSONDecoder().decode(FlowrateResponse.self, from: data);
        return flowrateResponse.flowrate;
    } catch {
        return nil;
    }
}

func setPumpIntensity(intensity: Float) async {
    let urlString = "http://192.168.220.1:1880/pumpctrl"
    let url = URL(string: urlString)
    
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let bodyData: [String: Any] = ["signal": intensity]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyData, options: []) else {
        print("Failed to serialize JSON")
        return
    }
    request.httpBody = httpBody

    let _ = try? await URLSession.shared.data(for: request)
}
