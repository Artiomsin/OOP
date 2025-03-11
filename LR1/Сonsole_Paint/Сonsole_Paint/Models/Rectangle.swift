import Foundation

class Rectangle: Shape {
    var x, y, width, height: Int
    var drawSymbol: Character
    var fillSymbol: Character?

    init(x: Int, y: Int, width: Int, height: Int, drawSymbol: Character, fillSymbol: Character?) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.drawSymbol = drawSymbol
        self.fillSymbol = fillSymbol
    }

    // Метод для вычисления пикселей для контура прямоугольника
    func calculatePixelsToDraw() -> [(Int, Int)] {
        var pixelsToDraw: [(Int, Int)] = []

        for i in 0..<height {
            for j in 0..<width {
                let drawX = x + j
                let drawY = y + i
                if (i == 0 || i == height - 1 || j == 0 || j == width - 1) { // Только контур
                    pixelsToDraw.append((drawX, drawY))
                }
            }
        }

        return pixelsToDraw
    }

    // Метод для вычисления пикселей для заливки
    func calculatePixelsToFill() -> [(Int, Int)] {
        var pixelsToFill: [(Int, Int)] = []

        if self.fillSymbol != nil {
            for i in 1..<height-1 {
                for j in 1..<width-1 {
                    let drawX = x + j
                    let drawY = y + i
                    pixelsToFill.append((drawX, drawY))
                }
            }
        }

        return pixelsToFill
    }

    // Метод для вычисления пикселей для удаления (контур и заливка)
    func calculatePixelsForErase() -> [(Int, Int)] {
        var pixelsToErase: [(Int, Int)] = []

        // Очищаем контур прямоугольника
        for i in 0..<height {
            for j in 0..<width {
                let drawX = x + j
                let drawY = y + i
                if (i == 0 || i == height - 1 || j == 0 || j == width - 1) { // Только контур
                    pixelsToErase.append((drawX, drawY))
                }
            }
        }

        // Удаление заливки, если она существует
        if self.fillSymbol != nil {
            for i in 1..<height-1 {
                for j in 1..<width-1 {
                    let drawX = x + j
                    let drawY = y + i
                    pixelsToErase.append((drawX, drawY))
                }
            }
        }

        return pixelsToErase
    }

    func move(by deltaX: Int, deltaY: Int) {
        x += deltaX
        y += deltaY
    }

    func fill() -> [(Int, Int)] {
        guard self.fillSymbol != nil else { return [] }
        return calculatePixelsToFill()
    }

    func copy() -> Shape {
        return Rectangle(x: self.x, y: self.y, width: self.width, height: self.height, drawSymbol: self.drawSymbol, fillSymbol: self.fillSymbol)
    }
}


