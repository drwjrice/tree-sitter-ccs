// swift-tools-version:5.3

import Foundation
import PackageDescription

var sources = ["src/parser.c"]
if FileManager.default.fileExists(atPath: "src/scanner.c") {
    sources.append("src/scanner.c")
}

let package = Package(
    name: "TreeSitterCcs",
    products: [
        .library(name: "TreeSitterCcs", targets: ["TreeSitterCcs"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tree-sitter/swift-tree-sitter", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "TreeSitterCcs",
            dependencies: [],
            path: ".",
            sources: sources,
            resources: [
                .copy("queries")
            ],
            publicHeadersPath: "bindings/swift",
            cSettings: [.headerSearchPath("src")]
        ),
        .testTarget(
            name: "TreeSitterCcsTests",
            dependencies: [
                "SwiftTreeSitter",
                "TreeSitterCcs",
            ],
            path: "bindings/swift/TreeSitterCcsTests"
        )
    ],
    cLanguageStandard: .c11
)
