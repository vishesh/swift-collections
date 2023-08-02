import XCTest

@testable import ARTreeModule

final class ARTreeNode48Tests: XCTestCase {
  func test48Basic() throws {
    var node = Node48.allocate()
    node.addChild(forKey: 10, node: NodeLeaf.allocate(key: [10], value: [1]))
    node.addChild(forKey: 20, node: NodeLeaf.allocate(key: [20], value: [2]))
    XCTAssertEqual(
      node.print(value: [UInt8].self),
      "○ Node48 {childs=2, partial=[]}\n" + "├──○ 10: 1[10] -> [1]\n" + "└──○ 20: 1[20] -> [2]")
  }

  func test48DeleteAtIndex() throws {
    var node = Node48.allocate()
    node.addChild(forKey: 10, node: NodeLeaf.allocate(key: [10], value: [1]))
    node.addChild(forKey: 15, node: NodeLeaf.allocate(key: [15], value: [2]))
    node.addChild(forKey: 20, node: NodeLeaf.allocate(key: [20], value: [3]))
    XCTAssertEqual(
      node.print(value: [UInt8].self),
      "○ Node48 {childs=3, partial=[]}\n" + "├──○ 10: 1[10] -> [1]\n" + "├──○ 15: 1[15] -> [2]\n"
        + "└──○ 20: 1[20] -> [3]")
    node.deleteChild(at: 10)
    XCTAssertEqual(
      node.print(value: [UInt8].self),
      "○ Node48 {childs=2, partial=[]}\n" + "├──○ 15: 1[15] -> [2]\n" + "└──○ 20: 1[20] -> [3]")
    node.deleteChild(at: 15)
    XCTAssertEqual(
      node.print(value: [UInt8].self),
      "○ Node48 {childs=1, partial=[]}\n" + "└──○ 20: 1[20] -> [3]")
    node.deleteChild(at: 20)
    XCTAssertEqual(node.print(value: [UInt8].self), "○ Node48 {childs=0, partial=[]}\n")
  }
}
