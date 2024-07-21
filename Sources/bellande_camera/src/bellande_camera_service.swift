/**
 * Copyright (C) 2024 Bellande Application UI UX Research Innovation Center, Ronaldson Bellande
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 **/

import Foundation
import AVFoundation
import Vision

public class bellande_camera_service {
    private let cameraAPI: bellande_camera_api
    private let apiAccessKey: String
    private let cameraEndpoint: String
    
    public init(apiURL: String, cameraEndpoint: String, apiAccessKey: String, cameraAPI: bellande_camera_api) {
        self.cameraAPI = cameraAPI
        self.apiAccessKey = apiAccessKey
        self.cameraEndpoint = cameraEndpoint
    }
    
    public func sendCameraData(data: CameraData, connectivityPasscode: String, completion: @escaping (Result<BellandeResponse, Error>) -> Void) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            cameraAPI.sendCameraData(url: cameraEndpoint, cameraData: encodedData, connectivityPasscode: connectivityPasscode, apiKey: apiAccessKey) { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    public func getCameraAnalysis(connectivityPasscode: String, completion: @escaping (Result<CameraAnalysis, Error>) -> Void) {
        cameraAPI.getCameraAnalysis(url: cameraEndpoint + "/analysis", connectivityPasscode: connectivityPasscode, apiKey: apiAccessKey) { result in
            switch result {
            case .success(let analysis):
                completion(.success(analysis))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func processCameraData(_ imageBuffer: CVImageBuffer) -> CameraProcessedData {
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        
        let averageBrightness = calculateAverageBrightness(ciImage)
        let dominantColor = calculateDominantColor(ciImage)
        let detectedObjects = detectObjects(ciImage)
        
        return CameraProcessedData(averageBrightness: averageBrightness, dominantColor: dominantColor, detectedObjects: detectedObjects)
    }
    
    private func calculateAverageBrightness(_ image: CIImage) -> Float {
        let extentVector = CIVector(x: image.extent.origin.x, y: image.extent.origin.y, z: image.extent.size.width, w: image.extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: image, kCIInputExtentKey: extentVector]) else {
            return 0
        }
        guard let outputImage = filter.outputImage else {
            return 0
        }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let brightness = (Float(bitmap[0]) + Float(bitmap[1]) + Float(bitmap[2])) / (3.0 * 255.0)
        return brightness
    }
    
    private func calculateDominantColor(_ image: CIImage) -> UIColor {
        let extentVector = CIVector(x: image.extent.origin.x, y: image.extent.origin.y, z: image.extent.size.width, w: image.extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: image, kCIInputExtentKey: extentVector]) else {
            return .black
        }
        guard let outputImage = filter.outputImage else {
            return .black
        }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
    }
    
    private func detectObjects(_ image: CIImage) -> [String] {
        var detectedObjects: [String] = []
        
        let request = VNDetectObjectRectanglesRequest { request, error in
            guard let results = request.results as? [VNDetectedObjectObservation] else { return }
            
            for objectObservation in results {
                if let label = objectObservation.labels.first?.identifier {
                    detectedObjects.append(label)
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image, orientation: .up)
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform object detection: \(error)")
        }
        
        return detectedObjects
    }
}

public struct CameraProcessedData {
    let averageBrightness: Float
    let dominantColor: UIColor
    let detectedObjects: [String]
}
