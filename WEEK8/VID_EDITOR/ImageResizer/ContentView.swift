//
//  ContentView.swift
//  ImageResizer
//
//  Created by Enock Mecheo on 24/10/2024.
//





import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI
import AVFoundation

extension CIImage {
    func oriented(for orientation: UIImage.Orientation) -> CIImage {
        switch orientation {
        case .up:
            return self
        case .down:
            return self.transformed(by: CGAffineTransform(rotationAngle: .pi))
        case .left:
            return self.transformed(by: CGAffineTransform(rotationAngle: .pi / 2))
        case .right:
            return self.transformed(by: CGAffineTransform(rotationAngle: -.pi / 2))
        case .upMirrored:
            return self.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        case .downMirrored:
            return self.transformed(by: CGAffineTransform(scaleX: -1, y: -1))
        case .leftMirrored:
            return self.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        case .rightMirrored:
            return self.transformed(by: CGAffineTransform(scaleX: 1, y: 1))
        @unknown default:
            return self
        }
    }
}

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var filterBrightness = 0.5
    @State private var targetWidth: CGFloat = 300
    @State private var targetHeight: CGFloat = 300

    let context = CIContext()
    @State private var currentImage: CIImage?
    @State private var uiImage: UIImage?

    @State private var selectedVideoItem: PhotosPickerItem?
    @State private var processedVideoURL: URL?

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem) { _ in
                    loadImage()
                }

                Spacer()

                HStack {
                    Text("Brightness")
                    Slider(value: $filterBrightness, in: 0...1)
                        .onChange(of: filterBrightness) { _ in
                            updateImageProcessing()
                        }
                }

                HStack {
                    Text("Width")
                    Slider(value: $targetWidth, in: 100...1000, step: 10)
                        .onChange(of: targetWidth) { _ in
                            updateImageProcessing()
                        }
                }

                HStack {
                    Text("Height")
                    Slider(value: $targetHeight, in: 100...1000, step: 10)
                        .onChange(of: targetHeight) { _ in
                            updateImageProcessing()
                        }
                }

                Spacer()

                // Video Picker
                PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
                    Text("Select a Video")
                }
                .onChange(of: selectedVideoItem) { _ in
                    loadVideo()
                }

                // Share processed video
                if let videoURL = processedVideoURL {
                    ShareLink(item: videoURL) {
                        Label("Share Video", systemImage: "square.and.arrow.up")
                    }
                    .padding()
                }

                Spacer()
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("PhotoResizer")
        }
    }

    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }

            currentImage = CIImage(image: inputImage)?.oriented(for: inputImage.imageOrientation)
            updateImageProcessing()
        }
    }

    func updateImageProcessing() {
        guard let inputImage = currentImage else { return }

        let brightnessFilter = CIFilter.colorControls()
        brightnessFilter.inputImage = inputImage
        brightnessFilter.brightness = Float(filterBrightness)

        guard let outputImage = brightnessFilter.outputImage else { return }

        let scaleX = targetWidth / outputImage.extent.width
        let scaleY = targetHeight / outputImage.extent.height

        let resizedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(resizedImage, from: resizedImage.extent) else { return }

        uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage!)
    }

    func loadVideo() {
        Task {
            guard let videoData = try await selectedVideoItem?.loadTransferable(type: Data.self) else { return }
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.mov")
            try videoData.write(to: tempURL)
            
            applyBrightnessFilterToVideo(at: tempURL)
        }
    }

    func applyBrightnessFilterToVideo(at url: URL) {
        let asset = AVAsset(url: url)
        let composition = AVVideoComposition(asset: asset) { request in
            let inputImage = request.sourceImage.clampedToExtent()
            
            // Apply brightness filter
            let brightnessFilter = CIFilter.colorControls()
            brightnessFilter.inputImage = inputImage
            brightnessFilter.brightness = Float(filterBrightness)
            
            if let outputImage = brightnessFilter.outputImage {
                request.finish(with: outputImage, context: nil)
            } else {
                request.finish(with: NSError(domain: "com.example.ImageResizer", code: -1, userInfo: nil))
            }
        }
        
        // Export the video with the applied filter
        let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent("processed.mov")
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputURL = exportURL
        exporter.outputFileType = .mov
        exporter.videoComposition = composition
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                if exporter.status == .completed {
                    self.processedVideoURL = exportURL
                } else {
                    print("Video export failed: \(String(describing: exporter.error))")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}



