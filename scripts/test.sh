#!/usr/bin/env bash
set -euo pipefail

mkdir -p .build

# Compile the real app target first so package-level Swift/concurrency issues are
# caught by `mise run test`, not only by the release bundle build in CI.
bash scripts/build_swift.sh

swiftc \
  -module-name AgentTallyTestHarness \
  -o .build/agenttally-test-harness \
  Sources/AgentTally/AppState.swift \
  Sources/AgentTally/LoginItemManager.swift \
  Sources/AgentTally/MenuRowsBuilder.swift \
  Sources/AgentTally/PowerSource.swift \
  Sources/AgentTally/StatusPresenter.swift \
  Sources/AgentTally/TimeUtils.swift \
  Sources/AgentTally/UsageFetcher.swift \
  Sources/AgentTally/UsagePayloadParser.swift \
  Sources/AgentTally/UsageRefreshController.swift \
  Tests/TestSupport.swift \
  Tests/StatusPresenterHarness.swift \
  Tests/UsageRefreshControllerHarness.swift \
  Tests/UsageFetcherHarness.swift \
  Tests/UsagePayloadParserHarness.swift \
  Tests/TimeUtilsHarness.swift \
  Tests/MenuRowsHarness.swift \
  Tests/LoginItemHarness.swift \
  Tests/HarnessMain.swift

.build/agenttally-test-harness
