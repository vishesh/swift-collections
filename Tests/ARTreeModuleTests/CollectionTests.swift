//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _CollectionsTestSupport
@testable import ARTreeModule

@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
final class ARTreeCollectionProtocolTests: CollectionTestCase {
  func testIndex() throws {
    var t = ARTree<Int>()
    t.insert(key: [1, 2, 3, 4, 5], value: 1)
    t.insert(key: [2, 2, 3, 4, 5], value: 2)
    t.insert(key: [2, 2, 3, 5, 5], value: 3)
    t.insert(key: [1, 2, 3, 5, 6], value: 3)
    let start = t.startIndex
    let end = t.endIndex

    expectEqual((start.current! as! NodeLeaf<DefaultSpec<Int>>).key, [1, 2, 3, 4, 5])
    expectTrue(end.current == nil)
  }

  func testIndexAfter() throws {
    var t1 = ARTree<Int>()
    _ = t1.insert(key: [1, 2, 3, 4, 5], value: 1)
    _ = t1.insert(key: [2, 3, 4, 5, 6], value: 2)
    _ = t1.insert(key: [3, 4, 5, 6, 7], value: 3)
    _ = t1.insert(key: [4, 5, 6, 7, 8], value: 4)
    _ = t1.insert(key: [8, 9, 10, 12, 12], value: 5)
    _ = t1.insert(key: [1, 2, 3, 5, 6], value: 6)
    _ = t1.insert(key: [1, 2, 3, 6, 7], value: 7)
    _ = t1.insert(key: [2, 3, 5, 5, 6], value: 8)
    _ = t1.insert(key: [4, 5, 6, 8, 8], value: 9)
    _ = t1.insert(key: [4, 5, 6, 9, 9], value: 10)
    _ = t1.insert(key: [5, 6, 7], value: 11)
    t1.delete(key: [2, 3, 4, 5, 6])
    let t1_descp = "○ Node16 {childs=6, partial=[]}\n" +
      "├──○ 1: Node4 {childs=3, partial=[2, 3]}\n" +
      "│  ├──○ 4: 5[1, 2, 3, 4, 5] -> 1\n" +
      "│  ├──○ 5: 5[1, 2, 3, 5, 6] -> 6\n" +
      "│  └──○ 6: 5[1, 2, 3, 6, 7] -> 7\n" +
      "├──○ 2: 5[2, 3, 5, 5, 6] -> 8\n" +
      "├──○ 3: 5[3, 4, 5, 6, 7] -> 3\n" +
      "├──○ 4: Node4 {childs=3, partial=[5, 6]}\n" +
      "│  ├──○ 7: 5[4, 5, 6, 7, 8] -> 4\n" +
      "│  ├──○ 8: 5[4, 5, 6, 8, 8] -> 9\n" +
      "│  └──○ 9: 5[4, 5, 6, 9, 9] -> 10\n" +
      "├──○ 5: 3[5, 6, 7] -> 11\n" +
      "└──○ 8: 5[8, 9, 10, 12, 12] -> 5"
    expectEqual(t1.description, t1_descp)

    var idx = t1.startIndex
    while idx != t1.endIndex {
      print(idx.current?.prettyPrint(depth: 0))
      idx = t1.index(after: idx)
    }
  }
}
