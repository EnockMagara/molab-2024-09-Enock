import SwiftUI

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @State private var newTitle: String = ""
    @State private var newDescription: String = ""

    var body: some View {
        VStack {
            Text("Community Challenges")
                .font(.largeTitle)
                .padding()
            
            Form {
                Section(header: Text("Add New Challenge")) {
                    TextField("Title", text: $newTitle)
                    TextField("Description", text: $newDescription)
                    Button("Add Challenge") {
                        viewModel.addChallenge(title: newTitle, description: newDescription)
                        newTitle = ""
                        newDescription = ""
                    }
                }
                
                Section(header: Text("Active Challenges")) {
                    List {
                        ForEach(viewModel.challenges, id: \.title) { challenge in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(challenge.title)
                                        .font(.headline)
                                    Text(challenge.description)
                                        .font(.subheadline)
                                }
                                Spacer()
                                Button("Complete") {
                                    viewModel.completeChallenge(challenge)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Completed Challenges")) {
                    List(viewModel.completedChallenges, id: \.title) { challenge in
                        VStack(alignment: .leading) {
                            Text(challenge.title)
                                .font(.headline)
                            Text(challenge.description)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.loadChallenges()
        }
    }
}

class ChallengesViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []
    @Published var completedChallenges: [Challenge] = []

    func loadChallenges() {
        let controller = ChallengesViewController()
        controller.loadChallengesFromJSON(fileName: "challenges.json")
        challenges = controller.challenges
    }
    
    func addChallenge(title: String, description: String) {
        let newChallenge = Challenge(title: title, description: description, isCompleted: false)
        challenges.append(newChallenge)
        saveChallenges()
    }
    
    func completeChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.title == challenge.title }) {
            challenges.remove(at: index)
            completedChallenges.append(challenge)
            saveChallenges()
        }
    }
    
    private func saveChallenges() {
        let controller = ChallengesViewController()
        controller.challenges = challenges
        controller.saveChallengesToJSON(fileName: "challenges.json")
    }
}
