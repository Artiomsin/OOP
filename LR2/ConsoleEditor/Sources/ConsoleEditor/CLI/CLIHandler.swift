import Foundation

class CLIHandler {
    var editor: TerminalEditor
    var cursorPosition: (row: Int, col: Int) = (0, 0)
    var isInInsertMode = false
    var isInSelectionMode = false
    var selectionStart: (row: Int, col: Int)?
    var clipboard: String = ""
    let undoRedoManager = UndoRedoManager()
    var fileAccessControl = FileAccessControl()
    var isClipboardCut = false
    var currentUser: User? {
        return userManager.currentUser
    }

    lazy var userManager = UserManager(cliHandler: self)
    lazy var filePermissionManager = FilePermissionManager(cliHandler: self, editor: editor)
    
    init(editor: TerminalEditor) {
        self.editor = editor
    }
    
    func start() {
        userManager.authenticateUser()
        
        while true {
            printMainMenu()
            
            guard let input = readLine()?.lowercased() else { continue }
            
            switch input {
            case "1": createNewDocument()
            case "2": openDocument()
            case "3": editDocument()
            case "4": deleteDocument()
            case "5": saveChanges()
            case "6": searchText()
            case "7":
                print("Выход. До свидания!")
                return
            case "8":
                if currentUser?.canManageUsers() == true {
                    userManager.manageUsers()
                } else {
                    print("У вас нет прав для управления пользователями.")
                }
            case "9":
                if currentUser?.canManagePermissions() == true {
                    filePermissionManager.manageFilePermissions()
                } else {
                    print("У вас нет прав для управления правами доступа.")
                }
            case "10":  userManager.authenticateUser()
            case "11": saveToFirebase()
            case "12": viewNotificationLogs()
            default:
                print("Неверная команда.")
            }
        }
    }
    
    // Добавьте новый метод:
    private func viewNotificationLogs() {
        clearScreen()
        print("=== NOTIFICATION LOGS ===")
        let logs = NotificationLogger.shared.readLogs()
        print(logs)
        print("\nPress Enter to continue...")
        _ = readLine()
    }
    
    //функция сохранение в облако
    private func saveToFirebase() {
        guard let user = currentUser else {
            print("Требуется авторизация")
            return
        }
        
        guard var doc = editor.currentDocument else {
            print("Нет открытого документа")
            return
        }
        
        print("Введите имя файла для сохранения в Firebase (с расширением):", terminator: " ")
        guard let fileName = readLine(), !fileName.isEmpty else {
            print("Имя файла не может быть пустым")
            return
        }
        
        let components = fileName.components(separatedBy: ".")
        doc.fileName = components.count > 1 ? fileName : fileName
        
        print("Попытка сохранить файл: \(doc.fileName)")
        
        // Сохраняем документ в Firestore
        FirebaseService.shared.saveDocument(
            userID: user.userId,
            fileName: doc.fileName,
            content: doc.content
        ) { success, error in
            if success {
                print("Документ успешно сохранен в Firestore")
                
                // Дополнительно сохраняем в Firebase Storage
                let contentAsString = doc.content.joined(separator: "\n")
                FirebaseService.shared.uploadDocumentToStorage(
                    userID: user.userId,
                    fileName: doc.fileName,
                    content: contentAsString
                ) { success, error in
                    if success {
                        print("Документ также сохранен в Firebase Storage")
                    } else {
                        print("Ошибка при сохранении в Storage: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                    }
                }
            } else {
                print("Ошибка при сохранении в Firestore: \(error?.localizedDescription ?? "Неизвестная ошибка")")
            }
        }
    }

    //главное меню
    private func printMainMenu() {
        clearScreen()
        print("""
            
            ==== МЕНЮ ====
            1. Создать новый документ
            2. Открыть документ
            3. Редактировать документ
            4. Удалить документ
            5. Сохранение изменений в файл
            6. Поиск текста в документе
            7. Выйти
            8. Управление пользователями\(currentUser?.canManageUsers() == true ? "" : " (недоступно)")
            9. Управление правами доступа\(currentUser?.canManagePermissions() == true ? "" : " (недоступно)")
            10. Сменить пользователя
            11.Сохранение в облочное хранилище
            12.NOTIFICATION LOGS
            ===============
            Текущий файл: \(editor.currentDocument?.fileName ?? "Нет")
            Текущий пользователь: \(currentUser?.username ?? "Не авторизован") (\(currentUser?.roleString ?? ""))
            Введите команду:
            """, terminator: " ")
    }
    
    
    //создание документа
    func createNewDocument() {
        guard currentUser?.canCreateDocument() == true else {
            print("У вас нет прав для создания документов.")
            return
        }
        
        let createDocumentCommand = CreateDocumentCommand(editor: editor, currentUser: currentUser)
        createDocumentCommand.execute()
        
        if var doc = editor.currentDocument {
            // Добавляем текущего пользователя как наблюдателя
            doc.notifier.addObserver(currentUser!)
            
            // Устанавливаем права владельца для создателя документа
            if let username = currentUser?.username {
                fileAccessControl.setPermission(
                    forUser: username,
                    file: doc.fileName,
                    permission: .owner
                )
            }
            
            // Сохраняем информацию о владельце документа
            doc.ownerId = currentUser?.userId
            
            print("Документ '\(doc.fileName)' создан. Вам назначены права владельца.")
        }
    }

    //открытие документа
    func openDocument() {
        print("Доступные пользователи в системе:")
           print(fileAccessControl.userRoles.keys)
        let openDocumentCommand = OpenDocumentCommand(editor: editor)
        openDocumentCommand.execute()
        
        if let doc = editor.currentDocument {
            guard let username = currentUser?.username else {
                print("Ошибка: пользователь не авторизован.")
                return
            }
            
            let permission = fileAccessControl.getPermission(forUser: username, file: doc.fileName)
            
            if permission.contains(.denyRead) || !permission.contains(.read) {
                print("У вас нет прав для просмотра этого документа.")
                editor.currentDocument = nil
                return
            }
            
            doc.notifier.addObserver(currentUser!)
        }
    }
    
    // Функция поиска текста в документе
    func searchText() {
        guard let doc = editor.currentDocument else {
            print("Нет открытого документа для поиска.")
            return
        }
        
        guard let username = currentUser?.username else {
            print("Ошибка: пользователь не авторизован.")
            return
        }
        
        let permission = fileAccessControl.getPermission(forUser: username, file: doc.fileName)
        
        if !permission.contains(.read) {
            print("У вас нет прав для поиска текста этого документа.")
            return
        }
        
        let command = SearchCommand(editor: editor)
        command.execute()
    }
    
    func deleteDocument() {
        guard let doc = editor.currentDocument else {
            print("Нет открытого документа для удаления.")
            return
        }
        
        guard let username = currentUser?.username else {
            print("Ошибка: пользователь не авторизован.")
            return
        }
        
        // Проверяем специальные права на файл или стандартные права по роли
        let permission = fileAccessControl.getPermission(forUser: username, file: doc.fileName)
        
        if !permission.contains(.delete) {
            print("У вас нет прав для удаления этого документа.")
            return
        }
        
        let command = DeleteDocumentCommand(editor: editor)
        command.execute()
        
        // Удаляем все записи о правах доступа для этого файла
        fileAccessControl.filePermissions.removeValue(forKey: doc.fileName)
    }
    
    func editDocument() {
        guard let doc = editor.currentDocument else {
            print("Документ не открыт.")
            return
        }
        
        guard let username = currentUser?.username else {
            print("Ошибка: пользователь не авторизован.")
            return
        }
        
        let permission = fileAccessControl.getPermission(forUser: username, file: doc.fileName)
        
        if !permission.contains(.edit) {
            print("У вас нет прав для редактирования этого документа.")
            return
        }
        
        print("Текущий документ: \(doc.fileName)")
        print("Ваши права: \(permission.description())")
        startEditing()
    }
    
    func saveChanges() {
        guard let doc = editor.currentDocument else { return }
        
        guard let username = currentUser?.username else {
            print("Ошибка: пользователь не авторизован.")
            return
        }
        
        // Проверяем права на сохранение
        let permission = fileAccessControl.getPermission(forUser: username, file: doc.fileName)
        
        if !permission.contains(.edit) {
            print("У вас нет прав для сохранения этого документа.")
            return
        }
        
        if doc.save() {
            print("Изменения сохранены в файл '\(doc.fileName)'.")
            doc.notifier.notifyObservers(document: doc, change: "Документ сохранен")
        } else {
            print("Ошибка при сохранении файла.")
        }
    }
    
    // Основная функция редактирования текста
    func startEditing() {
        while true {
            clearScreen()  // Очистить экран перед каждым обновлением
            displayContent() // Отображаем актуальный контент
            print("Введите команду (1 - влево, 2 - вправо, 3 - вниз, 4 - вверх, t - для ввода текста, d - удалить символ слева, s - режим выделения, v - вставить из буфера, /exit - выход из редактора): ", terminator: "")
            
            guard let input = readLine()?.lowercased() else { continue }
            
            switch input {
            case "1":
                moveCursorLeft()
            case "2":
                moveCursorRight()
            case "3":
                moveCursorDown()
            case "4":
                moveCursorUp()
            case "t":
                startInsertMode()
            case "d":
                deleteCharacterLeft()
            case "s":
                startSelectionMode()
            case "v":
                pasteClipboard()
            case "u": undoRedoManager.undo()
                clearScreen()
                displayContent()
            case "r": undoRedoManager.redo()
                clearScreen()
                displayContent()
            case "h": undoRedoManager.showHistory()
                
            case "/exit":
                return
            default:
                print("Неизвестная команда.")
            }
        }
    }
    
    // Очистка экрана
    func clearScreen() {
        let task = Process()
        task.launchPath = "/usr/bin/env"  // Используем /usr/bin/env для корректного выполнения
        task.arguments = ["clear"]  // Команда для очистки экрана
        task.launch()  // Запуск команды
        task.waitUntilExit()  // Ожидание завершения команды перед продолжением выполнения
        
        // Перемещаем курсор в начало экрана
        print("\u{001B}[H", terminator: "")
        fflush(stdout)  // Сбрасываем вывод, чтобы обновления сразу появились
    }
    
    // Отображение контента с курсором
    func displayContent() {
        print("Редактор документа. Для выхода введите /exit.")
        if let currentFile = editor.currentDocument?.fileName {
            print("Редактируемый файл: \(currentFile)")
        }
        print(String(repeating: "=", count: 50))
        
        for (index, line) in (editor.currentDocument?.content ?? []).enumerated() {
            var displayLine = line
            
            if isInSelectionMode, let selStart = selectionStart {
                let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
                let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
                
                if index < start.row || index > end.row {
                    // Строка вне диапазона выделения
                    displayLine = line
                } else if start.row == end.row {
                    // Однострочное выделение
                    let from = min(start.col, end.col)
                    let to = min(max(start.col, end.col), line.count)
                    let startIndex = line.index(line.startIndex, offsetBy: from)
                    let endIndex = line.index(line.startIndex, offsetBy: to)
                    let prefix = line.prefix(upTo: startIndex)
                    let selected = line[startIndex..<endIndex]
                    let suffix = line.suffix(from: endIndex)
                    displayLine = prefix + "[" + selected + "]" + suffix
                } else {
                    // Многострочное выделение
                    if index == start.row {
                        let startIndex = line.index(line.startIndex, offsetBy: min(start.col, line.count))
                        let prefix = line.prefix(upTo: startIndex)
                        let suffix = line.suffix(from: startIndex)
                        displayLine = prefix + "[" + suffix
                    } else if index > start.row && index < end.row {
                        displayLine = "[" + line + "]"
                    } else if index == end.row {
                        let endIndex = line.index(line.startIndex, offsetBy: min(end.col, line.count))
                        let prefix = line.prefix(upTo: endIndex)
                        let suffix = line.suffix(from: endIndex)
                        displayLine = prefix + "]" + suffix
                    }
                }
                
                // Вставка курсора, если он в этой строке
                if index == cursorPosition.row && !displayLine.contains("|") {
                    let cursorIdx = min(cursorPosition.col, displayLine.count)
                    let cursorPositionIndex = displayLine.index(displayLine.startIndex, offsetBy: cursorIdx)
                    displayLine.insert("|", at: cursorPositionIndex)
                }
            } else if index == cursorPosition.row {
                // Без выделения, только курсор
                let cursorIdx = min(cursorPosition.col, line.count)
                let cursorIndex = line.index(line.startIndex, offsetBy: cursorIdx)
                displayLine = line.prefix(upTo: cursorIndex) + "|" + line.suffix(from: cursorIndex)
            }
            
            print(displayLine)
        }
        
        print(String(repeating: "=", count: 50))
        
        // Вывод выделенного текста
        if isInSelectionMode, let selStart = selectionStart {
            let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
            let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
            
            var selectedText = ""
            let lines = editor.currentDocument?.content ?? []
            
            for i in start.row...end.row {
                guard i < lines.count else { continue }
                let line = lines[i]
                if i == start.row && i == end.row {
                    let from = min(start.col, line.count)
                    let to = min(end.col, line.count)
                    let startIdx = line.index(line.startIndex, offsetBy: from)
                    let endIdx = line.index(line.startIndex, offsetBy: to)
                    selectedText += String(line[startIdx..<endIdx])
                } else if i == start.row {
                    let from = min(start.col, line.count)
                    let startIdx = line.index(line.startIndex, offsetBy: from)
                    selectedText += String(line[startIdx...]) + "\n"
                } else if i == end.row {
                    let to = min(end.col, line.count)
                    let endIdx = line.index(line.startIndex, offsetBy: to)
                    selectedText += String(line[..<endIdx])
                } else {
                    selectedText += line + "\n"
                }
            }
            
        }
    }
    
    
    func moveCursorLeft() {
        let command = MoveCursorCommand(cliHandler: self, direction: .left)
        undoRedoManager.execute(command)
    }
    
    func moveCursorRight() {
        let command = MoveCursorCommand(cliHandler: self, direction: .right)
        undoRedoManager.execute(command)
    }
    
    func moveCursorUp() {
        let command = MoveCursorCommand(cliHandler: self, direction: .up)
        undoRedoManager.execute(command)
    }
    
    func moveCursorDown() {
        let command = MoveCursorCommand(cliHandler: self, direction: .down)
        undoRedoManager.execute(command)
    }
    
    func startInsertMode() {
        isInInsertMode = true
        print("Вы вошли в режим ввода текста. Для выхода из режима ввода введите /e.")
        while isInInsertMode {
            clearScreen()
            displayContent()
            print("\nВведите текст (для новой строки используйте Enter, для выхода введите /e): ", terminator: "")
            
            guard let inputText = readLine() else { continue }
            
            if inputText == "/e" {
                isInInsertMode = false
                return
            }
            
            let command = InsertTextCommand(
                document: editor.currentDocument,
                cliHandler: self,
                text: inputText
            )
            undoRedoManager.execute(command)
        }
    }
    
    func deleteCharacterLeft() {
        guard cursorPosition.col > 0 else { return }
        
        let range = (
            start: (row: cursorPosition.row, col: cursorPosition.col - 1),
            end: (row: cursorPosition.row, col: cursorPosition.col)
        )
        
        let command = DeleteTextCommand(
            document: editor.currentDocument,
            cliHandler: self,
            range: range
        )
        undoRedoManager.execute(command)
    }
    
    func startSelectionMode() {
        isInSelectionMode = true
        selectionStart = cursorPosition
        while isInSelectionMode {
            clearScreen()
            displayContent()
            print("Выделение: от \(selectionStart!) до \(cursorPosition)")
            print("Команды: 1 - влево, 2 - вправо, 3 - вниз, 4 - вверх, c - копировать, x - вырезать, i - курсив, b - жирный, u - подчёркнутый, r - снять формат, /e - выход")
            
            
            guard let input = readLine()?.lowercased() else { continue }
            
            switch input {
            case "1": moveCursorLeft()
            case "2": moveCursorRight()
            case "3": moveCursorDown()
                cursorPosition.col = editor.currentDocument?.content[cursorPosition.row].count ?? 0
            case "4": moveCursorUp()
                cursorPosition.col = editor.currentDocument?.content[cursorPosition.row].count ?? 0
            case "c":
                clipboard = getSelectedText()
                isClipboardCut = false
                print("Текст скопирован в буфер обмена.")
            case "x":
                clipboard = getSelectedText()
                deleteSelectedText()
                isClipboardCut = true
                print("Текст вырезан и скопирован.")
                isInSelectionMode = false
                selectionStart = nil
                return
            case "i":
                applyFormattingToSelection(format: .italic)
            case "b":
                applyFormattingToSelection(format: .bold)
            case "u":
                applyFormattingToSelection(format: .underline)
            case "r":
                removeFormattingFromSelection()
            case "/e":
                isInSelectionMode = false
                selectionStart = nil
                return
            default:
                print("Неизвестная команда.")
            }
        }
    }
    func positionLessThanOrEqual(_ a: (row: Int, col: Int), _ b: (row: Int, col: Int)) -> Bool {
        return a.row < b.row || (a.row == b.row && a.col <= b.col)
    }
    func getSelectedText() -> String {
        guard let selStart = selectionStart else { return "" }
        
        let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
        let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
        
        var selectedText = ""
        let lines = editor.currentDocument?.content ?? []
        
        for i in start.row...end.row {
            guard i < lines.count else { continue }
            let line = lines[i]
            if i == start.row && i == end.row {
                let from = min(start.col, line.count)
                let to = min(end.col, line.count)
                let startIdx = line.index(line.startIndex, offsetBy: from)
                let endIdx = line.index(line.startIndex, offsetBy: to)
                selectedText += String(line[startIdx..<endIdx])
            } else if i == start.row {
                let from = min(start.col, line.count)
                let startIdx = line.index(line.startIndex, offsetBy: from)
                selectedText += String(line[startIdx...]) + "\n"
            } else if i == end.row {
                let to = min(end.col, line.count)
                let endIdx = line.index(line.startIndex, offsetBy: to)
                selectedText += String(line[..<endIdx])
            } else {
                selectedText += line + "\n"
            }
        }
        
        return selectedText
    }
    
    func deleteSelectedText() {
        guard let selStart = selectionStart else { return }
        
        let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
        let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
        
        var lines = editor.currentDocument?.content ?? []
        
        if start.row == end.row {
            var line = lines[start.row]
            let from = min(start.col, line.count)
            let to = min(end.col, line.count)
            let startIdx = line.index(line.startIndex, offsetBy: from)
            let endIdx = line.index(line.startIndex, offsetBy: to)
            line.removeSubrange(startIdx..<endIdx)
            lines[start.row] = line
        } else {
            let startLine = lines[start.row]
            let endLine = lines[end.row]
            
            let startIdx = startLine.index(startLine.startIndex, offsetBy: min(start.col, startLine.count))
            let endIdx = endLine.index(endLine.startIndex, offsetBy: min(end.col, endLine.count))
            
            let newStart = String(startLine.prefix(upTo: startIdx))
            let newEnd = String(endLine.suffix(from: endIdx))
            
            lines[start.row] = newStart + newEnd
            lines.removeSubrange((start.row + 1)...end.row)
        }
        
        editor.currentDocument?.content = lines
        cursorPosition = start
    }
    
    func pasteClipboard() {
        guard !clipboard.isEmpty else { return }
        
        let command = PasteCommand(
            document: editor.currentDocument,
            cliHandler: self,
            text: clipboard
        )
        undoRedoManager.execute(command)
        // Если это был вырезанный текст — очищаем буфер
        if isClipboardCut {
            clipboard = ""
            isClipboardCut = false
        }
    }
    
    func applyFormattingToSelection(format: TextFormat) {
        guard let selStart = selectionStart else { return }
        
        let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
        let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
        
        let formatType: FormatTextCommand.FormatType
        switch format {
        case .bold: formatType = .bold
        case .italic: formatType = .italic
        case .underline: formatType = .underline
        }
        
        let command = FormatTextCommand(
            document: editor.currentDocument,
            cliHandler: self,
            range: (start, end),
            format: formatType
        )
        undoRedoManager.execute(command)
        
        isInSelectionMode = false
        selectionStart = nil
    }
    
    
    enum TextFormat {
        case bold
        case italic
        case underline
    }
    
    func removeFormattingFromSelection() {
        guard selectionStart != nil else { return }
        
        let selectedText = getSelectedText()
        guard !selectedText.isEmpty else { return }
        
        // Удаление всех типов форматирования
        let plainText = selectedText
            .replacingOccurrences(of: "**", with: "")     // bold
            .replacingOccurrences(of: "*", with: "")       // italic
            .replacingOccurrences(of: "<u>", with: "")     // underline start
            .replacingOccurrences(of: "</u>", with: "")    // underline end
        
        deleteSelectedText()
        
        let currentLine = editor.currentDocument?.content[cursorPosition.row] ?? ""
        let leftPart = currentLine.prefix(cursorPosition.col)
        let rightPart = currentLine.suffix(currentLine.count - cursorPosition.col)
        
        editor.currentDocument?.content[cursorPosition.row] = leftPart + plainText + rightPart
        cursorPosition.col += plainText.count
    }
}


