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

public class bellande_radar_service {
    private let radarAPI: bellande_radar_api
    private let apiAccessKey: String
    private let radarEndpoint: String
    
    public init(apiURL: String, radarEndpoint: String, apiAccessKey: String, radarAPI: bellande_radar_api) {
        self.radarAPI = radarAPI
        self.apiAccessKey = apiAccessKey
        self.radarEndpoint = radarEndpoint
    }
    
    public func sendRadarData(data: RadarData, connectivityPasscode: String, completion: @escaping (Result<BellandeResponse, Error>) -> Void) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            radarAPI.sendRadarData(url: radarEndpoint, radarData: encodedData, connectivityPasscode: connectivityPasscode, apiKey: apiAccessKey) { result in
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
    
    public func startRadarStream(connectivityPasscode: String, completion: @escaping (Result<Data, Error>) -> Void) {
        radarAPI.startRadarStream(url: radarEndpoint + "/stream", connectivityPasscode: connectivityPasscode, apiKey: apiAccessKey) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func stopRadarStream() {
        radarAPI.stopRadarStream()
    }
}
