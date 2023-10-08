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
}
