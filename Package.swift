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
    name: "bellande_internal_sensors_mobile_ios_api",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "bellande_cpu_temperature",
            targets: ["bellande_cpu_temperature"]),
        .library(
            name: "bellande_cpu_usage",
            targets: ["bellande_cpu_usage"]),
        .library(
            name: "bellande_internal_temperature",
            targets: ["bellande_internal_temperature"]),
        .library(
            name: "bellande_battery_usage",
            targets: ["bellande_battery_usage"]),
        .library(
            name: "bellande_battery_temperature",
            targets: ["bellande_battery_temperature"]),
        .library(
            name: "bellande_network_usage",
            targets: ["bellande_network_usage"]),
        .library(
            name: "bellande_ram_usage",
            targets: ["bellande_ram_usage"]),
        .library(
            name: "bellande_storage_usage",
            targets: ["bellande_storage_usage"]),
        .library(
            name: "bellande_cpu_temperature",
            targets: ["bellande_cpu_temperature"]),
        .library(
            name: "bellande_gpu_usage",
            targets: ["bellande_gpu_usage"]),



        .library(
            name: "bellande_device_motion",
            targets: ["bellande_device_motion"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "bellande_cpu_temperature",
            dependencies: [],
            path: "Source/bellande_cpu_temperature",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_cpu_temperature_tests",
            dependencies: ["bellande_cpu_temperature"]),
       

        .target(
            name: "bellande_cpu_usage",
            dependencies: [],
            path: "Source/bellande_cpu_usage",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_cpu_usage_tests",
            dependencies: ["bellande_cpu_usage"]),


        .target(
            name: "bellande_internal_temperature",
            dependencies: [],
            path: "Source/bellande_internal_temperature",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_internal_temperature_tests",
            dependencies: ["bellande_internal_temperature"]),


        .target(
            name: "bellande_battery_usage",
            dependencies: [],
            path: "Source/bellande_battery_usage",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_battery_usage_tests",
            dependencies: ["bellande_battery_usage"]),
       

        .target(
            name: "bellande_battery_temperature",
            dependencies: [],
            path: "Source/bellande_battery_temperature",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_battery_temperature_tests",
            dependencies: ["bellande_battery_temperature"]),


        .target(
            name: "bellande_network_usage",
            dependencies: [],
            path: "Source/bellande_network_usage",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_network_usage_tests",
            dependencies: ["bellande_network_usage"]),


        .target(
            name: "bellande_ram_usage",
            dependencies: [],
            path: "Source/bellande_ram_usage",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_ram_usage_tests",
            dependencies: ["bellande_ram_usage"]),


        .target(
            name: "bellande_storage_usage",
            dependencies: [],
            path: "Source/bellande_storage_usage",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_storage_usage_tests",
            dependencies: ["bellande_storage_usage"]),


        .target(
            name: "bellande_gpu_temperature",
            dependencies: [],
            path: "Source/bellande_gpu_temperature",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_gpu_temperature_tests",
            dependencies: ["bellande_gpu_temperature"]),
       

        .target(
            name: "bellande_gpu_usage",
            dependencies: [],
            path: "Source/bellande_gpu_usage",
            exclude: ["config"],
            sources: ["src"],
            resources: [
                .copy("configs.json")
            ]
        ),
        .testTarget(
            name: "bellande_gpu_usage_tests",
            dependencies: ["bellande_gpu_usage"]),


        .target(
            name: "bellande_device_motion",
            dependencies: []),
        .testTarget(
            name: "bellande_device_motion_tests",
            dependencies: ["bellande_device_motion"]),
    ]
)
