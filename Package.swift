// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "AgentTally",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .executable(
      name: "AgentTally",
      targets: ["AgentTally"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.9.1")
  ],
  targets: [
    .executableTarget(
      name: "AgentTally",
      dependencies: [
        .product(name: "Sparkle", package: "Sparkle")
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", "-rpath",
          "-Xlinker", "@executable_path/../Frameworks",
        ])
      ]
    )
  ]
)
