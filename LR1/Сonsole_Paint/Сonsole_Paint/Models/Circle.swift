import Foundation
class Circle: Shape {
    var x, y, radius: Int
    var drawSymbol: Character
    var fillSymbol: Character?
    init(x: Int, y: Int, radius: Int,drawSymbol: Character,fillSymbol: Character? ) {
        self.x = x
        self.y = y
        self.radius = radius
        self.drawSymbol = drawSymbol
        self.fillSymbol = fillSymbol
    }
    
    func draw(on canvas: inout Canvas) {
        
    }
    
    func erase(on canvas: inout Canvas) {
        
    }
    
    
    func move(by deltaX: Int, deltaY: Int) {
        
    }
    
    func copy() -> Shape {
        return Circle(x: self.x,y: self.y, radius: self.radius, drawSymbol: self.drawSymbol,fillSymbol: self.fillSymbol)
        
    }
    
    func fill(on canvas: inout Canvas) {
        
    }
}
