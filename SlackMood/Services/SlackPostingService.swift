import Foundation
import Alamofire

class SlackPostingService: NSObject {
    let postingUri = "https://slack.com/api/chat.postMessage"

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
            let message = createMessage(item)
            println(message)

            let channel = "#\(config.channel)"
            let params: [String: AnyObject] = [
                "channel": channel,
                "token": config.token,
                "as_user": true,
                "text" : message
            ]

            Alamofire
                .request(.POST, postingUri, parameters: params, encoding: ParameterEncoding.URL, headers: nil)
                .response { (request, response, data, error) -> Void in
                    println(response)
            }

        }
    }

    private func createMessage(item: PlayingItem) -> String {
        let unknown = "(unknown)"

        let name = escape(item.name) ?? unknown
        let artist = escape(item.artist) ?? unknown
        let album = escape(item.album) ?? unknown
        if let url = item.url {
            return "Now Playing: *\(name)* by *\(artist)* from :cd: <\(url)|\(album)>"
        }
        else {
            return "Now Playing: *\(name)* by *\(artist)* from :cd: *\(album)*"
        }
    }

    private func escape(str: String?) -> String? {
        if let s = str {
            return s.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
                .stringByReplacingOccurrencesOfString("<", withString: "&lt;")
                .stringByReplacingOccurrencesOfString(">", withString: "&gt;")
        }
        return str
    }
}
