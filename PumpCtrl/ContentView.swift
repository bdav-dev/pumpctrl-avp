import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct ContentView: View {
    @State private var timer: AnyCancellable?
    @State private var pumpIntensitySliderValue: Float = 0.0
    @State private var pumpIntensity: Float = 0.0
    @State private var flowrate: Float?
    
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
                            await setPumpIntensity(intensity: pumpIntensity)
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
                Button(action: {
                    // TODO
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 30))
                        .padding()
                }
                .frame(width: 55, height: 55)
            }
            
            
        }
        .onAppear {
            timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
                .sink { _ in
                    Task {
                        self.flowrate =  await getFlowrate();
                    }
                }
        }
        .onDisappear {
            timer?.cancel()
        }
        .padding()
    }
    
}
