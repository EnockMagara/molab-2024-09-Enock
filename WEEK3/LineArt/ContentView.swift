import SwiftUI

struct ContentView: View {
    // Define the number of shapes and their properties
    let numberOfLines = 100 // Total lines to draw
    let numberOfCircles = 50 // Total circles to draw
    let numberOfRectangles = 30 // Total rectangles to draw
    let lineLength: CGFloat = 300 // Length of each line
    let colors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple] // Array of colors

    @State private var shapes: [ShapeData] = [] // State variable to hold shapes

    var body: some View {
        // Create a ZStack to overlay shapes
        ZStack {
            // Draw shapes
            ForEach(shapes) { shape in
                shape.view // Render the shape
            }
        }
        .background(Color.white) // Set background color to white
        .edgesIgnoringSafeArea(.all) // Ignore safe area for full-screen effect
        .onTapGesture {
            // Clear shapes and regenerate on tap
            shapes.removeAll() // Clear the shapes array
            print("Cleared shapes on tap.") // Debug statement
            generateShapes() // Generate new shapes
        }
        .onAppear {
            // Generate initial shapes when the view appears
            generateShapes()
        }
    }

    // Function to generate random shapes
    private func generateShapes() {
        shapes = [] // Clear existing shapes
        for _ in 0..<numberOfLines {
            let startX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let startY = CGFloat.random(in: 0...UIScreen.main.bounds.height)
            let endX = startX + CGFloat.random(in: -lineLength...lineLength)
            let endY = startY + CGFloat.random(in: -lineLength...lineLength)
            let color = colors.randomElement() ?? .black // Random color

            // Create a line shape and add it to the shapes array
            shapes.append(ShapeData(view: Line(start: CGPoint(x: startX, y: startY), end: CGPoint(x: endX, y: endY)).stroke(color, lineWidth: 2)))
        }

        for _ in 0..<numberOfCircles {
            let centerX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let centerY = CGFloat.random(in: 0...UIScreen.main.bounds.height)
            let radius = CGFloat.random(in: 10...50) // Random radius
            let color = colors.randomElement() ?? .black // Random color

            // Create a circle shape and add it to the shapes array
            shapes.append(ShapeData(view: Circle().fill(color).frame(width: radius * 2, height: radius * 2).position(x: centerX, y: centerY)))
        }

        for _ in 0..<numberOfRectangles {
            let width = CGFloat.random(in: 20...100) // Random width
            let height = CGFloat.random(in: 20...100) // Random height
            let x = CGFloat.random(in: 0...(UIScreen.main.bounds.width - width))
            let y = CGFloat.random(in: 0...(UIScreen.main.bounds.height - height))
            let color = colors.randomElement() ?? .black // Random color

            // Create a rectangle shape and add it to the shapes array
            shapes.append(ShapeData(view: Rectangle().fill(color).frame(width: width, height: height).position(x: x + width / 2, y: y + height / 2)))
        }
    }
}

// Custom Line shape
struct Line: Shape {
    var start: CGPoint
    var end: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path() // Create a new path
        path.move(to: start) // Move to the start point
        path.addLine(to: end) // Draw line to the end point
        return path // Return the path
    }
}

// Struct to hold shape data
struct ShapeData: Identifiable {
    let id = UUID() // Unique identifier
    let view: AnyView // Shape view

    init<V: View>(view: V) {
        self.view = AnyView(view) // Store the shape view
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Preview the ContentView
    }
}
