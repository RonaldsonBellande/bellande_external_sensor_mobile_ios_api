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

public class bellande_radar_activity {
    private let radarService: bellande_radar_service
    private let connectivityPasscode: String
    
    public init() {
        guard let config = Self.loadConfigFromFile() else {
            fatalError("Failed to load configuration")
        }
        
        guard let apiUrl = config["url"] as? String,
              let endpointPaths = config["endpoint_path"] as? [String: String],
              let radarEndpoint = endpointPaths["radar"],
              let apiAccessKey = config["Bellande_Framework_Access_Key"] as? String,
              let connectivityPasscode = config["connectivity_passcode"] as? String else {
            fatalError("Invalid configuration format")
        }
        
        self.connectivityPasscode = connectivityPasscode
        
        let radarAPI = bellande_radar_api(baseURL: apiUrl)
        self.radarService = bellande_radar_service(
            apiURL: apiUrl,
            radarEndpoint: radarEndpoint,
            apiAccessKey: apiAccessKey,
            radarAPI: radarAPI
        )
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
    
    public func startRadarStreaming(completion: @escaping (Result<Data, Error>) -> Void) {
        radarService.startRadarStream(connectivityPasscode: connectivityPasscode, completion: completion)
    }
    
    public func stopRadarStreaming() {
        radarService.stopRadarStream()
    }
    
    public func sendRadarData(_ data: RadarData, completion: @escaping (Result<BellandeResponse, Error>) -> Void) {
        radarService.sendRadarData(data: data, connectivityPasscode: connectivityPasscode, completion: completion)
    }
}

public struct RadarData: Codable {
    public let timestamp: Date
    public let objects: [RadarObject]
    
    public struct RadarObject: Codable {
        public let id: String
        public let distance: Double
        public let angle: Double
        public let velocity: Double
    }
}
