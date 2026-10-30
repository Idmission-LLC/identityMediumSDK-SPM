// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IDentityMediumSDK",
    platforms: [
        .iOS("15.6")
    ],
    products: [
        .library(name: "IDentityMediumSDK", targets: ["IDentityMediumSDKTarget"]),
        .library(name: "IDentityMediumModels", targets: ["IDentityMediumModelsTarget"]),
        .library(name: "IDentityMediumNFC", targets: ["IDentityMediumNFCTarget"]),
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
            name: "IDentityMediumNFCTarget",
            dependencies: ["IDentityMediumNFC"],
            path: "Sources/IDentityMediumNFC"
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
        .binaryTarget(name: "IDentityMediumSDK", url: "https://github.com/Idmission-LLC/ios-sdk-releases/releases/download/medium-11.1.19.2.5/IDentityMediumSDK.zip", checksum: "38ad83c03b8be6e80fdf8fb12754494d3c2e18ad14e17fcc1f6ae41a579ea377"),
        .binaryTarget(name: "IDCaptureMedium", url: "https://github.com/Idmission-LLC/ios-sdk-releases/releases/download/medium-11.1.19.2.5/IDCaptureMedium.zip", checksum: "61bd7668ffeaae6fc9c60c5f4c9a2abce38bd87eb31a1a91107612e1b0263fbf"),
        .binaryTarget(name: "SelfieCaptureMedium", url: "https://github.com/Idmission-LLC/ios-sdk-releases/releases/download/medium-11.1.19.2.5/SelfieCaptureMedium.zip", checksum: "3997b12d7d2412d3a62183cd5dfd573f0c9ad254b65a0802b407dc24a2efc344"),
        .binaryTarget(name: "IDentityMediumModels", url: "https://github.com/Idmission-LLC/ios-sdk-releases/releases/download/medium-11.1.19.2.5/IDentityMediumModels.zip", checksum: "215f15fbdee33a248d7df99df68dee64ad23a56006da633ef26a7bb192ed8774"),
        .binaryTarget(name: "IDentityMediumNFC", url: "https://github.com/Idmission-LLC/ios-sdk-releases/releases/download/medium-11.1.19.2.5/IDentityMediumNFC.zip", checksum: "be6d2349a2a55e9742a1bd959b7f029fe2b9479887b021a7471d7cfd74a537f0"),
        .binaryTarget(name: "SignatureCaptureMedium", url: "https://github.com/Idmission-LLC/ios-sdk-releases/releases/download/medium-11.1.19.2.5/SignatureCaptureMedium.zip", checksum: "1e8726aa861b6dde4dc3fc993d5e7c53f7c8ff06e70572322747b4985a086ef6"),
        .binaryTarget(name: "VoiceCaptureMedium", url: "https://github.com/Idmission-LLC/ios-sdk-releases/releases/download/medium-11.1.19.2.5/VoiceCaptureMedium.zip", checksum: "6e79fa6373f17741bda44b662c8a79d375e52ef8cb4592ae3ce0cf4d6544c6c4"),
        .binaryTarget(name: "FingerPrintCaptureMedium", url: "https://github.com/Idmission-LLC/ios-sdk-releases/releases/download/medium-11.1.19.2.5/FingerPrintCaptureMedium.zip", checksum: "f75ef14284dc48bbf9603e2a57a5955cd0e8785b41b47a654389dc0d6c08e4cc")
    ]
)
