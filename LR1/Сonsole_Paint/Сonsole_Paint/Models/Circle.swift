import Foundation
class Circle: Shape {
    var x, y, radius: Int
    var drawSymbol: Character
    var fillSymbol: Character?

    init(x: Int, y: Int, radius: Int, drawSymbol: Character, fillSymbol: Character?) {
        self.x = x
        self.y = y
        self.radius = radius
        self.drawSymbol = drawSymbol
        self.fillSymbol = fillSymbol
    }

    // Метод для вычисления пикселей для контура круга
    func calculatePixelsToDraw() -> [(Int, Int)] {
        var pixelsToDraw: [(Int, Int)] = []
        let r = radius
        let centerX = x
        let centerY = y

        for angle in 0..<360 {
            let radians = Double(angle) * .pi / 180.0
            let dx = Int(round(Double(r) * cos(radians)))
            let dy = Int(round(Double(r) * sin(radians)))

            let drawX = centerX + dx
            let drawY = centerY + dy

            pixelsToDraw.append((drawX, drawY))
        }

        return pixelsToDraw
    }

    // Метод для вычисления пикселей для заливки круга
    func calculatePixelsToFill() -> [(Int, Int)] {
        var pixelsToFill: [(Int, Int)] = []

        if self.fillSymbol != nil {
            for i in -radius...radius {
                for j in -radius...radius {
                    if i * i + j * j <= radius * radius {
                        let drawX = x + i
                        let drawY = y + j
                        pixelsToFill.append((drawX, drawY))
                    }
                }
            }
        }

        return pixelsToFill
    }

    // Метод для вычисления пикселей для удаления
    func calculatePixelsForErase() -> [(Int, Int)] {
        var pixelsToErase: [(Int, Int)] = []

        // Удаление контура
        let r = radius
        let centerX = x
        let centerY = y

        for angle in 0..<360 {
            let radians = Double(angle) * .pi / 180.0
            let dx = Int(round(Double(r) * cos(radians)))
            let dy = Int(round(Double(r) * sin(radians)))

            let drawX = centerX + dx
            let drawY = centerY + dy

            pixelsToErase.append((drawX, drawY))
        }

        // Удаление заливки, если она существует
        if self.fillSymbol != nil {
            for i in -radius...radius {
                for j in -radius...radius {
                    if i * i + j * j <= radius * radius {
                        let drawX = x + i
                        let drawY = y + j
                        pixelsToErase.append((drawX, drawY))
                    }
                }
            }
        }

        return pixelsToErase
    }

    func move(by deltaX: Int, deltaY: Int) {
        x += deltaX
        y += deltaY
    }

    func copy() -> Shape {
        return Circle(x: self.x, y: self.y, radius: self.radius, drawSymbol: self.drawSymbol, fillSymbol: self.fillSymbol)
    }
}


