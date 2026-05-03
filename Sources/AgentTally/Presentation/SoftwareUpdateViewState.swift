import Foundation

public struct SoftwareUpdateViewState: Equatable, Sendable {
  public static let idle = SoftwareUpdateViewState()

  public let availableVersion: String?

  public init(availableVersion: String? = nil) {
    let trimmedVersion = availableVersion?.trimmingCharacters(in: .whitespacesAndNewlines)
    self.availableVersion = trimmedVersion?.isEmpty == false ? trimmedVersion : nil
  }

  public var menuTitle: String {
    guard let availableVersion else {
      return "Check for Updates..."
    }

    if availableVersion.lowercased().hasPrefix("v") {
      return "Update Available: \(availableVersion)..."
    }

    return "Update Available: v\(availableVersion)..."
  }
}
