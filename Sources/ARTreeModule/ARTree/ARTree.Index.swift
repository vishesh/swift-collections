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

// Assumes if root is not-nil, it must have kv pairs.
@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
extension ARTreeImpl {
  public struct Index {
    internal typealias _ChildIndex = InternalNode<Spec>.Index

    internal weak var root: RawNodeBuffer? = nil
    internal var current: (any ArtNode<Spec>)? = nil
    internal var path: [(any InternalNode<Spec>, _ChildIndex)] = []
    internal let version: Int

    // Initializes to minimum key index, which may not actually exist.
    internal init(forTree tree: ARTreeImpl<Spec>, endIndex: Bool = false) {
      self.version = tree.version

      if let root = tree._root {
        assert(root.type != .leaf, "root can't be leaf")
        self.root = tree._root?.buf
        if endIndex {
          return
        }
        self.current = tree._root?.toArtNode()
      }
    }
  }
}

@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
extension ARTreeImpl.Index {
  internal var isAtBottom: Bool {
    guard let currentNode = self.current else {
      return false
    }

    if currentNode.type == .leaf {
      return true
    }

    let node: any InternalNode<Spec> = currentNode.rawNode.toInternalNode()
    return node.count == 0
  }

  internal mutating func descentToLeftMostChild() {
    while !isAtBottom {
      descend { $0.startIndex }
    }
  }

  internal mutating func descend(_ to: (any InternalNode<Spec>)
                                   -> (any InternalNode<Spec>).Index) {
    assert(!isAtBottom, "can't descent from a bottom node")
    assert(current != nil, "current node can't be nil")

    let currentNode: any InternalNode<Spec> = current!.rawNode.toInternalNode()
    let index = to(currentNode)
    self.path.append((currentNode, index))
    self.current = currentNode.child(at: index)?.toArtNode()
  }

  mutating func advanceToNext() {
    while !path.isEmpty {
      let (node, index) = path.popLast()!
      let next = node.index(after: index)

      if next == node.endIndex {
        continue
      }

      path.append((node, next))
      guard let nextNode = node.child(at: next) else {
        assert(false, "should have a child")
      }

      if nextNode.type == .leaf {
        return
      }

      descentToLeftMostChild()
    }

    self.current = nil
  }
}


@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
extension ARTreeImpl.Index: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    if case (let lhs?, let rhs?) = (lhs.current, rhs.current) {
      return lhs.equals(rhs)
    }

    return false
  }
}

@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
extension ARTreeImpl.Index: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    for ((_, idxL), (_, idxR)) in zip(lhs.path, rhs.path) {
      if idxL < idxR {
        return true
      } else if idxL > idxR {
        return false
      }
    }

    return false
  }
}
