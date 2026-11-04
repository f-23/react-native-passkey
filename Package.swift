// swift-tools-version: 6.0

import Foundation
import PackageDescription

let reactHeaders: [Target.Dependency] = [
    .product(name: "ReactHeaders", package: "ReactNative"),
    .product(name: "ReactNativeHeaders", package: "ReactNative"),
    .product(name: "ReactNativeDependenciesHeaders", package: "ReactNative"),
    .product(name: "ReactAppHeaders", package: "React-GeneratedCode"),
]

// Exclude unrelated package contents so SwiftPM does not discover them as resources.
let usedRootEntries: Set<String> = ["ios", "spm-support", "spm-headers", "Package.swift"]
let unusedRootEntries = try! FileManager.default.contentsOfDirectory(atPath: Context.packageDirectory)
    .filter { !usedRootEntries.contains($0) }
    .sorted()
let iosDirectory = URL(fileURLWithPath: Context.packageDirectory).appendingPathComponent("ios")
let iosEntries = try! FileManager.default.subpathsOfDirectory(atPath: iosDirectory.path)
    .filter { !$0.contains(".xcodeproj/") }
func unusedIosEntries(sourceExtensions: Set<String>) -> [String] {
    iosEntries.filter { entry in
        let url = iosDirectory.appendingPathComponent(entry)
        if url.pathExtension == "xcodeproj" { return true }
        let isFile = try! url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true
        return isFile && (!sourceExtensions.contains(url.pathExtension)
            || entry == "Passkey-Bridging-Header.h")
    }
    .map { "ios/" + $0 }
    .sorted()
}
let unusedSwiftIosEntries = unusedIosEntries(sourceExtensions: ["swift"])
let unusedObjCIosEntries = unusedIosEntries(sourceExtensions: ["h", "m", "mm"])

let package = Package(
    name: "react_native_passkey",
    platforms: [.iOS("15.1")],
    products: [
        .library(name: "react_native_passkey", targets: ["react_native_passkey", "PasskeyObjC"]),
    ],
    dependencies: [
        .package(name: "ReactNative", path: "../../../../xcframeworks"),
        .package(name: "React-GeneratedCode", path: "../../../ios"),
    ],
    targets: [
        .target(
            name: "react_native_passkey",
            dependencies: reactHeaders,
            path: ".",
            exclude: unusedRootEntries + ["spm-headers"] + unusedSwiftIosEntries,
            sources: ["ios", "spm-support"],
            linkerSettings: [.linkedFramework("AuthenticationServices")]
        ),
        .target(
            name: "PasskeyObjC",
            dependencies: [.target(name: "react_native_passkey")] + reactHeaders,
            path: ".",
            exclude: unusedRootEntries + ["spm-support"] + unusedObjCIosEntries,
            sources: ["ios"],
            // The registration target needs an empty public module, not the CocoaPods bridging header.
            publicHeadersPath: "spm-headers/public",
            cSettings: [.define("RCT_NEW_ARCH_ENABLED", to: "1")],
            cxxSettings: [
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                .define("DEBUG", .when(configuration: .debug)),
                .define("NDEBUG", .when(configuration: .release)),
            ]
        ),
    ],
    swiftLanguageModes: [.v5],
    cxxLanguageStandard: .cxx20
)
