import AppKit
import Carbon
import Foundation

let hotkeyModifiers = UInt32(cmdKey | optionKey | controlKey)
let downHotkeyID: UInt32 = 1
let upHotkeyID: UInt32 = 2

func hotkeyEventHandler(
  _ nextHandler: EventHandlerCallRef?,
  _ event: EventRef?,
  _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
  guard let event, let userData else {
    return noErr
  }

  let controller = Unmanaged<HotkeyController>.fromOpaque(userData).takeUnretainedValue()
  controller.handle(event: event)
  return noErr
}

final class HotkeyController {
  private var downHotkeyRef: EventHotKeyRef?
  private var upHotkeyRef: EventHotKeyRef?
  private var eventHandlerRef: EventHandlerRef?
  private let bundleURL = Bundle.main.bundleURL
  private let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.murat-taskaynatan.logi-fine-volume.hotkeys"
  private let bundlePath = Bundle.main.bundlePath
  private let downStep = Bundle.main.object(forInfoDictionaryKey: "LFVDownStep") as? Int ?? -2
  private let upStep = Bundle.main.object(forInfoDictionaryKey: "LFVUpStep") as? Int ?? 2

  func start() {
    var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    let selfPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

    InstallEventHandler(
      GetApplicationEventTarget(),
      hotkeyEventHandler,
      1,
      &eventType,
      selfPointer,
      &eventHandlerRef
    )

    register(keyCode: UInt32(kVK_ANSI_J), id: downHotkeyID, ref: &downHotkeyRef)
    register(keyCode: UInt32(kVK_ANSI_K), id: upHotkeyID, ref: &upHotkeyRef)

    appendLog(
      "hotkeys_ready bundle=\(bundleIdentifier) down=ctrl+opt+cmd+j step=\(downStep) up=ctrl+opt+cmd+k step=\(upStep)"
    )
  }

  private func register(keyCode: UInt32, id: UInt32, ref: inout EventHotKeyRef?) {
    let hotKeyID = EventHotKeyID(signature: OSType(0x4c465648), id: id)
    RegisterEventHotKey(
      keyCode,
      hotkeyModifiers,
      hotKeyID,
      GetApplicationEventTarget(),
      0,
      &ref
    )
  }

  func handle(event: EventRef) {
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
      event,
      EventParamName(kEventParamDirectObject),
      EventParamType(typeEventHotKeyID),
      nil,
      MemoryLayout<EventHotKeyID>.size,
      nil,
      &hotKeyID
    )

    guard status == noErr else {
      appendLog("hotkey_error bundle=\(bundleIdentifier) reason=event_parameter status=\(status)")
      return
    }

    switch hotKeyID.id {
    case downHotkeyID:
      performVolumeStep(
        step: downStep,
        source: "hotkey_down",
        bundleURL: bundleURL,
        bundleIdentifier: bundleIdentifier,
        bundlePath: bundlePath
      )
    case upHotkeyID:
      performVolumeStep(
        step: upStep,
        source: "hotkey_up",
        bundleURL: bundleURL,
        bundleIdentifier: bundleIdentifier,
        bundlePath: bundlePath
      )
    default:
      appendLog("hotkey_ignored bundle=\(bundleIdentifier) id=\(hotKeyID.id)")
    }
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  private let controller = HotkeyController()

  func applicationDidFinishLaunching(_ notification: Notification) {
    controller.start()
  }
}

@main
struct VolumeHotkeysApp {
  static func main() {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
  }
}
