import Foundation

class AlternativesViewModel: ObservableObject {
    @Published var suggestions: [String] = []
    private let allSuggestions = [
        "Bamboo Toothbrush",
        "Reusable Water Bottle",
        "Cloth Shopping Bags",
        "Solar Charger",
        "Eco-Friendly Detergent"
    ]
    
    init() {
        loadSuggestionsFromJSON(fileName: "suggestions.json")
    }
    
    // Add a new suggestion
    func addSuggestion(_ suggestion: String) {
        suggestions.append(suggestion)
        saveSuggestionsToJSON(fileName: "suggestions.json")
    }
    
    // Filter suggestions based on user input
    func filterSuggestions(for input: String) {
        if input.isEmpty {
            suggestions = allSuggestions
        } else {
            suggestions = allSuggestions.filter { $0.localizedCaseInsensitiveContains(input) }
        }
    }
    
    // Provide static suggestions
    func provideStaticSuggestions() {
        suggestions = allSuggestions
    }
    
    // Save suggestions to JSON
    func saveSuggestionsToJSON(fileName: String) {
        do {
            let filePath = try documentPath(fileName: fileName)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(suggestions)
            try jsonData.write(to: filePath)
            print("Suggestions saved successfully.")
        } catch {
            print("Failed to save suggestions: \(error)")
        }
    }
    
    // Load suggestions from JSON
    func loadSuggestionsFromJSON(fileName: String) {
        do {
            let filePath = try documentPath(fileName: fileName)
            if !FileManager.default.fileExists(atPath: filePath.path) {
                suggestions = allSuggestions
                saveSuggestionsToJSON(fileName: fileName)
                return
            }
            let jsonData = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            suggestions = try decoder.decode([String].self, from: jsonData)
            print("Suggestions loaded successfully.")
        } catch {
            print("Failed to load suggestions: \(error)")
            suggestions = allSuggestions // Fallback to default
        }
    }
    
    // Helper function to get the document directory path
    private func documentPath(fileName: String) throws -> URL {
        let directory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        return directory.appendingPathComponent(fileName)
    }
}
