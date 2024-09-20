import Foundation

// Function to start the guessing game
func startGuessingGame() {
    let randomNumber = Int.random(in: 1...100)  // Random number between 1 and 100
    var isGuessedCorrectly = false
    let maxAttempts = 5  // Maximum number of attempts allowed

    print("Guess the number between 1 and 100. You have \(maxAttempts) attempts.")

    for attempt in 1...maxAttempts {
        print("Attempt \(attempt): Enter your guess:")
        
        // Simulating user input in Playground (replace this with actual user input in a real app)
        let userGuess = Int.random(in: 1...100)  // Random guess for demonstration
        print("You guessed: \(userGuess)")
        
        if userGuess == randomNumber {
            print("Congratulations! You guessed the right number: \(randomNumber)")
            isGuessedCorrectly = true
            break
        } else if userGuess < randomNumber {
            print("Your guess is too low.")
        } else {
            print("Your guess is too high.")
        }
    }
    
    if !isGuessedCorrectly {
        print("Sorry, you've used all your attempts. The correct number was \(randomNumber).")
    }
}

// Start the game
startGuessingGame()
