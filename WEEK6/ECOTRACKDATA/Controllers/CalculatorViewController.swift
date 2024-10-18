import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var distanceInput: UITextField!
    @IBOutlet weak var fuelEfficiencyInput: UITextField!
    @IBOutlet weak var emissionFactorInput: UITextField!
    @IBOutlet weak var resultLabel: UILabel!

    @IBAction func calculateFootprint(_ sender: UIButton) {
        let distance = Double(distanceInput.text ?? "0") ?? 0
        let fuelEfficiency = Double(fuelEfficiencyInput.text ?? "0") ?? 0
        let emissionFactor = Double(emissionFactorInput.text ?? "0") ?? 0
        let footprint = calculateCarbonFootprint(distance: distance, fuelEfficiency: fuelEfficiency, emissionFactor: emissionFactor)
        resultLabel.text = "Your Carbon Footprint: \(footprint) kg CO2"
    }

    func calculateCarbonFootprint(distance: Double, fuelEfficiency: Double, emissionFactor: Double) -> Double {
        return distance * fuelEfficiency * emissionFactor
    }
}
