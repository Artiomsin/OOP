class Triangle: Shape {
    var fillSymbol: Character?
    var x1, y1, x2, y2, x3, y3: Int
    var drawSymbol: Character
    
    init(x1: Int, y1: Int, x2: Int, y2: Int, x3: Int, y3: Int, drawSymbol: Character, fillSymbol: Character?) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.x3 = x3
        self.y3 = y3
        self.drawSymbol = drawSymbol
        self.fillSymbol = fillSymbol
    }
    
    func draw(on canvas: inout Canvas) {
        
    }
    
    func erase(on canvas: inout Canvas) {
        
    }
    
    private func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, on canvas: inout Canvas) {
        
    }
    
    private func eraseLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, on canvas: inout Canvas) {
        
    }
    
    func move(by deltaX: Int, deltaY: Int) {
        
    }
    
    func copy() -> Shape {
        return Triangle(x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3, drawSymbol: drawSymbol, fillSymbol: fillSymbol)
    }
    
    func fill(on canvas: inout Canvas) {
        
    }
    
    private func checkIntersection(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, _ y: Int, _ intersections: inout [Int]) {
        
    }
}

