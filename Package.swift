// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "DriveDialCore",
    products: [
        .library(name: "DriveDialCore", targets: ["DriveDialCore"])
    ],
    targets: [
        .target(name: "DriveDialCore"),
        .testTarget(name: "DriveDialCoreTests", dependencies: ["DriveDialCore"])
    ]
)
