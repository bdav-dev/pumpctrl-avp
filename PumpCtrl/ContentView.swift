import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct ContentView: View {
    private static let userDefaultsUrlKey = "pumpctrlapiurl"
    
    @State private var timer: AnyCancellable?
    
    @State private var urlTextFieldValue: String = ""
    @State private var pumpIntensitySliderValue: Float = 0.0
    
    @State private var pumpIntensity: Float = 0.0
    @State private var flowrate: Float?
    @State private var url: String = ""
    @State private var showSettings = false
    
    var formattedFlowrate: String {
        if let flowrate = flowrate {
            return String(format: "%.2f", flowrate)
                .replacingOccurrences(of: ".", with: ",")
        } else {
            return "-"
        }
    }
    
    var formattedPumpIntensity: String {
        return String(Int(pumpIntensity))
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Text("PumpCtrl")
                    .font(.largeTitle)
            }
            
            Spacer()
            
            if flowrate != nil {
                VStack {
                    HStack {
                        Text("Pump Level:")
                        Spacer()
                    }
                    Slider(
                        value: $pumpIntensitySliderValue,
                        in: 0...100
                    ) { pressed in
                        Task {
                            pumpIntensity = pumpIntensitySliderValue
                            await setPumpIntensity(url: url, intensity: pumpIntensity)
                        }
                    }
                    HStack {
                        Spacer()
                        Text("\(formattedPumpIntensity)%")
                            .font(.system(.body, design: .monospaced))
                    }
                }
                .padding()
                
                Divider()
                
                HStack {
                    Spacer()
                    Text("Flowrate: ")
                    TextField("-", text: .constant(formattedFlowrate))
                        .allowsHitTesting(false)
                        .font(.system(.body, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .fixedSize()
                    Text("m/s")
                }
                
                
            } else {
                Text("Not connected")
                    .foregroundStyle(.red)
                    .font(.largeTitle)
            }
            
            Spacer()
            
            HStack(alignment: .bottom) {
                Text("v1.0")
                    .font(.system(.body, design: .monospaced))
                    .padding()
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.system(size: 30))
                        .padding()
                }
                .frame(width: 55, height: 55)
            }
            
        }
        .sheet(isPresented: $showSettings, content: {
            VStack {
                HStack {
                    Button(action: {
                        showSettings = false
                        urlTextFieldValue = url
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 25))
                            .padding()
                    }
                    .frame(width: 30, height: 30)
                    .padding()
                    
                    Spacer()
                }
                
                LabeledContent {
                    TextField("URL", text: $urlTextFieldValue)
                        .font(.system(.body, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textCase(.lowercase)
                } label: {
                    Text("URL")
                }
                .padding()
                
                Button(action: {
                    let formattedUrl = urlTextFieldValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    UserDefaults.standard.set(formattedUrl, forKey: ContentView.userDefaultsUrlKey)
                    url = formattedUrl
                    
                    showSettings = false
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding()
        })
        .onAppear {
            url = UserDefaults.standard.string(forKey: ContentView.userDefaultsUrlKey) ?? ""
            urlTextFieldValue = url
            
            triggerLocalNetworkPrivacyAlert()
            
            timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
                .sink { _ in
                    Task {
                        self.flowrate =  await getFlowrate(url: url)
                    }
                }
        }
        .onDisappear {
            timer?.cancel()
        }
        .padding()
    }
    
}
