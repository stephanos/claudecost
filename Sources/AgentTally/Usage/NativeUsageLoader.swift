import Foundation

enum NativeUsageLoader {
  static func loadUsage(
    since: String,
    offline: Bool,
    agents: [AgentKind],
    context: UsageTrackingContext = .live
  ) async throws -> UsageSnapshot {
    let pricing = try await UsagePricingStore.loadSharedPricing(
      offline: offline,
      context: context
    )

    let rawAgents = agents.map { agent -> AgentRawData in
      switch agent {
      case .claude:
        return ClaudeUsageTracker.load(
          since: since,
          pricing: pricing,
          context: context
        )
      case .codex:
        return CodexUsageTracker.load(
          since: since,
          pricing: pricing,
          context: context
        )
      }
    }

    return UsageSnapshot(agents: rawAgents)
  }
}
