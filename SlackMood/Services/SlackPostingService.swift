import Foundation

class SlackPostingService: NSObject {
    static let instance = SlackPostingService()
    class func sharedService() -> SlackPostingService {
        return instance
    }

    private override init() {
    }

    func start() {
        notificationCenter().addObserver(self, selector: "update:", name: "slackmood.startPlaying", object: nil)
    }

    func stop() {
        notificationCenter().removeObserver(self, name: "slackmood.startPlaying", object: nil)
    }

    func update(notification: NSNotification?) {
        if let item = notification?.object! as? PlayingItem {
            post(item)
        }
    }

    private func notificationCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }

    private func post(item: PlayingItem) {
        if let config = SlackApiConfigService.sharedService().load() {
            println("Posting item to #\(config.channel)")
        }
        println("Listing \(item.name!) by \(item.artist!)")
    }
}
