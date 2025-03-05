class Canvas {
    var width: Int
    var height: Int
    var pixels: [[Character]]
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.pixels = Array(repeating: Array(repeating: " ", count: width), count: height)
    }
    
    // Очистка холста
    func clear() {
        self.pixels = Array(repeating: Array(repeating: " ", count: width), count: height)
    }
    
    // Вывод холста в консоль
    func render() {
        for row in pixels {
            print(String(row))
        }
    }
}

