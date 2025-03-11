// Протокол для фигур
protocol Shape: AnyObject {
    var drawSymbol: Character { get }
    var fillSymbol: Character? { get }
    
    func move(by deltaX: Int, deltaY: Int)
    func copy() -> Shape
    func calculatePixelsToDraw() -> [(Int, Int)]
    func calculatePixelsToFill() -> [(Int, Int)]
    func calculatePixelsForErase() -> [(Int, Int)]
}


