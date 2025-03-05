// Протокол для фигур
protocol Shape {
    func draw(on canvas: inout Canvas)
    func erase(on canvas: inout Canvas)
    func move(by deltaX: Int, deltaY: Int)
    func copy() -> Shape
    var drawSymbol: Character { get set }
    func fill(on canvas: inout Canvas)
    var fillSymbol: Character? { get set }
    
    
}
