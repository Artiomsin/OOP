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
        let r = radius
        let centerX = x
        let centerY = y
        
        for angle in 0..<360 {
            let radians = Double(angle) * .pi / 180.0
            let dx = Int(round(Double(r) * cos(radians)))
            let dy = Int(round(Double(r) * sin(radians)))
            
            let drawX = centerX + dx
            let drawY = centerY + dy
            
            if drawX >= 0, drawX < canvas.width, drawY >= 0, drawY < canvas.height {
                canvas.pixels[canvas.height - 1 - drawY][drawX] = drawSymbol
            }
        }
    }
    
    func erase(on canvas: inout Canvas) {
        let r = radius
        let centerX = x
        let centerY = y
        
        // Удаление контуров
        for angle in 0..<360 {
            let radians = Double(angle) * .pi / 180.0
            let dx = Int(round(Double(r) * cos(radians)))
            let dy = Int(round(Double(r) * sin(radians)))
            
            let drawX = centerX + dx
            let drawY = centerY + dy
            
            if drawX >= 0, drawX < canvas.width, drawY >= 0, drawY < canvas.height {
                canvas.pixels[canvas.height - 1 - drawY][drawX] = " "
            }
        }
        
        // Удаление заливки, если она существует
        if self.fillSymbol != nil {
            for i in -radius...radius {
                for j in -radius...radius {
                    if i * i + j * j <= radius * radius {
                        let drawX = x + i
                        let drawY = y + j
                        if drawX >= 0, drawX < canvas.width, drawY >= 0, drawY < canvas.height {
                            canvas.pixels[canvas.height - 1 - drawY][drawX] = " "  // Убираем заливку
                        }
                    }
                }
            }
        }
    }
    
    
    func move(by deltaX: Int, deltaY: Int) {
        x += deltaX
        y += deltaY
    }
    
    func copy() -> Shape {
        return Circle(x: self.x,y: self.y, radius: self.radius, drawSymbol: self.drawSymbol,fillSymbol: self.fillSymbol)
        
    }
    
    func fill(on canvas: inout Canvas) {
        // Запрашиваем символ для заливки
        guard let fillSymbol = self.fillSymbol else { return }
        
        // Проходим по всем точкам внутри квадрата, ограниченного радиусом круга
        for i in -radius...radius {
            for j in -radius...radius {
                // Проверяем, что точка внутри круга
                if i * i + j * j <= radius * radius {
                    let drawX = x + i
                    let drawY = y + j
                    if drawX >= 0, drawX < canvas.width, drawY >= 0, drawY < canvas.height {
                        // Заливаем пиксель на холсте
                        canvas.pixels[canvas.height - 1 - drawY][drawX] = fillSymbol
                    }
                }
            }
        }
    }
    
    
}

