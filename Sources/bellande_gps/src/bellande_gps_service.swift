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

public class bellande_gps_service {
    private let gpsAPI: bellande_gps_api
    private let apiAccessKey: String
    private let gpsEndpoint: String
    
    public init(apiURL: String, gpsEndpoint: String, apiAccessKey: String, gpsAPI: bellande_gps_api) {
        self.gpsAPI = gpsAPI
        self.apiAccessKey = apiAccessKey
        self.gpsEndpoint = gpsEndpoint
    }
    
    public func sendGPSData(data: GPSData, connectivityPasscode: String, completion: @escaping (Result<BellandeResponse, Error>) -> Void) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            gpsAPI.sendGPSData(url: gpsEndpoint, gpsData: encodedData, connectivityPasscode: connectivityPasscode, apiKey: apiAccessKey) { result in
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
}
