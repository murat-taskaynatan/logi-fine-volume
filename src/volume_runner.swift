import AppKit
import Foundation

@main
struct VolumeRunnerApp {
  static func main() {
    let step = Bundle.main.object(forInfoDictionaryKey: "LFVStep") as? Int ?? 0
    let bundlePath = Bundle.main.bundlePath
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? "unknown"

    performVolumeStep(
      step: step,
      source: "app",
      bundleURL: Bundle.main.bundleURL,
      bundleIdentifier: bundleIdentifier,
      bundlePath: bundlePath
    )
  }
}
