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
import ARKit

public class bellande_lidar_activity: NSObject, ARSessionDelegate {
    private let lidarService: bellande_lidar_service
    private let connectivityPasscode: String
    private var arSession: ARSession!
    
    public init() {
        guard let config = Self.loadConfigFromFile() else {
            fatalError("Failed to load configuration")
        }
        
        guard let apiUrl = config["url"] as? String,
              let endpointPaths = config["endpoint_path"] as? [String: String],
              let lidarEndpoint = endpointPaths["lidar"],
              let apiAccessKey = config["Bellande_Framework_Access_Key"] as? String,
              let connectivityPasscode = config["connectivity_passcode"] as? String else {
            fatalError("Invalid configuration format")
        }
        
        self.connectivityPasscode = connectivityPasscode
        
        let lidarAPI = bellande_lidar_api(baseURL: apiUrl)
        self.lidarService = bellande_lidar_service(
            apiURL: apiUrl,
            lidarEndpoint: lidarEndpoint,
            apiAccessKey: apiAccessKey,
            lidarAPI: lidarAPI
        )
        
        super.init()
        
        setupARSession()
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
    
    private func setupARSession() {
        arSession = ARSession()
        arSession.delegate = self
        
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else {
            print("Scene reconstruction is not supported on this device.")
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.environmentTexturing = .automatic
        
        arSession.run(configuration)
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let lidarDepth = frame.sceneDepth?.depthMap,
              let lidarConfidence = frame.sceneDepth?.confidenceMap else {
            return
        }
        
        let lidarData = LidarData(depthMap: lidarDepth, confidenceMap: lidarConfidence)
        sendLidarData(lidarData)
    }
    
    private func sendLidarData(_ data: LidarData) {
        lidarService.sendLidarData(data: data, connectivityPasscode: connectivityPasscode) { result in
            switch result {
            case .success(let response):
                print("LiDAR data sent successfully: \(response)")
            case .failure(let error):
                print("Failed to send LiDAR data: \(error)")
            }
        }
    }
}

struct LidarData: Codable {
    let depthMap: CVPixelBuffer
    let confidenceMap: CVPixelBuffer
    
    enum CodingKeys: String, CodingKey {
        case depthMap
        case confidenceMap
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(depthMap.base64EncodedString(), forKey: .depthMap)
        try container.encode(confidenceMap.base64EncodedString(), forKey: .confidenceMap)
    }
}

extension CVPixelBuffer {
    func base64EncodedString() throws -> String {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }
        
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let height = CVPixelBufferGetHeight(self)
        let totalBytes = bytesPerRow * height
        
        guard let baseAddress = baseAddress else {
            throw NSError(domain: "LiDAR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to get base address"])
        }
        
        let data = Data(bytes: baseAddress, count: totalBytes)
        return data.base64EncodedString()
    }
}
