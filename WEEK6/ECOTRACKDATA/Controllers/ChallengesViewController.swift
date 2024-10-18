import UIKit

class ChallengesViewController: UIViewController {
    var challenges: [Challenge] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChallengesFromJSON(fileName: "challenges.json")
    }

    func loadChallengesFromJSON(fileName: String) {
        do {
            let filePath = try documentPath(fileName: fileName)
            if !FileManager.default.fileExists(atPath: filePath.path) {
                challenges = defaultChallenges()
                saveChallengesToJSON(fileName: fileName)
                return
            }
            let jsonData = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            challenges = try decoder.decode([Challenge].self, from: jsonData)
            print("Challenges loaded successfully.")
        } catch {
            print("Failed to load challenges: \(error)")
            challenges = defaultChallenges() // Fallback to default
        }
    }

    func saveChallengesToJSON(fileName: String) {
        do {
            let filePath = try documentPath(fileName: fileName)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(challenges)
            try jsonData.write(to: filePath)
            print("Challenges saved successfully.")
        } catch {
            print("Failed to save challenges: \(error)")
        }
    }

    func defaultChallenges() -> [Challenge] {
        return [
            Challenge(title: "Plastic Free July", description: "Avoid single-use plastics.", isCompleted: false),
            Challenge(title: "Plant a Tree", description: "Plant a tree in your community.", isCompleted: false)
        ]
    }

    private func documentPath(fileName: String) throws -> URL {
        let directory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        return directory.appendingPathComponent(fileName)
    }
}
