import Foundation

enum UsageRefreshController {
  private static let onlinePricingRefreshInterval: TimeInterval = 60 * 60

  struct RefreshRequest {
    let state: AppState
    let pricingMode: PricingRefreshMode
  }

  static func beginRefresh(
    from state: AppState,
    isOnBatteryPower: Bool,
    now: Date = Date()
  ) -> RefreshRequest? {
    guard !state.isRefreshing else {
      return nil
    }

    var nextState = state
    nextState.isRefreshing = true
    return RefreshRequest(
      state: nextState,
      pricingMode: pricingMode(
        from: state,
        isOnBatteryPower: isOnBatteryPower,
        now: now
      )
    )
  }

  static func applySuccess(
    snapshot: UsageSnapshot,
    pricingMode: PricingRefreshMode,
    to state: AppState,
    now: Date = Date()
  ) -> AppState {
    var nextState = state
    nextState.isRefreshing = false
    nextState.lastRefreshAt = now
    nextState.businessDays = TimeUtils.businessDaysThisMonth(now: now)
    nextState.agentSpendings = snapshot.agents.map { raw in
      AgentSpending(
        name: raw.name,
        isInstalled: raw.found,
        todayCost: raw.today,
        monthCost: raw.month,
        avgPerDay: nextState.businessDays > 0 && raw.found
          ? raw.month / Double(nextState.businessDays) : 0
      )
    }
    if pricingMode == .online {
      nextState.lastOnlinePricingRefreshAt = now
    }
    nextState.lastError = nil
    return nextState
  }

  static func applyFailure(
    error: Error,
    to state: AppState,
    now: Date = Date()
  ) -> AppState {
    var nextState = state
    nextState.isRefreshing = false
    nextState.lastRefreshAt = now
    nextState.lastError = error.localizedDescription
    return nextState
  }

  static func pricingMode(
    from state: AppState,
    isOnBatteryPower: Bool,
    now: Date = Date()
  ) -> PricingRefreshMode {
    if isOnBatteryPower {
      return .offline
    }

    guard let lastOnlinePricingRefreshAt = state.lastOnlinePricingRefreshAt else {
      return .online
    }

    if now.timeIntervalSince(lastOnlinePricingRefreshAt) >= onlinePricingRefreshInterval {
      return .online
    }

    return .offline
  }
}
