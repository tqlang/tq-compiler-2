// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "tq-compiler",

    products: [
        .executable(name: "tqc", targets: ["tqc"]),
    ],

    dependencies: [
        .package(url: "https://github.com/LebJe/TOMLKit.git", from: "0.6.0"),
    ],

    targets: [
        .target(name: "TqcSystem"),
        .target(name: "TqcIR"),
        .target(name: "TqcDiagnostics", dependencies: ["TqcSystem"]),
        .target(name: "TqcBuild", dependencies: ["TqcSystem"]),
        .target(name: "TqcBuildToml", dependencies: [
            "TqcBuild",
            "TqcSystem",
            .product(name: "TOMLKit", package: "TOMLKit"),
        ]),
        .target(name: "TqcSyntax", dependencies: [
            "TqcDiagnostics",
            "TqcSystem"
        ]),
        .target(name: "TqcSemantics", dependencies: ["TqcSyntax"]),

        .executableTarget(name: "tqc", dependencies: [
            "TqcBuild",
            "TqcBuildToml",
            "TqcDiagnostics",
            "TqcSemantics",
            "TqcSyntax",
            "TqcSystem",
        ]),
    ]
)
