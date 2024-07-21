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
import CoreLocation

public class bellande_gps_activity: NSObject, CLLocationManagerDelegate {
    private let gpsService: bellande_gps_service
    private let connectivityPasscode: String
    private var locationManager: CLLocationManager!
    
    public override init() {
        guard let config = Self.loadConfigFromFile() else {
            fatalError("Failed to load configuration")
        }
        
        guard let apiUrl = config["url"] as? String,
              let endpointPaths = config["endpoint_path"] as? [String: String],
              let gpsEndpoint = endpointPaths["gps"],
              let apiAccessKey = config["Bellande_Framework_Access_Key"] as? String,
              let connectivityPasscode = config["connectivity_passcode"] as? String else {
            fatalError("Invalid configuration format")
        }
        
        self.connectivityPasscode = connectivityPasscode
        
        let gpsAPI = bellande_gps_api(baseURL: apiUrl)
        self.gpsService = bellande_gps_service(
            apiURL: apiUrl,
            gpsEndpoint: gpsEndpoint,
            apiAccessKey: apiAccessKey,
            gpsAPI: gpsAPI
        )
        
        super.init()
        
        setupLocationManager()
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
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func startGPSTracking() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopGPSTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let gpsData = GPSData(latitude: location.coordinate.latitude,
                              longitude: location.coordinate.longitude,
                              altitude: location.altitude,
                              speed: location.speed,
                              course: location.course,
                              timestamp: location.timestamp)
        
        sendGPSData(gpsData)
    }
    
    private func sendGPSData(_ data: GPSData) {
        gpsService.sendGPSData(data: data, connectivityPasscode: connectivityPasscode) { result in
            switch result {
            case .success(let response):
                print("GPS data sent successfully: \(response)")
            case .failure(let error):
                print("Failed to send GPS data: \(error)")
            }
        }
    }
}

struct GPSData: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let speed: Double
    let course: Double
    let timestamp: Date
}
