import Foundation

@MainActor
func testRefreshGenerationGate() throws {
  try testGenerationGateTracks()
  try testGenerationGateDetectsStaleness()
  try testGenerationGateNumbersMonotonically()
}

@MainActor
private func testGenerationGateTracks() throws {
  let gate = RefreshGenerationGate()
  let gen1 = gate.nextGeneration()
  try expect(gen1 == 1, "first generation should be 1")
  try expect(gate.isCurrent(gen1), "latest generation should be current")
}

@MainActor
private func testGenerationGateDetectsStaleness() throws {
  let gate = RefreshGenerationGate()
  let gen1 = gate.nextGeneration()
  let gen2 = gate.nextGeneration()
  try expect(
    !gate.isCurrent(gen1),
    "older generation should not be current"
  )
  try expect(
    gate.isCurrent(gen2),
    "latest generation should be current"
  )
}

@MainActor
private func testGenerationGateNumbersMonotonically() throws {
  let gate = RefreshGenerationGate()
  var lastGen: UInt64 = 0
  for _ in 0..<100 {
    let gen = gate.nextGeneration()
    try expect(
      gen > lastGen,
      "generations must be strictly increasing"
    )
    lastGen = gen
  }
}
