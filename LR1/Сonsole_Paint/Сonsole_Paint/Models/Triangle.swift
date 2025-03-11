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

    // Метод для вычисления пикселей для контура треугольника
    func calculatePixelsToDraw() -> [(Int, Int)] {
        var pixelsToDraw: [(Int, Int)] = []
        drawLine(x1, y1, x2, y2, &pixelsToDraw)
        drawLine(x2, y2, x3, y3, &pixelsToDraw)
        drawLine(x3, y3, x1, y1, &pixelsToDraw)
        return pixelsToDraw
    }

    // Метод для вычисления пикселей для заливки треугольника
    func calculatePixelsToFill() -> [(Int, Int)] {
        var pixelsToFill: [(Int, Int)] = []
        if self.fillSymbol != nil {
            let minY = min(y1, y2, y3), maxY = max(y1, y2, y3)

            for y in minY...maxY {
                var intersections: [Int] = []
                checkIntersection(x1, y1, x2, y2, y, &intersections)
                checkIntersection(x2, y2, x3, y3, y, &intersections)
                checkIntersection(x3, y3, x1, y1, y, &intersections)

                intersections.sort()

                for i in stride(from: 0, to: intersections.count, by: 2) {
                    if i + 1 < intersections.count {
                        for x in intersections[i]...intersections[i + 1] {
                            pixelsToFill.append((x, y))
                        }
                    }
                }
            }
        }
        return pixelsToFill
    }

    // Метод для вычисления пикселей для удаления
    func calculatePixelsForErase() -> [(Int, Int)] {
        var pixelsToErase: [(Int, Int)] = []
        eraseLine(x1, y1, x2, y2, &pixelsToErase)
        eraseLine(x2, y2, x3, y3, &pixelsToErase)
        eraseLine(x3, y3, x1, y1, &pixelsToErase)
        return pixelsToErase
    }

    private func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, _ pixelsToDraw: inout [(Int, Int)]) {
        var x = x1, y = y1
        let dx = abs(x2 - x1), dy = abs(y2 - y1)
        let sx = x1 < x2 ? 1 : -1, sy = y1 < y2 ? 1 : -1
        var err = dx - dy

        while true {
            pixelsToDraw.append((x, y))
            if x == x2 && y == y2 { break }
            let e2 = err * 2
            if e2 > -dy { err -= dy; x += sx }
            if e2 < dx { err += dx; y += sy }
        }
    }

    private func eraseLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, _ pixelsToErase: inout [(Int, Int)]) {
        var x = x1, y = y1
        let dx = abs(x2 - x1), dy = abs(y2 - y1)
        let sx = x1 < x2 ? 1 : -1, sy = y1 < y2 ? 1 : -1
        var err = dx - dy

        while true {
            pixelsToErase.append((x, y))
            if x == x2 && y == y2 { break }
            let e2 = err * 2
            if e2 > -dy { err -= dy; x += sx }
            if e2 < dx { err += dx; y += sy }
        }
    }

    func move(by deltaX: Int, deltaY: Int) {
        x1 += deltaX
        y1 += deltaY
        x2 += deltaX
        y2 += deltaY
        x3 += deltaX
        y3 += deltaY
    }

    func copy() -> Shape {
        return Triangle(x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3, drawSymbol: drawSymbol, fillSymbol: fillSymbol)
    }

    private func checkIntersection(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, _ y: Int, _ intersections: inout [Int]) {
        if (y1 <= y && y2 > y) || (y2 <= y && y1 > y) {
            let x = x1 + (y - y1) * (x2 - x1) / (y2 - y1)
            intersections.append(x)
        }
    }
}


