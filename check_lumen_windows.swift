import Cocoa

let options = CGWindowListOption(arrayLiteral: .optionAll)
let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []

for window in windowList {
    if let ownerName = window[kCGWindowOwnerName as String] as? String,
       let ownerPID = window[kCGWindowOwnerPID as String] as? Int {
        if ownerName == "Lumen" || ownerPID == 69106 {
            print("Found Lumen window: \(window)")
        }
    }
}
print("Done")
