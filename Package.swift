// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IDentityMediumSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "IDentityMediumSDK", targets: ["IDentityMediumSDKTarget"]),
        .library(name: "IDentityMediumModels", targets: ["IDentityMediumModelsTarget"]),
        .library(name: "SignatureCaptureMediumSDK", targets: ["SignatureCaptureMediumSDKTarget"]),
        .library(name: "VoiceCaptureMediumSDK", targets: ["VoiceCaptureMediumSDKTarget"]),
        .library(name: "FingerPrintCaptureMediumSDK", targets: ["FingerPrintCaptureMediumSDKTarget"])
    ],
    targets: [
        // These targets link the binary frameworks and the external dependencies together.
        .target(
            name: "IDentityMediumSDKTarget",
            dependencies: [
                "IDentityMediumSDK",
                "IDCaptureMedium",
                "SelfieCaptureMedium"
            ],
            path: "Sources/IDentityMedium"
        ),
        .target(
            name: "IDentityMediumModelsTarget",
            dependencies: ["IDentityMediumModels"],
            path: "Sources/IDentityMediumModels"
        ),
        .target(
            name: "SignatureCaptureMediumSDKTarget",
            dependencies: ["SignatureCaptureMedium"],
            path: "Sources/SignatureCaptureMedium"
        ),
        .target(
            name: "VoiceCaptureMediumSDKTarget",
            dependencies: ["VoiceCaptureMedium"],
            path: "Sources/VoiceCaptureMedium"
        ),
        .target(
            name: "FingerPrintCaptureMediumSDKTarget",
            dependencies: ["FingerPrintCaptureMedium"],
            path: "Sources/FingerPrintCaptureMedium"
        ),

        // --- Binary Targets (Medium) ---
        .binaryTarget(name: "IDentityMediumSDK", path: "Frameworks/IDentityMediumSDK.xcframework"),
        .binaryTarget(name: "IDCaptureMedium", path: "Frameworks/IDCaptureMedium.xcframework"),
        .binaryTarget(name: "SelfieCaptureMedium", path: "Frameworks/SelfieCaptureMedium.xcframework"),
        .binaryTarget(name: "IDentityMediumModels", path: "Frameworks/IDentityMediumModels.xcframework"),
        .binaryTarget(name: "SignatureCaptureMedium", path: "Frameworks/SignatureCaptureMedium.xcframework"),
        .binaryTarget(name: "VoiceCaptureMedium", path: "Frameworks/VoiceCaptureMedium.xcframework"),
        .binaryTarget(name: "FingerPrintCaptureMedium", path: "Frameworks/FingerPrintCaptureMedium.xcframework")
    ]
)
