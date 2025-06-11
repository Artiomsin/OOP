
import Foundation

class NotificationLogger {
    static let shared = NotificationLogger()
    private let logFileName = "notifications.log"
    private let dateFormatter = DateFormatter()
    
    private init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        createLogFileIfNeeded()
    }
    
    private func createLogFileIfNeeded() {
        let fileURL = getLogFileURL()
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
    }
    
    private func getLogFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(logFileName)
    }
    
    func logNotification(documentName: String, changeDescription: String, recipients: [String]) {
        let timestamp = dateFormatter.string(from: Date())
        let recipientsList = recipients.joined(separator: ", ")
        let logEntry = "[\(timestamp)] Document '\(documentName)' changed: \(changeDescription). Recipients: \(recipientsList)\n"
        
        do {
            let fileURL = getLogFileURL()
            if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(logEntry.data(using: .utf8)!)
                fileHandle.closeFile()
            } else {
                try logEntry.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error writing to log file: \(error)")
        }
    }
    
    func readLogs() -> String {
        let fileURL = getLogFileURL()
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            return "No logs available"
        }
    }
}
