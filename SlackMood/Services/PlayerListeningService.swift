import Foundation

class PlayerListeningService: NSObject {
    let notificationName = "slackmood.startPlaying"
    let listeningNotificationName = "com.apple.iTunes.playerInfo"

    static let instance = PlayerListeningService()
    class func sharedService() -> PlayerListeningService {
        return instance
    }

    var running: Bool = false

    private override init() {
    }

    func start() {
        running = true
        notificationCenter().addObserver(self, selector: "update:", name: listeningNotificationName, object: nil)
        notifyStateChanged()
    }

    func stop() {
        running = false
        notificationCenter().removeObserver(self, name: listeningNotificationName, object: nil)
        notifyStateChanged()
    }

    func isRunning() -> Bool {
        return running
    }

    private func notificationCenter() -> NSNotificationCenter {
        return NSDistributedNotificationCenter.defaultCenter()
    }

    private func notifyStateChanged() {
        let notification = NSNotification(name: "slackmood.playerListeningService.stateChanged", object: self)
        let center = NSNotificationCenter.defaultCenter()
        center.postNotification(notification)
    }

    func update(notification: NSNotification?) {
        if let userInfo = notification?.userInfo! {
            if !interesting(userInfo) {
                return
            }

            notifyPlaying(userInfo)
        }
    }

    private func interesting(userInfo: [NSObject : AnyObject]) -> Bool {
        if let state = userInfo["Player State"] as? String! {
            return state == "Playing"
        }
        return false
    }

    private func notifyPlaying(userInfo: [NSObject : AnyObject]) {
        let playingItem = createPlayingItem(userInfo)
        let playingNotification = NSNotification(name: notificationName, object: playingItem)
        NSNotificationCenter.defaultCenter().postNotification(playingNotification)
    }

    private func createPlayingItem(userInfo: [NSObject : AnyObject]) -> PlayingItem {
        let name   = userInfo["Name"] as? String
        let artist = userInfo["Artist"] as? String
        let album  = userInfo["Album"] as? String
        return PlayingItem(name: name, artist: artist, album: album)
    }
}
