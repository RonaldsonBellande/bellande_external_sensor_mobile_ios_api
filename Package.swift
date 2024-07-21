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

import PackageDescription

let package = Package(
    name: "bellande_external_sensors_mobile_ios_api",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "bellande_camera",
            targets: ["bellande_camera"]),
        .library(
            name: "bellande_gps",
            targets: ["bellande_gps"]),
        .library(
            name: "bellande_lidar",
            targets: ["bellande_lidar"]),
        .library(
            name: "bellande_radar",
            targets: ["bellande_radar"]),

    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "bellande_camera",
            dependencies: [],
            path: "Source/bellande_camera",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_camera_tests",
            dependencies: ["bellande_camera"]),
       

        .target(
            name: "bellande_gps",
            dependencies: [],
            path: "Source/bellande_gps",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_gps_tests",
            dependencies: ["bellande_gps"]),


        .target(
            name: "bellande_lidar",
            dependencies: [],
            path: "Source/bellande_lidar",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_lidar_tests",
            dependencies: ["bellande_lidar"]),


        .target(
            name: "bellande_radar",
            dependencies: [],
            path: "Source/bellande_radar",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_radar_tests",
            dependencies: ["bellande_radar"]),

    ]
)
