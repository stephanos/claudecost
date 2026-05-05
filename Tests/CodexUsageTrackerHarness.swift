import Foundation

func testCodexUsageTracker() throws {
  try testCodexTrackerUsesLastTokenUsage()
  try testCodexTrackerReconstructsTotalsWhenLastUsageIsMissing()
  try testCodexTrackerMatchesAliasedModelPricing()
}

private let codexTrackerNow = Calendar.current.date(
  from: DateComponents(year: 2026, month: 5, day: 4, hour: 12, minute: 0, second: 0)
)!

private func testCodexTrackerUsesLastTokenUsage() throws {
  let homeDirectory = try makeTemporaryDirectory()
  defer { try? FileManager.default.removeItem(at: homeDirectory) }

  let sessionFile =
    homeDirectory
    .appendingPathComponent(".codex")
    .appendingPathComponent("sessions")
    .appendingPathComponent("2026")
    .appendingPathComponent("05")
    .appendingPathComponent("04")
    .appendingPathComponent("session.jsonl")

  try writeTestFile(
    sessionFile,
    contents: [
      #"{"timestamp":"2026-05-04T08:00:00Z","type":"turn_context","payload":{"model":"gpt-5"}}"#,
      #"{"timestamp":"2026-05-04T08:01:00Z","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":1000,"cached_input_tokens":250,"output_tokens":100}}}}"#,
    ].joined(separator: "\n"),
    modifiedAt: 1_000
  )

  let raw = CodexUsageTracker.load(
    since: "20260501",
    pricing: UsagePricing.bundled,
    context: UsageTrackingContext(
      environment: [:],
      homeDirectory: homeDirectory,
      now: codexTrackerNow,
      pricingDataLoader: { _ in Data() }
    )
  )

  try expect(raw.found, "Codex should be found when session files exist")
  try expect(raw.today > 0, "last_token_usage should produce a cost")
}

private func testCodexTrackerReconstructsTotalsWhenLastUsageIsMissing() throws {
  let homeDirectory = try makeTemporaryDirectory()
  defer { try? FileManager.default.removeItem(at: homeDirectory) }

  let sessionFile =
    homeDirectory
    .appendingPathComponent(".codex")
    .appendingPathComponent("sessions")
    .appendingPathComponent("2026")
    .appendingPathComponent("05")
    .appendingPathComponent("04")
    .appendingPathComponent("session.jsonl")

  try writeTestFile(
    sessionFile,
    contents: [
      #"{"timestamp":"2026-05-04T08:00:00Z","type":"turn_context","payload":{"model":"gpt-5-codex"}}"#,
      #"{"timestamp":"2026-05-04T08:01:00Z","type":"event_msg","payload":{"type":"token_count","info":{"total_token_usage":{"input_tokens":1000,"cached_input_tokens":250,"output_tokens":100}}}}"#,
      #"{"timestamp":"2026-05-04T08:02:00Z","type":"event_msg","payload":{"type":"token_count","info":{"total_token_usage":{"input_tokens":1300,"cached_input_tokens":300,"output_tokens":180}}}}"#,
    ].joined(separator: "\n"),
    modifiedAt: 2_000
  )

  let raw = CodexUsageTracker.load(
    since: "20260501",
    pricing: UsagePricing.bundled,
    context: UsageTrackingContext(
      environment: [:],
      homeDirectory: homeDirectory,
      now: codexTrackerNow,
      pricingDataLoader: { _ in Data() }
    )
  )

  let firstCost = UsagePricing.calculateCodexCost(
    inputTokens: 1000,
    cachedInputTokens: 250,
    outputTokens: 100,
    pricing: UsagePricing.bundled["gpt-5"]!
  )
  let secondCost = UsagePricing.calculateCodexCost(
    inputTokens: 300,
    cachedInputTokens: 50,
    outputTokens: 80,
    pricing: UsagePricing.bundled["gpt-5"]!
  )

  try expectNear(
    raw.today, firstCost + secondCost, "total_token_usage deltas should be reconstructed")
}

private func testCodexTrackerMatchesAliasedModelPricing() throws {
  let homeDirectory = try makeTemporaryDirectory()
  defer { try? FileManager.default.removeItem(at: homeDirectory) }

  let sessionFile =
    homeDirectory
    .appendingPathComponent(".codex")
    .appendingPathComponent("sessions")
    .appendingPathComponent("2026")
    .appendingPathComponent("05")
    .appendingPathComponent("04")
    .appendingPathComponent("session.jsonl")

  try writeTestFile(
    sessionFile,
    contents: [
      #"{"timestamp":"2026-05-04T08:00:00Z","type":"turn_context","payload":{"model":"openai/gpt-5-codex"}}"#,
      #"{"timestamp":"2026-05-04T08:01:00Z","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":100,"cached_input_tokens":0,"output_tokens":10}}}}"#,
    ].joined(separator: "\n"),
    modifiedAt: 3_000
  )

  let raw = CodexUsageTracker.load(
    since: "20260501",
    pricing: UsagePricing.bundled,
    context: UsageTrackingContext(
      environment: [:],
      homeDirectory: homeDirectory,
      now: codexTrackerNow,
      pricingDataLoader: { _ in Data() }
    )
  )

  try expect(raw.today > 0, "provider-prefixed alias should resolve to bundled pricing")
}
