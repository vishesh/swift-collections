//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension PersistentSet: Equatable {
  @inlinable
  public static func == (left: Self, right: Self) -> Bool {
    left._root.isEqual(to: right._root, by: { _, _ in true })
  }
}
