import SwiftUI

struct AlternativesView: View {
    @StateObject private var viewModel = AlternativesViewModel()
    @State private var userInput: String = ""

    var body: some View {
        VStack {
            Text("Sustainable Alternatives")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter product/service", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                viewModel.provideStaticSuggestions() // Call the new method
            }) {
                Text("Get Suggestions")
            }
            .padding()
            
            List(viewModel.suggestions, id: \.self) { suggestion in
                Text(suggestion)
            }
        }
        .padding()
    }
}
