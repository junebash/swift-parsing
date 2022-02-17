import CustomDump
import Parsing
import XCTest

final class OneOfBuilderTests: XCTestCase {
  func testBuildArray() {
    enum Role: String, CaseIterable, Equatable {
      case admin
      case guest
      case member
    }

    let parser = OneOf {
      for role in Role.allCases {
        role.rawValue.map { role }
      }
    }

    for role in Role.allCases {
      XCTAssertNoDifference(role, try parser.parse(role.rawValue))
    }
    XCTAssertThrowsError(try parser.parse("president")) { error in
      XCTAssertNoDifference(
        """
        error: unexpected input
         --> input:1:1
        1 | president
          | ^ expected "admin"
          | ^ expected "guest"
          | ^ expected "member"
        """,
        "\(error)"
      )
    }
  }

  func testBuildIf() {
    enum Role {
      case admin
      case guest
      case member
    }

    var parseAdmins = false
    var parser = OneOf {
      if parseAdmins {
        "admin".map { Role.admin }
      }

      "guest".map { Role.guest }
      "member".map { Role.member }
    }

    XCTAssertNoDifference(.guest, try parser.parse("guest"))
    XCTAssertThrowsError(try parser.parse("admin")) { error in
      XCTAssertNoDifference(
        """
        error: unexpected input
         --> input:1:1
        1 | admin
          | ^ expected "guest"
          | ^ expected "member"
        """,
        "\(error)"
      )
    }

    parseAdmins = true
    parser = OneOf {
      if parseAdmins {
        "admin".map { Role.admin }
      }

      "guest".map { Role.guest }
      "member".map { Role.member }
    }
    XCTAssertNoDifference(.guest, try parser.parse("guest"))
    XCTAssertNoDifference(.admin, try parser.parse("admin"))
    XCTAssertThrowsError(try parser.parse("president")) { error in
      XCTAssertNoDifference(
        """
        error: unexpected input
         --> input:1:1
        1 | president
          | ^ expected "admin"
          | ^ expected "guest"
          | ^ expected "member"
        """,
        "\(error)"
      )
    }
  }
}
