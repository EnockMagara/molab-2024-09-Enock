import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var transportationInput: UITextField!
    @IBOutlet weak var energyInput: UITextField!
    @IBOutlet weak var resultLabel: UILabel!

    @IBAction func calculateFootprint(_ sender: UIButton) {
        let transportation = Double(transportationInput.text ?? "0") ?? 0
        let energy = Double(energyInput.text ?? "0") ?? 0
        let footprint = calculateCarbonFootprint(transportation: transportation, energy: energy)
        resultLabel.text = "Your Carbon Footprint: \(footprint) kg CO2"
    }

    func calculateCarbonFootprint(transportation: Double, energy: Double) -> Double {
        return (transportation * 2.5) + (energy * 1.5) // Example coefficients
    }
}
