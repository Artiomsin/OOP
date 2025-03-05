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
        for i in 0..<height {
            for j in 0..<width {
                let drawX = x + j
                let drawY = y + i
                if (i == 0 || i == height - 1 || j == 0 || j == width - 1) {
                    if drawX >= 0, drawX < canvas.width, drawY >= 0, drawY < canvas.height {
                        canvas.pixels[canvas.height - 1 - drawY][drawX] = drawSymbol
                    }
                }
            }
        }
    }
    
    func erase(on canvas: inout Canvas) {
        
        // Очищаем контур прямоугольника
        for i in 0..<height {
            for j in 0..<width {
                let drawX = x + j
                let drawY = y + i
                if (i == 0 || i == height - 1 || j == 0 || j == width - 1) { // Только контур
                    if drawX >= 0, drawX < canvas.width, drawY >= 0, drawY < canvas.height {
                        canvas.pixels[canvas.height - 1 - drawY][drawX] = " " // Убираем символ
                    }
                }
            }
        }
        
        // Удаление заливки, если она существует
        if self.fillSymbol != nil {
            for i in 1..<height-1 {
                for j in 1..<width-1 {
                    let drawX = x + j
                    let drawY = y + i
                    if drawX >= 0, drawX < canvas.width, drawY >= 0, drawY < canvas.height {
                        canvas.pixels[canvas.height - 1 - drawY][drawX] = " "  // Убираем заливку
                    }
                }
            }
        }
    }
    
    
    func move(by deltaX: Int, deltaY: Int) {
        x += deltaX
        y += deltaY
    }
    
    func fill(on canvas: inout Canvas) {
        guard let fillSymbol = self.fillSymbol else { return }
        for i in 1..<height-1 {
            for j in 1..<width-1 {
                let drawX = x + j
                let drawY = y + i
                if drawX >= 0, drawX < canvas.width, drawY >= 0, drawY < canvas.height {
                    canvas.pixels[canvas.height - 1 - drawY][drawX] = fillSymbol
                }
            }
        }
        
    }
    
    func copy() -> Shape {
        return Rectangle(x: self.x, y: self.y, width: self.width, height: self.height, drawSymbol: self.drawSymbol,fillSymbol: self.fillSymbol)
    }
}
