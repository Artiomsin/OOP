import Foundation

class DrawingManager {
    var canvas: Canvas
    var shapes: [Shape] = []
    var undoStack: [[Shape]] = []  // Стек для отмены
    var redoStack: [[Shape]] = []  // Стек для повтора
    
    init(canvas: Canvas) {
        self.canvas = canvas
    }
    
}
