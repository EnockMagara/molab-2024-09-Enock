import SwiftUI
import PlaygroundSupport

// Define the data model for a to-do item
struct TodoItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
}

// ViewModel to manage the to-do list
class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = []  // This array will store all to-do items.

    func addItem(title: String) {
        let newItem = TodoItem(title: title)
        items.append(newItem)
    }

    func deleteItem(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }

    func toggleIsCompleted(item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }
}

// Main ContentView that displays the to-do list
struct ContentView: View {
    @StateObject var viewModel = TodoViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items) { item in
                    HStack {
                        Text(item.title)
                            .strikethrough(item.isCompleted, color: .gray)
                        Spacer()
                        Button(action: {
                            viewModel.toggleIsCompleted(item: item)
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.square" : "square")
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteItem)
            }
            .navigationTitle("To-Do List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Item") {
                        viewModel.addItem(title: "New Item")
                    }
                }
            }
        }
    }
}

// Set up the live preview
PlaygroundPage.current.setLiveView(ContentView())
