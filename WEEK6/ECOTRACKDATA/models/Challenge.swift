import Foundation

struct Challenge: Codable { // Conform to Codable
    let title: String
    let description: String
    var isCompleted: Bool // Mutable to track completion
}
