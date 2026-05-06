import Foundation

@MainActor
final class RefreshGenerationGate {
  private var generation: UInt64 = 0

  func nextGeneration() -> UInt64 {
    generation += 1
    return generation
  }

  func isCurrent(_ generation: UInt64) -> Bool {
    return generation == self.generation
  }
}
