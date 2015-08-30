import Foundation

class SlackApiConfigService: NSObject {
    static let instance = SlackApiConfigService()
    class func sharedService() -> SlackApiConfigService {
        return instance
    }

    private override init() {
    }

    func save(config: SlackApiConfig) {
        if let directory = documentDirectory() {
            ensureDirectory(directory)

            let data: NSDictionary = [
                "channel": config.channel,
                "token": config.token
            ]
            let path = dataFilePath(directory)
            data.writeToFile(path, atomically: true)
        }
    }

    func load() -> SlackApiConfig? {
        if let directory = documentDirectory() {
            let path = dataFilePath(directory)
            if let data = NSDictionary(contentsOfFile: path) {
                return createConfig(data)
            }

        }
        return nil
    }

    private func createConfig(data: NSDictionary) -> SlackApiConfig? {
        return (data.objectForKey("channel") as? String).flatMap { channel in
            (data.objectForKey("token") as? String).flatMap {token in
                SlackApiConfig(channel: channel, token: token)
            }
        }
    }

    private func ensureDirectory(path: String) {
        var error: NSError?

        let manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(path) {
            return
        }

        let success = manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error)
        if !success {
            println("Failed to create directory \(path) : \(error)")
        }
    }

    private func documentDirectory() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, false)

        let root = paths[0] as? String
        return root.map {
            $0.stringByAppendingPathComponent("SlackMood")
        }
    }

    private func dataFilePath(prefix: String) -> String {
        return prefix.stringByAppendingPathComponent("slack-api.plist")
    }

    private func createPropertyList(config: SlackApiConfig) -> NSDictionary {
        return [
            "channel": config.channel,
            "token": config.token
        ]
    }
}