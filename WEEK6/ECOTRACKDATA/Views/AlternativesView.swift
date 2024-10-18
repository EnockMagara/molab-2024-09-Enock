import SwiftUI

struct AlternativesView: View {
    @StateObject private var viewModel = AlternativesViewModel()
    @State private var userInput: String = ""
    @State private var showSuggestions: Bool = false // State to control visibility

    var body: some View {
        VStack {
            Text("Sustainable Alternatives")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter product/service", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button(action: {
                    if !userInput.isEmpty {
                        viewModel.addSuggestion(userInput) // Add new suggestion
                        userInput = "" // Clear input field
                    }
                }) {
                    Text("Add")
                }
                .padding()
                
                Button(action: {
                    viewModel.loadSuggestionsFromJSON(fileName: "suggestions.json") // Reload suggestions
                    showSuggestions = true // Show suggestions
                }) {
                    Text("Get Suggestions")
                }
                .padding()
            }
            
            if showSuggestions { // Conditionally show the list
                List(viewModel.suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                }
            }
        }
        .padding()
    }
}
