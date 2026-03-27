import AppKit
import Foundation

func clamp(_ value: Int) -> Int {
  max(0, min(100, value))
}

func adjustedVolume(step: Int) throws -> Int {
  let operation = step >= 0 ? "+" : "-"
  let amount = abs(step)
  let scriptSource = """
  set step to \(amount)
  set currentVolume to output volume of (get volume settings)
  set targetVolume to currentVolume \(operation) step
  if targetVolume < 0 then set targetVolume to 0
  if targetVolume > 100 then set targetVolume to 100
  set volume output volume targetVolume output muted false
  return targetVolume
  """

  var error: NSDictionary?
  guard let script = NSAppleScript(source: scriptSource) else {
    throw NSError(domain: "logi-fine-volume", code: 1)
  }

  let result = script.executeAndReturnError(&error)
  if let error {
    throw NSError(domain: "logi-fine-volume", code: 3, userInfo: error as? [String: Any])
  }

  if result.descriptorType == typeSInt32 || result.descriptorType == typeUInt32 {
    return clamp(Int(result.int32Value))
  }

  if let stringValue = result.stringValue, let parsed = Int(stringValue) {
    return clamp(parsed)
  }

  throw NSError(domain: "logi-fine-volume", code: 2)
}

func spawnHUD(volume: Int) {
  guard let bundleURL = Bundle.main.bundleURL as URL? else {
    return
  }

  let executableURL = bundleURL
    .appendingPathComponent("Contents")
    .appendingPathComponent("MacOS")
    .appendingPathComponent("volume_hud")

  let process = Process()
  process.executableURL = executableURL
  process.arguments = ["\(volume)"]
  process.standardOutput = nil
  process.standardError = nil
  try? process.run()
}

let step = Bundle.main.object(forInfoDictionaryKey: "LFVStep") as? Int ?? 0
if step != 0, let volume = try? adjustedVolume(step: step) {
  spawnHUD(volume: volume)
}
