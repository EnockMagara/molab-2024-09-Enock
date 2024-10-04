import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var timerDuration: String = ""
    @State private var remainingTime: Int = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var timer: Timer?
    @State private var isTimerRunning: Bool = false
    @State private var showAlert: Bool = false

    var body: some View {
        VStack {
            Text("Procrastination Police")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Set Timer (seconds)")
                .font(.title)
                .padding()

            TextField("Enter seconds", text: $timerDuration)
                .keyboardType(.numberPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("Remaining Time: \(remainingTime) seconds")
                .font(.title)
                .padding()

            Button(action: startTimer) {
                Text(isTimerRunning ? "Running..." : "Start Timer")
                    .font(.title2)
                    .padding()
                    .background(Color(red: 0.8, green: 0.52, blue: 0.25)) // Golden brown color
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5) // Optional shadow for better appearance
            }
            .disabled(isTimerRunning)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("You've been caught!"),
                  message: Text("Get back to work!"),
                  dismissButton: .default(Text("OK")){
                    audioPlayer?.stop()
            })
        }
    }

    // Function to start the timer
    private func startTimer() {
        guard let duration = Int(timerDuration), duration > 0 else { return }
        remainingTime = duration
        isTimerRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.isTimerRunning = false
                playSound()
                showAlert = true
            }
        }
    }

    // Function to play sound
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "POLICE_SIREN", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
