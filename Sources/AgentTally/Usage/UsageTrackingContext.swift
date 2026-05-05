import Foundation

typealias PricingDataLoader = @Sendable (URL) async throws -> Data

struct UsageTrackingContext: Sendable {
  let environment: [String: String]
  let homeDirectory: URL
  let now: Date
  let pricingDataLoader: PricingDataLoader

  static var live: UsageTrackingContext {
    UsageTrackingContext(
      environment: ProcessInfo.processInfo.environment,
      homeDirectory: FileManager.default.homeDirectoryForCurrentUser,
      now: Date(),
      pricingDataLoader: { url in
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
          200..<300 ~= httpResponse.statusCode
        else {
          throw UsageFetcherError.invalidResponse("pricing request failed")
        }
        return data
      }
    )
  }
}
