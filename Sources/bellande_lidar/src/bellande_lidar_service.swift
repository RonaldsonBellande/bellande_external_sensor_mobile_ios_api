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

public class bellande_lidar_service {
    private let lidarAPI: bellande_lidar_api
    private let apiAccessKey: String
    private let lidarEndpoint: String
    
    public init(apiURL: String, lidarEndpoint: String, apiAccessKey: String, lidarAPI: bellande_lidar_api) {
        self.lidarAPI = lidarAPI
        self.apiAccessKey = apiAccessKey
        self.lidarEndpoint = lidarEndpoint
    }
    
    public func sendLidarData(data: LidarData, connectivityPasscode: String, completion: @escaping (Result<BellandeResponse, Error>) -> Void) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            lidarAPI.sendLidarData(url: lidarEndpoint, lidarData: encodedData, connectivityPasscode: connectivityPasscode, apiKey: apiAccessKey) { result in
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
    
    public func getLidarAnalysis(connectivityPasscode: String, completion: @escaping (Result<LidarAnalysis, Error>) -> Void) {
        lidarAPI.getLidarAnalysis(url: lidarEndpoint + "/analysis", connectivityPasscode: connectivityPasscode, apiKey: apiAccessKey) { result in
            switch result {
            case .success(let analysis):
                completion(.success(analysis))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func processLidarData(_ depthMap: CVPixelBuffer, _ confidenceMap: CVPixelBuffer) -> LidarProcessedData {
        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        
        var totalDepth: Float = 0
        var pointCount: Int = 0
        
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
        
        let baseAddress = CVPixelBufferGetBaseAddress(depthMap)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        
        for y in 0..<height {
            let rowData = baseAddress!.advanced(by: y * bytesPerRow).assumingMemoryBound(to: Float32.self)
            for x in 0..<width {
                let depth = rowData[x]
                if depth > 0 && depth < Float.greatestFiniteMagnitude {
                    totalDepth += depth
                    pointCount += 1
                }
            }
        }
        
        let averageDepth = pointCount > 0 ? totalDepth / Float(pointCount) : 0
        
        return LidarProcessedData(averageDepth: averageDepth, pointCount: pointCount)
    }
}

public struct LidarProcessedData {
    let averageDepth: Float
    let pointCount: Int
}
