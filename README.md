# KVOReceptionist
Simple KVO for Objective-C objects in Swift

# Example Usage
```
class Example {
    func startListening() {
        receptionist = KVOReceptionist(keyPath: "operationCount", object: queue, handler: { oldValue, newValue in
            print( (newValue > oldValue ? "added" : "removed") + " an operation. new count: \(newValue!)")
        })
    }
    
    func stopListening() {
        receptionist = nil
    }
    
    func addOperation() {
        queue.addOperationWithBlock({
            print("running block")
        })
    }
    
    private let queue = NSOperationQueue()
    private var receptionist: KVOReceptionist<Int>?
}

// added an operation. new count: 1
// running block
// removed an operation. new count: 0
```

