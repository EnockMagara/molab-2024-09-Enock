import Foundation

class AlternativesViewModel: ObservableObject {
    @Published var suggestions: [String] = []
    
    // You can create a method to provide static suggestions or any other logic
    func provideStaticSuggestions() {
        // Example static suggestions
        self.suggestions = [
            "Bamboo Toothbrush",
            "Reusable Water Bottle",
            "Cloth Shopping Bags"
        ]
    }
}
