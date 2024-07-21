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
import UIKit

public class bellande_camera_activity: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let cameraService: bellande_camera_service
    private let connectivityPasscode: String
    private var captureSession: AVCaptureSession!
    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var captureQueue: DispatchQueue!
    private static let REQUEST_VIDEO_CAPTURE = 1
    
    public init() {
        guard let config = Self.loadConfigFromFile() else {
            fatalError("Failed to load configuration")
        }
        
        guard let apiUrl = config["url"] as? String,
              let endpointPaths = config["endpoint_path"] as? [String: String],
              let streamEndpoint = endpointPaths["stream"],
              let apiAccessKey = config["Bellande_Framework_Access_Key"] as? String,
              let connectivityPasscode = config["connectivity_passcode"] as? String else {
            fatalError("Invalid configuration format")
        }
        
        self.connectivityPasscode = connectivityPasscode
        
        let cameraAPI = bellande_camera_api(baseURL: apiUrl)
        self.cameraService = bellande_camera_service(
            apiURL: apiUrl,
            streamEndpoint: streamEndpoint,
            apiAccessKey: apiAccessKey,
            cameraAPI: cameraAPI
        )
        
        super.init()
        
        setupCaptureSession()
    }
    
    private static func loadConfigFromFile() -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: "config/configs", withExtension: "json") else {
            print("Could not find config/configs.json")
            return nil
        }
    
        do {
            let data = try Data(contentsOf: url)
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("Error loading config: \(error)")
            return nil
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            print("Unable to access back camera")
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        captureQueue = DispatchQueue(label: "VideoDataOutputQueue")
        videoDataOutput.setSampleBufferDelegate(self, queue: captureQueue)
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
    }
    
    public func startVideoCapture() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    public func stopVideoCapture() {
        captureSession.stopRunning()
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let cameraData = CameraData(imageBuffer: pixelBuffer)
        sendCameraData(cameraData)
    }
    
    private func sendCameraData(_ data: CameraData) {
        cameraService.streamVideo(videoData: data, connectivityPasscode: connectivityPasscode) { result in
            switch result {
            case .success(let response):
                print("Video streamed successfully: \(response)")
            case .failure(let error):
                print("Failed to stream video: \(error)")
            }
        }
    }
    
    public func receiveVideoStream(completion: @escaping (Result<Data, Error>) -> Void) {
        cameraService.receiveVideoStream(connectivityPasscode: connectivityPasscode, completion: completion)
    }
}

struct CameraData: Codable {
    let imageBuffer: CVImageBuffer
    
    enum CodingKeys: String, CodingKey {
        case imageBuffer
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        if let jpegData = CIContext().jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB()) {
            try container.encode(jpegData.base64EncodedString(), forKey: .imageBuffer)
        } else {
            throw EncodingError.invalidValue(imageBuffer, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode image buffer"))
        }
    }
}
