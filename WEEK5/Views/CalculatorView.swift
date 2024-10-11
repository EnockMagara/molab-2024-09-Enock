import SwiftUI

struct CalculatorView: View {
    @State private var transportationInput: String = ""
    @State private var energyInput: String = ""
    @State private var result: String = ""

    var body: some View {
        VStack {
            Text("Carbon Footprint Calculator")
                .font(.largeTitle)
                .padding()

            TextField("Transportation (km)", text: $transportationInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Energy Use (kWh)", text: $energyInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: calculateFootprint) {
                Text("Calculate")
            }
            .padding()

            Text(result)
                .padding()
        }
        .padding()
    }

    func calculateFootprint() {
        let transportation = Double(transportationInput) ?? 0
        let energy = Double(energyInput) ?? 0
        let footprint = (transportation * 2.5) + (energy * 1.5)
        result = "Your Carbon Footprint: \(footprint) kg CO2"
    }
}
