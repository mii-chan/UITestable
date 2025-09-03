import SwiftSyntax

extension Trivia {
    func spaceCount() -> Int? {
        for piece in pieces {
            if case let .spaces(count) = piece {
                return count
            }
        }
        return nil
    }
}
