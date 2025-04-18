import Foundation


let cli = CLIHandler()
cli.start()
/*
class SimpleEditor {
    var document: [[Character]]
    var cursorX: Int
    var cursorY: Int
    var isRunning: Bool
    
    init(rows: Int, columns: Int) {
        self.document = Array(repeating: Array(repeating: "_", count: columns), count: rows)
        self.cursorX = 0
        self.cursorY = 0
        self.isRunning = true
    }
    
    // Запуск редактора
    func start() {
        print("Введите количество строк документа:")
        guard let rowsInput = readLine(), let rows = Int(rowsInput), rows > 0 else {
            print("Неверное количество строк.")
            return
        }
        
        print("Введите количество столбцов документа:")
        guard let columnsInput = readLine(), let columns = Int(columnsInput), columns > 0 else {
            print("Неверное количество столбцов.")
            return
        }

        // Инициализация документа с заданными размерами
        self.document = Array(repeating: Array(repeating: "_", count: columns), count: rows)
        self.cursorX = 0
        self.cursorY = 0
        self.isRunning = true
        
        while isRunning {
            printDocument()
            handleInput()
        }
    }
    
    func printDocument() {
        // Вместо очищения экрана, перерисовываем только измененные строки
        // Печатаем только измененные строки, что ускоряет процесс

        for (y, row) in document.enumerated() {
            if y == cursorY {
                var rowWithCursor = row
                rowWithCursor[cursorX] = "|" // Показываем курсор
                print(String(rowWithCursor))
            } else {
                print(String(row)) // Печать обычной строки
            }
        }
        
        // Печатаем информацию о положении курсора
        print("\nКурсор в (\(cursorX), \(cursorY))")
        print("Используй 8 (вверх), 2 (вниз), 4 (влево), 6 (вправо), d (удалить), любой символ - для ввода. 'q' - выход")
    }
    
    func handleInput() {
        if let input = readLine(strippingNewline: true) {
            switch input {
            case "8": if cursorY > 0 { cursorY -= 1 } // Перемещение вверх
            case "2": if cursorY < document.count - 1 { cursorY += 1 } // Перемещение вниз
            case "4": if cursorX > 0 { cursorX -= 1 } // Перемещение влево
            case "6": if cursorX < document[cursorY].count - 1 { cursorX += 1 } // Перемещение вправо
            case "d":
                document[cursorY][cursorX] = "_" // Удаление символа, заменяем на "_"
            case "q":
                isRunning = false // Выход из редактора
            default:
                if input.count == 1 { // Ввод одного символа
                    document[cursorY][cursorX] = Character(input)
                }
            }
        }
    }
}

// Запуск редактора
let editor = SimpleEditor(rows: 7, columns: 16)
editor.start()
*/


/*
 📂 SwiftTextEditor
 │
 ├── 📂 Models
 │   ├── Document.swift
 │   ├── PlainTextDocument.swift
 │   ├── MarkdownDocument.swift
 │   ├── RichTextDocument.swift
 │   ├── User.swift
 │   └── RoleManager.swift
 │
 ├── 📂 Patterns
 │   ├── FactoryPattern.swift
 │   ├── AdapterPattern.swift
 │   ├── DecoratorPattern.swift
 │   ├── CommandPattern.swift
 │   ├── StrategyPattern.swift
 │   ├── ObserverPattern.swift
 │   └── SingletonPattern.swift
 │
 ├── 📂 Storage
 │   ├── LocalStorage.swift
 │   └── CloudStorage.swift
 │
 ├── 📂 Commands
 │   ├── InsertTextCommand.swift
 │   ├── DeleteTextCommand.swift
 │   └── UndoRedoManager.swift
 │
 ├── 📂 CLI
 │   └── CLIHandler.swift
 │
 └── main.swift
 */

/*
 План выполнения лабораторной работы №2 ("OOP Patterns")
 Мы будем постепенно добавлять функционал, используя принципы объектно-ориентированного программирования (ООП) и паттерны проектирования.

 📌 Этап 1: Базовая система управления документами
 🔹 Функциональность:
 ✅ Реализация классов Document, PlainTextDocument, MarkdownDocument, RichTextDocument.
 ✅ Реализация фабричного паттерна (Factory Pattern) для создания разных типов документов.
 ✅ Возможность создания, открытия, редактирования, сохранения и удаления документов.
 ✅ Поддержка форматов: TXT, JSON, XML.
 ✅ CLI (Command Line Interface) для взаимодействия с пользователем.
 ✅ Корректное хранение файлов в заданной директории.

 📌 Используемые паттерны:
 ✔ Factory Method (для создания документов разных типов).

 📌 Этап 2: Редактирование и форматирование текста
 🔹 Функциональность:
 ✅ Добавление текста, удаление, изменение.
 ✅ Возможность форматирования текста (жирный, курсив, подчёркнутый).
 ✅ Реализация копирования, вырезания, вставки текста.
 ✅ Поиск текста в документе.

 📌 Используемые паттерны:
 ✔ Decorator Pattern (для форматирования текста).

 📌 Этап 3: Система "Отменить / Повторить" (Undo/Redo)
 🔹 Функциональность:
 ✅ Добавление истории изменений документа.
 ✅ Реализация команд "Отмена" (Undo) / "Повторить" (Redo).

 📌 Используемые паттерны:
 ✔ Command Pattern (для управления действиями пользователя).

 📌 Этап 4: Управление пользователями и правами доступа
 🔹 Функциональность:
 ✅ Добавление ролей пользователей (Viewer, Editor, Admin).
 ✅ Ограничение доступа для пользователей в зависимости от их роли.
 ✅ Реализация наблюдателя для уведомления пользователей об изменениях.

 📌 Используемые паттерны:
 ✔ Strategy Pattern (разные уровни доступа).
 ✔ Observer Pattern (уведомления об изменениях).

 📌 Этап 5: Хранение документов и экспорт в разные форматы
 🔹 Функциональность:
 ✅ Возможность сохранения в локальные файлы, базу данных, облако.
 ✅ Экспорт в разные форматы (TXT, JSON, XML).
 ✅ Конвертация между форматами (Markdown <-> PlainText <-> RichText).

 📌 Используемые паттерны:
 ✔ Adapter Pattern (для работы с разными форматами).
 ✔ Strategy Pattern (для выбора места хранения).

 📌 Этап 6: Настройки и персонализация
 🔹 Функциональность:
 ✅ Глобальные настройки темы, шрифта, размера текста.
 ✅ Реализация истории редактирования документа.

 📌 Используемые паттерны:
 ✔ Singleton Pattern (для хранения настроек).

 📌 Финальный этап: Тестирование и подготовка отчёта
 ✅ Тестирование системы (unit-тесты).
 ✅ Подготовка UML-диаграммы.
 ✅ Оформление README.md (описание проекта, инструкции).
 ✅ Загрузка кода в GitHub.

 🎯 Итог:
 🔹 Получится гибкий и удобный консольный текстовый редактор с расширенной функциональностью.
 🔹 Используем основные паттерны ООП, что обеспечит масштабируемость кода.
 🔹 Все функции добавляются поэтапно, упрощая разработку и тестирование.

 Как тебе такой план? 😎🚀
 */
