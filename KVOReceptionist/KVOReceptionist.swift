class KVOReceptionist<T>: NSObject {
    
    init(keyPath: String, object: AnyObject, queue: dispatch_queue_t = dispatch_get_main_queue(), handler: (oldValue: T?, newValue: T?) -> Void) {
        
        let handleOnMainThread = dispatch_queue_get_label(dispatch_get_main_queue()) == dispatch_queue_get_label(queue)
        
        // closure to parse the KVO response and return the old/new values to the handler
        kvoHandler = { change in
            // locally redefine handler as Void -> Void
            let handler = { handler(oldValue: change?[NSKeyValueChangeOldKey] as? T, newValue: change?[NSKeyValueChangeNewKey] as? T) }
            
            // dispatch handler to the correct queue
            switch (handleOnMainThread, NSThread.isMainThread()) {
            case (true, true):
                handler() // main thread dispatch and already on main thread. call immediately
            case (true, false):
                dispatch_async(queue, handler) // main thread dispatch and not on main thread. dispatch async
            default:
                dispatch_sync(queue, handler) // background thread dispatch. dispatch sync
            }
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
