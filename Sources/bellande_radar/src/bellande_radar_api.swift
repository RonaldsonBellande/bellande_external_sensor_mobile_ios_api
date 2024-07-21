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

public class bellande_radar_api {
    private let baseURL: String
    private let session: URLSession
    private var streamTask: URLSessionStreamTask?
    
    public init(baseURL: String) {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
    
    public func sendRadarData(url: String, radarData: Data, connectivityPasscode: String, apiKey: String, completion: @escaping (Result<BellandeResponse, Error>) -> Void) {
        guard let url = URL(string: baseURL + url) else {
            completion(.failure(NSError(domain: "BellandeRadar", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Bellande-Framework-Access-Key")
        request.setValue(connectivityPasscode, forHTTPHeaderField: "Connectivity-Passcode")
        
        request.httpBody = radarData
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "BellandeRadar", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let bellandeResponse = try JSONDecoder().decode(BellandeResponse.self, from: data)
                completion(.success(bellandeResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public func startRadarStream(url: String, connectivityPasscode: String, apiKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: baseURL + url) else {
            completion(.failure(NSError(domain: "BellandeRadar", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        streamTask = session.streamTask(with: url)
        
        streamTask?.write(connectivityPasscode.data(using: .utf8)!) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            self.readStreamData(completion: completion)
        }
        
        streamTask?.resume()
    }
    
    private func readStreamData(completion: @escaping (Result<Data, Error>) -> Void) {
        streamTask?.readData(ofMinLength: 1, maxLength: 1024, timeout: 0) { data, isComplete, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            }
            
            if !isComplete {
                self.readStreamData(completion: completion)
            }
        }
    }
    
    public func stopRadarStream() {
        streamTask?.cancel()
        streamTask = nil
    }
}

public struct BellandeResponse: Codable {
    public let status: String
    public let message: String
}
