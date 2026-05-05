import Foundation

enum UsagePricingStore {
  private static let pricingURL = URL(
    string:
      "https://raw.githubusercontent.com/BerriAI/litellm/main/model_prices_and_context_window.json"
  )!
  private static let cacheTTL: TimeInterval = 24 * 60 * 60

  static func loadSharedPricing(
    offline: Bool,
    context: UsageTrackingContext
  ) async throws -> [String: ModelPricing] {
    let cacheURL = context.homeDirectory
      .appendingPathComponent(".cache")
      .appendingPathComponent("agenttally")
      .appendingPathComponent("litellm-pricing.json")

    if let cached = readCache(at: cacheURL),
      context.now.timeIntervalSince(cached.fetchedAt) < cacheTTL,
      !cached.pricing.isEmpty
    {
      return cached.pricing
    }

    if offline {
      return readCache(at: cacheURL)?.pricing ?? UsagePricing.bundled
    }

    do {
      let data = try await context.pricingDataLoader(pricingURL)
      let pricing = try parsePricing(from: data)
      guard !pricing.isEmpty else {
        throw UsageFetcherError.invalidResponse("empty pricing dataset")
      }
      try writeCache(PricingCacheFile(fetchedAt: context.now, pricing: pricing), to: cacheURL)
      return pricing
    } catch {
      return readCache(at: cacheURL)?.pricing ?? UsagePricing.bundled
    }
  }

  private static func parsePricing(from data: Data) throws -> [String: ModelPricing] {
    let rawDataset = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    let decoder = JSONDecoder()
    var pricing: [String: ModelPricing] = [:]

    for (modelName, rawValue) in rawDataset {
      guard JSONSerialization.isValidJSONObject(rawValue) else {
        continue
      }
      let entryData = try JSONSerialization.data(withJSONObject: rawValue)
      guard let modelPricing = try? decoder.decode(ModelPricing.self, from: entryData) else {
        continue
      }
      pricing[modelName] = modelPricing
    }

    return pricing
  }

  private static func readCache(at url: URL) -> PricingCacheFile? {
    guard let data = try? Data(contentsOf: url) else {
      return nil
    }
    return try? JSONDecoder().decode(PricingCacheFile.self, from: data)
  }

  private static func writeCache(_ cache: PricingCacheFile, to url: URL) throws {
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try JSONEncoder().encode(cache).write(to: url)
  }
}
