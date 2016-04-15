class KVOReceptionist<T>: NSObject {
    
    init(keyPath: String, object: AnyObject, handler: (oldValue: T?, newValue: T?) -> Void) {
        // closure to parse the KVO response and return the old/new values to the handler
        kvoHandler = { change in
            handler(oldValue: change?[NSKeyValueChangeOldKey] as? T, newValue: change?[NSKeyValueChangeNewKey] as? T)
        }
        
        // closure to remove KVO observer during deinit
        cleanupHandler = { [weak object] strongSelf in
            object?.removeObserver(strongSelf, forKeyPath: keyPath)
        }
        
        // finish initialization and add the KVO observer
        super.init()
        object.addObserver(self, forKeyPath: keyPath, options: [.New, .Old], context: nil)
    }
    
    deinit {
        cleanupHandler(self)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        kvoHandler(change)
    }
    
    // internal handlers
    private let kvoHandler: [String : AnyObject]? -> Void
    private let cleanupHandler: KVOReceptionist -> Void
}
