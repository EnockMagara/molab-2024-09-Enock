import Foundation

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
    init(name: String, type: AnimalType, properties: AnimalProperties, asciiArt: String) {
        self.name = name
        self.type = type
        self.properties = properties
        self.asciiArt = asciiArt
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
let dogArt = """
  / \\__
 (    @\\___
 /         O
/   (_____/
/_____/   U
"""
let myDog = AnimalClass(name: "Buddy", type: .dog, properties: dogProperties, asciiArt: dogArt)

let catProperties = AnimalProperties(age: 1, weight: 5.0)
let catArt = """
  /\\_/\\  
 ( o.o ) 
 > ^ <  
"""
let myCat = AnimalClass(name: "Whiskers", type: .cat, properties: catProperties, asciiArt: catArt)

let birdProperties = AnimalProperties(age: 3, weight: 0.5)
let birdArt = """
  \\
 (o>
 //\\
 V_/_ 
"""
let myBird = AnimalClass(name: "Tweety", type: .bird, properties: birdProperties, asciiArt: birdArt)

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
