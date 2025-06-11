
import Foundation
import FirebaseCore

class TerminalEditor {
    var currentDocument: Document?
}
// Вручную загружаем GoogleService-Info.plist
if let filePath = Bundle.module.path(forResource: "GoogleService-Info", ofType: "plist"),
   let options = FirebaseOptions(contentsOfFile: filePath) {
    // Настройка Firebase с использованием переданных настроек
    FirebaseApp.configure(options: options)
    print("✅ Firebase настроен вручную через FirebaseOptions")
} else {
    print("❌ Не удалось найти GoogleService-Info.plist в Bundle.module")
}
if let app = FirebaseApp.app() {
    print("Firebase успешно инициализирован: \(app)")
} else {
    print("Ошибка при инициализации Firebase.")
}
let editor = TerminalEditor()
let cliHandler = CLIHandler(editor: editor)

cliHandler.start()

/*ConsoleEditor/
 ├── 1234567.md
 ├── 33.md
 ├── 55.md
 ├── dfdf.txt
 ├── document.txt
 ├── ee.json
 ├── eww.md
 ├── fff
 ├── gggg.json
 ├── hhhhhh.txt
 ├── hhhhtr.txt
 ├── notifications.log
 ├── Package.resolved
 ├── Package.swift
 ├── qq.md.md
 ├── rrr.md
 ├── Sources/
 │   └── ConsoleEditor/
 │       ├── CLI/
 │       │   └── CLIHandler.swift
 │       ├── Commands/
 │       │   ├── CreateDocumentCommand.swift
 │       │   ├── DeleteDocumentCommand.swift
 │       │   ├── EditCommands.swift
 │       │   ├── FilePermissionManager.swift
 │       │   ├── NotificationLogger.swift
 │       │   ├── OpenDocumentCommand.swift
 │       │   ├── SearchCommand.swift
 │       │   └── UndoRedoManager.swift
 │       ├── FirebaseService.swift
 │       ├── FileAccessControl.swift
 │       ├── FilePermission.swift
 │       ├── GoogleService-Info.plist
 │       ├── Models/
 │       │   ├── Document.swift
 │       │   ├── MarkdownDocument.swift
 │       │   ├── PlainTextDocument.swift
 │       │   ├── RichTextDocument.swift
 │       │   └── User.swift
 │       ├── Patterns/
 │       │   ├── CommandPattern.swift
 │       │   ├── FactoryPattern.swift
 │       │   ├── ObservableDocument.swift
 │       │   └── StrategyPattern.swift
 │       ├── main.swift
 │       └── UserManager.swift
 ├── Tests/
 │   └── ConsoleEditorTests/
 │       └── ConsoleEditorTests.swift
*/


