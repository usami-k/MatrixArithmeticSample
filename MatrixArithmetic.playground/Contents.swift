// Matrix Arithmetic

// ==============================
// Define Matrix
// ==============================

protocol MatrixProtocol {
    associatedtype Scalar: Numeric
    var rows: Int { get }
    var columns: Int { get }
    subscript(row: Int, column: Int) -> Scalar { get set }
    func vector(row: Int) -> [Scalar]
    func vector(column: Int) -> [Scalar]
}

struct Matrix : MatrixProtocol {
    typealias Scalar = Float
    let rows: Int
    let columns: Int
    private var grid: [Scalar]

    init(rows: Int, columns: Int, grid: [Scalar]) {
        assert(grid.count == rows * columns, "Mismatch size")
        self.rows = rows
        self.columns = columns
        self.grid = grid
    }

    init(elements: [[Scalar]]) {
        let rows = elements.count
        let columns = elements.first?.count ?? 0
        let grid = elements.flatMap { $0 }
        self.init(rows: rows, columns: columns, grid: grid)
    }

    subscript(row: Int, column: Int) -> Scalar {
        get {
            assert(0 <= row && row < rows && 0 <= column && column < columns, "Invalid index")
            return grid[row * columns + column]
        }
        set {
            assert(0 <= row && row < rows && 0 <= column && column < columns, "Invalid index")
            grid[row * columns + column] = newValue
        }
    }

    func vector(row: Int) -> [Scalar] {
        return (0..<columns).map { self[row, $0] }
    }

    func vector(column: Int) -> [Scalar] {
        return (0..<rows).map { self[$0, column] }
    }
}

extension Matrix : CustomStringConvertible {
    var description: String { return (0..<rows).map({ vector(row: $0).description }).joined() }
}

extension Matrix : AdditiveArithmetic {
    static var zero = Matrix(rows: 0, columns: 0, grid: [])

    static func + (lhs: Matrix, rhs: Matrix) -> Matrix {
        assert(lhs.rows == rhs.rows && lhs.columns == rhs.columns, "Mismatch size")
        return Matrix(rows: lhs.rows, columns: lhs.columns, grid: zip(lhs.grid, rhs.grid).map(+))
    }

    static func - (lhs: Matrix, rhs: Matrix) -> Matrix {
        assert(lhs.rows == rhs.rows && lhs.columns == rhs.columns, "Mismatch size")
        return Matrix(rows: lhs.rows, columns: lhs.columns, grid: zip(lhs.grid, rhs.grid).map(-))
    }

    static func += (lhs: inout Matrix, rhs: Matrix) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Matrix, rhs: Matrix) {
        lhs = lhs - rhs
    }
}

protocol VectorNumeric {
    associatedtype Scalar: Numeric
    static func * (lhs: Scalar, rhs: Self) -> Self
    static func *= (lhs: inout Self, rhs: Scalar)
}

extension Matrix : VectorNumeric {
    static func * (lhs: Scalar, rhs: Matrix) -> Matrix {
        return Matrix(rows: rhs.rows, columns: rhs.columns, grid: rhs.grid.map { lhs * $0 })
    }

    static func *= (lhs: inout Matrix, rhs: Scalar) {
        lhs = rhs * lhs
    }
}

protocol MultiplicativeArithmetic {
    static func * (lhs: Self, rhs: Self) -> Self
    static func *= (lhs: inout Self, rhs: Self)
}

extension Matrix : MultiplicativeArithmetic {
    static func * (lhs: Matrix, rhs: Matrix) -> Matrix {
        assert(lhs.rows == rhs.columns, "Mismatch size")
        return Matrix(rows: lhs.rows, columns: rhs.columns, grid: (0..<lhs.rows).flatMap { row in
            (0..<rhs.columns).map { column in
                zip(lhs.vector(row: row), rhs.vector(column: column)).map(*).reduce(0, +)
            }
        })
    }

    static func *= (lhs: inout Matrix, rhs: Matrix) {
        lhs = lhs * rhs
    }
}

// ==============================
// Use Matrix
// ==============================

let a = Matrix(elements: [[1, 2], [3, 4]])
let b = Matrix(elements: [[5, 6], [7, 8]])

a + b
a - b
3 * a
a * b
