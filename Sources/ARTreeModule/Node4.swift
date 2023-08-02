struct Node4 {
  static let numKeys: Int = 4

  var pointer: NodePtr
  var keys: UnsafeMutableBufferPointer<KeyPart>
  var childs: UnsafeMutableBufferPointer<NodePtr?>

  init(ptr: NodePtr) {
    self.pointer = ptr
    let body = ptr + MemoryLayout<NodeHeader>.stride
    self.keys = UnsafeMutableBufferPointer(
      start: body.assumingMemoryBound(to: KeyPart.self),
      count: Self.numKeys
    )

    let childPtr = (body + Self.numKeys * MemoryLayout<KeyPart>.stride)
      .assumingMemoryBound(to: NodePtr?.self)
    self.childs = UnsafeMutableBufferPointer(start: childPtr, count: 4)
  }
}

extension Node4 {
  static func allocate() -> Self {
    let buf = NodeBuffer.allocate(type: .node4, size: size)
    return Self(ptr: buf)
  }

  static func allocate(copyFrom: Node16) -> Self {
    var node = Self.allocate()
    node.copyHeader(from: copyFrom)
    UnsafeMutableRawBufferPointer(node.keys).copyBytes(
      from: UnsafeBufferPointer(rebasing: copyFrom.keys[0..<numKeys]))
    UnsafeMutableRawBufferPointer(node.childs).copyBytes(
      from: UnsafeRawBufferPointer(
        UnsafeBufferPointer(rebasing: copyFrom.childs[0..<numKeys])))
    return node
  }

  static var size: Int {
    MemoryLayout<NodeHeader>.stride + Self.numKeys
      * (MemoryLayout<KeyPart>.stride + MemoryLayout<NodePtr>.stride)
  }
}

extension Node4: Node {
  func type() -> NodeType { .node4 }

  func index(forKey k: KeyPart) -> Index? {
    for (index, key) in keys.enumerated() {
      if key == k {
        return index
      }
    }

    return nil
  }

  func index() -> Index? {
    return 0
  }

  func next(index: Index) -> Index? {
    let next = index + 1
    return next < count ? next : nil
  }

  func _insertSlot(forKey k: KeyPart) -> Int? {
    if count >= Self.numKeys {
      return nil
    }

    for idx in 0..<count {
      if keys[idx] >= Int(k) {
        return idx
      }
    }

    return count
  }

  func child(forKey k: KeyPart, ref: inout ChildSlotPtr?) -> NodePtr? {
    guard let index = index(forKey: k) else {
      return nil
    }

    ref = childs.baseAddress! + index
    return child(at: index)
  }

  func child(at: Index) -> NodePtr? {
    assert(at < Self.numKeys, "maximum \(Self.numKeys) childs allowed, given index = \(at)")
    return childs[at]
  }

  func child(at index: Index, ref: inout ChildSlotPtr?) -> NodePtr? {
    assert(
      index < Self.numKeys,
      "maximum \(Self.numKeys) childs allowed, given index = \(index)")
    ref = childs.baseAddress! + index
    return childs[index]
  }

  mutating func addChild(
    forKey k: KeyPart,
    node: NodePtr,
    ref: ChildSlotPtr?
  ) {
    if let slot = _insertSlot(forKey: k) {
      assert(count == 0 || keys[slot] != k, "node for key \(k) already exists")
      keys.shiftRight(startIndex: slot, endIndex: count - 1, by: 1)
      childs.shiftRight(startIndex: slot, endIndex: count - 1, by: 1)
      keys[slot] = k
      childs[slot] = node
      count += 1
    } else {
      var newNode = Node16.allocate(copyFrom: self)
      newNode.addChild(forKey: k, node: node)
      ref?.pointee = newNode.pointer
      pointer.deallocate()
    }
  }

  mutating func deleteChild(at index: Index, ref: ChildSlotPtr?) {
    assert(index < 4, "index can't >= 4 in Node4")
    assert(index < count, "not enough childs in node")

    let childBuf = child(at: index)
    childBuf?.deallocate()

    keys[self.count] = 0
    childs[self.count] = nil

    count -= 1
    keys.shiftLeft(startIndex: index + 1, endIndex: count, by: 1)
    childs.shiftLeft(startIndex: index + 1, endIndex: count, by: 1)

    if count == 1 {
      // Shrink to leaf node.
      ref?.pointee = childs[0]
      pointer.deallocate()
    }
  }
}
