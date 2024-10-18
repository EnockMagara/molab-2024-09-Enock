import SwiftUI

struct CalculatorView: View {
    @State private var distanceInput: String = ""
    @State private var fuelEfficiencyInput: String = ""
    @State private var emissionFactorInput: String = ""
    @State private var result: String = ""
    @State private var errorMessage: String? = nil // State for error message

    var body: some View {
        VStack {
            Text("Carbon Footprint Calculator")
                .font(.largeTitle)
                .padding()

            TextField("Distance Traveled (km)", text: $distanceInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Fuel Efficiency (L/km)", text: $fuelEfficiencyInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Emission Factor (kg CO2/L)", text: $emissionFactorInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

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
        guard let distance = Double(distanceInput), distance >= 0 else {
            errorMessage = "Please enter a valid number for distance."
            return
        }
        
        guard let fuelEfficiency = Double(fuelEfficiencyInput), fuelEfficiency > 0 else {
            errorMessage = "Please enter a valid number for fuel efficiency."
            return
        }
        
        guard let emissionFactor = Double(emissionFactorInput), emissionFactor > 0 else {
            errorMessage = "Please enter a valid number for emission factor."
            return
        }
        
        errorMessage = nil // Clear error message if inputs are valid
        let footprint = distance * fuelEfficiency * emissionFactor
        result = "Your Carbon Footprint: \(footprint) kg CO2"
    }
}
