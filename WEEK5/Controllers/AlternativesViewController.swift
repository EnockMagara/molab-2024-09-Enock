import UIKit

class AlternativesViewController: UIViewController {
    var userInput: String = "" // User's input for product/service

    func fetchAlternatives(for input: String) -> [SustainableProduct] {
        let alternatives = [
            SustainableProduct(name: "Bamboo Toothbrush", category: "Personal Care"),
            SustainableProduct(name: "Reusable Water Bottle", category: "Beverage")
        ]
        return alternatives.filter { $0.category.contains(input) } // Simple filtering
    }
}
