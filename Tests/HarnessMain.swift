import Foundation

@main
struct TestHarness {
  static func main() throws {
    let tests: [(String, () throws -> Void)] = [
      ("StatusPresenter", testStatusPresenter),
      ("ClaudeUsageTracker", testClaudeUsageTracker),
      ("CodexUsageTracker", testCodexUsageTracker),
      ("NativeUsageLoader", testNativeUsageLoader),
      ("UsagePricing", testUsagePricing),
      ("UsageRefreshController", testUsageRefreshController),
      ("UsageFetcher", testUsageFetcher),
      ("UsageDataScanner", testUsageDataScanner),
      ("TimeUtils", testTimeUtils),
      ("MenuRowsBuilder", testMenuRowsBuilder),
      ("DemoMode", testDemoMode),
      ("LoginItemManager", testLoginItemManager),
    ]

    var failures: [String] = []

    for (name, test) in tests {
      do {
        try test()
        print("PASS \(name)")
      } catch {
        failures.append("FAIL \(name): \(error)")
      }
    }

    if failures.isEmpty {
      print("All tests passed")
    } else {
      for failure in failures {
        print(failure)
      }
      exit(1)
    }
  }
}
