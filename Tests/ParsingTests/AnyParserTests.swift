import CustomDump
import Parsing
import XCTest

final class AnyParserTests: XCTestCase {
  func testClosureInitializer() {
    struct CustomError: Equatable, Error {}

    let parser = AnyParser<Substring, Void> { input in
      guard input.starts(with: "Hello") else {
        throw CustomError()
      }
      input.removeFirst(5)
    }

    var input = "Hello, world!"[...]
    XCTAssertNoThrow(try parser.parse(&input))
    XCTAssertNoDifference(", world!", input)

    XCTAssertThrowsError(try parser.parse(&input)) { error in
      XCTAssertNoDifference(error as? CustomError, CustomError())
    }
    XCTAssertNoDifference(", world!", input)
  }

  func testParserInitializer() {
    let parser = AnyParser("Hello")

    var input = "Hello, world!"[...]
    XCTAssertNoThrow(try parser.parse(&input))
    XCTAssertNoDifference(", world!", input)

    XCTAssertThrowsError(try parser.parse(&input)) { error in
      XCTAssertNoDifference(
        """
        error: unexpected input
         --> input:1:6
        1 | Hello, world!
          |      ^ expected "Hello"
        """,
        "\(error)"
      )
    }
    XCTAssertNoDifference(", world!", input)
  }

  func testParserEraseToAnyParser() {
    let parser = "Hello".eraseToAnyParser()

    var input = "Hello, world!"[...]
    XCTAssertNoThrow(try parser.parse(&input))
    XCTAssertNoDifference(", world!", input)

    XCTAssertThrowsError(try parser.parse(&input)) { error in
      XCTAssertNoDifference(
        """
        error: unexpected input
         --> input:1:6
        1 | Hello, world!
          |      ^ expected "Hello"
        """,
        "\(error)"
      )
    }
    XCTAssertNoDifference(", world!", input)
  }

  func testAnyParserEraseToAnyParser() {
    let parser = "Hello".eraseToAnyParser().eraseToAnyParser()

    var input = "Hello, world!"[...]
    XCTAssertNoThrow(try parser.parse(&input))
    XCTAssertNoDifference(", world!", input)

    XCTAssertThrowsError(try parser.parse(&input)) { error in
      XCTAssertNoDifference(
        """
        error: unexpected input
         --> input:1:6
        1 | Hello, world!
          |      ^ expected "Hello"
        """,
        "\(error)"
      )
    }
    XCTAssertNoDifference(", world!", input)
  }
}
