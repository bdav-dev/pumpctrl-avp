import Foundation

struct FlowrateResponse: Codable {
    let flowrate: Float
}

func getFlowrate(url: String) async -> Float? {
    let url = URL(
        string: formatUrlString(url) + "flowrate"
    );
    
    guard let url = url else {
        return nil;
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    do {
        let (data, _) = try await URLSession.shared.data(for: request);
        let flowrateResponse = try JSONDecoder().decode(FlowrateResponse.self, from: data);
        return flowrateResponse.flowrate;
    } catch {
        return nil;
    }
}

func setPumpIntensity(url: String, intensity: Float) async {
    let url = URL(
        string: formatUrlString(url) + "pumpctrl"
    );
    
    guard let url = url else {
        return;
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let bodyData: [String: Any] = ["signal": String(Int(intensity))]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyData, options: []) else {
        return
    }
    request.httpBody = httpBody

    let _ = try? await URLSession.shared.data(for: request)
}



func formatUrlString(_ url: String) -> String {
    if !url.hasSuffix("/") {
        return url + "/";
    }
    
    return url;
}
