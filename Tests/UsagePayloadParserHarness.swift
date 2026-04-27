import Foundation

func testUsagePayloadParser() throws {
  let output = Data(
    """
    [ccusage] WARN Fetching pricing
    {"agents":[{"name":"Claude Code","found":true,"today":48.35,"month":208.12},{"name":"Codex","found":false,"today":0,"month":0}]}
    """.utf8)

  let snapshot = try UsagePayloadParser.decodeSnapshot(from: output)
  let claude = snapshot.agents.first(where: { $0.name == "Claude Code" })
  let codex = snapshot.agents.first(where: { $0.name == "Codex" })
  try expect(claude?.today == 48.35, "today payload should decode")
  try expect(claude?.month == 208.12, "month payload should decode")
  try expect(claude?.found == true, "claude found flag should decode")
  try expect(codex?.found == false, "codex not-installed flag should decode")

  do {
    _ = try UsagePayloadParser.decodeSnapshot(from: Data("not json".utf8))
    throw TestFailure(description: "invalid payload should throw")
  } catch {}
}
