import Foundation

public struct AgentSpending: Equatable {
  public let name: String
  public let isInstalled: Bool
  public let todayCost: Double
  public let monthCost: Double
  public let avgPerDay: Double

  public init(name: String, isInstalled: Bool, todayCost: Double, monthCost: Double, avgPerDay: Double) {
    self.name = name
    self.isInstalled = isInstalled
    self.todayCost = todayCost
    self.monthCost = monthCost
    self.avgPerDay = avgPerDay
  }
}
