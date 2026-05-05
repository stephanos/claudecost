import Foundation

func testNativeUsageLoader() throws {
  try testNativeUsageLoaderBuildsSnapshotForRequestedAgents()
}

private func testNativeUsageLoaderBuildsSnapshotForRequestedAgents() throws {
  let homeDirectory = try makeTemporaryDirectory()
  defer { try? FileManager.default.removeItem(at: homeDirectory) }

  try writeTestFile(
    homeDirectory
      .appendingPathComponent(".config")
      .appendingPathComponent("claude")
      .appendingPathComponent("projects")
      .appendingPathComponent("demo")
      .appendingPathComponent("usage.jsonl"),
    contents:
      #"{"timestamp":"2026-05-04T08:00:00Z","message":{"id":"m1","model":"claude-sonnet-4-20250514","usage":{"input_tokens":1000,"output_tokens":500}}}"#,
    modifiedAt: 1_000
  )

  let snapshot = try waitFor {
    try await NativeUsageLoader.loadUsage(
      since: "20260501",
      offline: true,
      agents: [.claude],
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

  try expect(snapshot.agents.map(\.name) == ["Claude Code"], "requested agents should be preserved")
}
