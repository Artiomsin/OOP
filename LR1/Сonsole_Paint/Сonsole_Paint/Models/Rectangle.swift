class Rectangle: Shape {
    var x, y, width, height: Int
    var drawSymbol: Character
    var fillSymbol: Character?
    init(x: Int, y: Int, width: Int, height: Int,drawSymbol: Character,fillSymbol: Character?) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.drawSymbol = drawSymbol
        self.fillSymbol=fillSymbol
    }
    func draw(on canvas: inout Canvas) {
        
    }
    
    func erase(on canvas: inout Canvas) {
        
        
    }
    
    
    func move(by deltaX: Int, deltaY: Int) {
        
    }
    
    func fill(on canvas: inout Canvas) {
        
        
    }
    
    func copy() -> Shape {
        return Rectangle(x: self.x, y: self.y, width: self.width, height: self.height, drawSymbol: self.drawSymbol,fillSymbol: self.fillSymbol)
    }
}
