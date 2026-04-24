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
  targets: [
    .executableTarget(
      name: "AgentTally"
    )
  ]
)
