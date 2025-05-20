import XCTest
import SwiftTreeSitter
import TreeSitterCcs

final class TreeSitterCcsTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_ccs())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading CCS grammar")
    }
}
