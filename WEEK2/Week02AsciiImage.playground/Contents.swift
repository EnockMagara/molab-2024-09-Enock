import Foundation

// Function to load an ASCII art file
func load(_ file: String) -> String {
    guard let path = Bundle.main.path(forResource: file, ofType: nil) else {
        return "File not found!"
    }
    return (try? String(contentsOfFile: path, encoding: .utf8)) ?? "Error loading file!"
}

// AnimalType enum to represent different types of animals
enum AnimalType: String {
    case dog = "Dog"
    case cat = "Cat"
    case bird = "Bird"
}

// Protocol defining common behaviors for animals
protocol Animal {
    var name: String { get }
    var type: AnimalType { get }
    var properties: AnimalProperties { get }
    var asciiArt: String { get }
    func makeSound() -> String
    func description() -> String
}

// Struct to hold properties of an animal
struct AnimalProperties {
    var age: Int
    var weight: Double
}

// Class representing an Animal with behaviors
class AnimalClass: Animal {
    var name: String
    var type: AnimalType
    var properties: AnimalProperties
    var asciiArt: String
    
    // Initializer for the class
    init(name: String, type: AnimalType, properties: AnimalProperties, asciiArtFile: String) {
        self.name = name
        self.type = type
        self.properties = properties
        self.asciiArt = load(asciiArtFile) // Load ASCII art from file
    }
    
    // Method to make sound based on animal type
    func makeSound() -> String {
        switch type {
        case .dog:
            return "Woof!"
        case .cat:
            return "Meow!"
        case .bird:
            return "Chirp!"
        }
    }
    
    // Method to provide a description of the animal
    func description() -> String {
        return "\(name) is a \(type.rawValue) aged \(properties.age) years and weighs \(properties.weight) kg."
    }
}

// Extension to add additional functionality to AnimalClass
extension AnimalClass {
    func isAdult() -> Bool {
        return properties.age >= 2 // Assuming 2 years is the adult age for simplicity
    }
}

// Generic function to filter animals by type
func filterAnimals<T: Animal>(animals: [T], byType type: AnimalType) -> [T] {
    return animals.filter { $0.type == type }
}

// Example usage
let dogProperties = AnimalProperties(age: 5, weight: 20.0)
let myDog = AnimalClass(name: "Buddy", type: .dog, properties: dogProperties, asciiArtFile: "dog.txt")

let catProperties = AnimalProperties(age: 1, weight: 5.0)
let myCat = AnimalClass(name: "Whiskers", type: .cat, properties: catProperties, asciiArtFile: "cat.txt")

let birdProperties = AnimalProperties(age: 3, weight: 0.5)
let myBird = AnimalClass(name: "Tweety", type: .bird, properties: birdProperties, asciiArtFile: "bird.txt")

// Create an array of animals
let animals: [AnimalClass] = [myDog, myCat, myBird]

// Display information about each animal
for animal in animals {
    print(animal.description())
    print("Sound: \(animal.makeSound())")
    print("ASCII Art:\n\(animal.asciiArt)")
    print("Is Adult: \(animal.isAdult())\n")
}

// Filter animals by type
let dogs = filterAnimals(animals: animals, byType: .dog)
print("Filtered Dogs:")
for dog in dogs {
    print(dog.description())
    print("ASCII Art:\n\(dog.asciiArt)")
}
