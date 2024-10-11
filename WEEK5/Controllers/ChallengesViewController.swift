import UIKit

class ChallengesViewController: UIViewController {
    var challenges: [Challenge] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChallenges()
    }

    func loadChallenges() {
        challenges = [
            Challenge(title: "Plastic Free July", description: "Avoid single-use plastics.", isCompleted: false),
            Challenge(title: "Plant a Tree", description: "Plant a tree in your community.", isCompleted: false)
        ]
    }
}
