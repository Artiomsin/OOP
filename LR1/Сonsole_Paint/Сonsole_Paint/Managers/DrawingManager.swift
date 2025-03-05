import Foundation

class DrawingManager {
    var canvas: Canvas
    var shapes: [Shape] = []
    var undoStack: [[Shape]] = []  // Стек для отмены
    var redoStack: [[Shape]] = []  // Стек для повтора
    
    init(canvas: Canvas) {
        self.canvas = canvas
    }
    
    // Сохранение состояния в стек Undo
    func saveStateForUndo() {
        
    }
    
    // Отмена последнего действия
    func undo() {
        
    }
    
    // Повтор последнего отменённого действия
    func redo() {
        
    }
    
    func addShape(_ shape: Shape) {
        
    }
    
    func removeShape(at index: Int) {
        
    }
    
    func isShapeWithinBounds(_ shape: Shape) -> Bool {
        return true
    }
    
    func clearCanvas() {
        
    }
    
    func restoreBorder() {
        
    }
    
    func render() {
        
    }
    
    func moveShape(at index: Int, deltaX: Int, deltaY: Int) {
        
    }
    
    func redrawAllShapes() {
        
    }
    
}
