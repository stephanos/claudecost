import Foundation

func testUsageFetcher() throws {
  try testUsageFetcherLoadsNativeSnapshot()
}

private func testUsageFetcherLoadsNativeSnapshot() throws {
  let homeDirectory = try makeTemporaryDirectory()
  defer { try? FileManager.default.removeItem(at: homeDirectory) }

  try writeTestFile(
    homeDirectory
      .appendingPathComponent(".codex")
      .appendingPathComponent("sessions")
      .appendingPathComponent("2026")
      .appendingPathComponent("05")
      .appendingPathComponent("04")
      .appendingPathComponent("session.jsonl"),
    contents: [
      #"{"timestamp":"2026-05-04T08:00:00Z","type":"turn_context","payload":{"model":"gpt-5"}}"#,
      #"{"timestamp":"2026-05-04T08:01:00Z","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":1000,"cached_input_tokens":250,"output_tokens":100}}}}"#,
    ].joined(separator: "\n"),
    modifiedAt: 1_000
  )

  let snapshot = try waitFor {
    try await UsageFetcher.fetchUsage(
      offline: true,
      agents: [.codex],
      context: UsageTrackingContext(
        environment: [:],
        homeDirectory: homeDirectory,
        now: Calendar.current.date(
          from: DateComponents(year: 2026, month: 5, day: 4, hour: 12, minute: 0, second: 0)
        )!,
        pricingDataLoader: { _ in Data() }
      )
    )
  }

  try expect(snapshot.agents.first?.name == "Codex", "native fetch path should return Codex data")
}
