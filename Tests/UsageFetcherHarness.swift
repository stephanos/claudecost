import Foundation

func testUsageFetcherTimeoutDecision() throws {
  try expect(
    UsageFetcher.shouldTimeOut(processIsRunning: true),
    "running helper should trigger timeout handling"
  )
  try expect(
    !UsageFetcher.shouldTimeOut(processIsRunning: false),
    "completed helper should not trigger timeout handling"
  )
  try expect(
    UsageFetcher.shouldEscalateTermination(processIsRunning: true, waitedEnough: true),
    "running helper should escalate after the grace period"
  )
  try expect(
    !UsageFetcher.shouldEscalateTermination(processIsRunning: true, waitedEnough: false),
    "helper should not escalate before the grace period expires"
  )
  try expect(
    !UsageFetcher.shouldEscalateTermination(processIsRunning: false, waitedEnough: true),
    "stopped helper should not escalate"
  )
}
