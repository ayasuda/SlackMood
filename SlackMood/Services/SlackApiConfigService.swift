import Foundation
import KeychainAccess

class SlackApiConfigService: NSObject {
    static let instance = SlackApiConfigService()
    class func sharedService() -> SlackApiConfigService {
        return instance
    }

    private override init() {
    }

    func save(config: SlackApiConfig) {
        FileStore().save(config)
        KeychainStore().saveApiToken(config.token)
        notifyUpdate(config)
    }

    func load() -> SlackApiConfig? {
        if let data = FileStore().load() {
            if let token = loadToken() {
                let dic = NSMutableDictionary(dictionary: data)
                dic.setValue(token, forKey: "token")
                return createConfig(dic)
            }
            else {
                return createConfig(data)
            }
        }
        return nil
    }

    func loadToken() -> String? {
        return KeychainStore().loadApiToken()
    }

    private func createConfig(data: NSDictionary) -> SlackApiConfig? {
        return (data.objectForKey("channel") as? String).flatMap { channel in
            (data.objectForKey("token") as? String).flatMap {token in
                SlackApiConfig(channel: channel, token: token)
            }
        }
    }

    private func notifyUpdate(config: SlackApiConfig) {
        let notification = NSNotification(name: "slackmood.apiConfig.updated", object: config)
        notificationCenter().postNotification(notification)
    }

    private func notificationCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }

    class FileStore: NSObject {
        func save(config: SlackApiConfig) {
            if let directory = documentDirectory() {
                ensureDirectory(directory)

                let data: NSDictionary = [
                    "channel": config.channel,
                ]
                let path = dataFilePath(directory)
                data.writeToFile(path, atomically: true)
            }
        }

        func load() -> NSDictionary? {
            if let directory = documentDirectory() {
                let path = dataFilePath(directory)
                return NSDictionary(contentsOfFile: path)
            }
            return nil
        }

        private func ensureDirectory(path: String) {
            var error: NSError?

            let manager = NSFileManager.defaultManager()
            if manager.fileExistsAtPath(path) {
                return
            }

            let success: Bool
            do {
                try manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
                success = true
            } catch let error1 as NSError {
                error = error1
                success = false
            }
            if !success {
                print("Failed to create directory \(path) : \(error)")
            }
        }

        private func documentDirectory() -> String? {
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true)

            let root = paths[0]
            let baseUrl = NSURL.fileURLWithPath(root, isDirectory: true)
            return baseUrl.URLByAppendingPathComponent("SlackMood").path
        }

        private func dataFilePath(prefix: String) -> String {
            let baseUrl = NSURL.fileURLWithPath(prefix, isDirectory: true)
            return baseUrl.URLByAppendingPathComponent("slack-api.plist").path!
        }
    }

    class KeychainStore: NSObject {
        private let keychain = Keychain()
        private let key = "slack-api-token"

        func loadApiToken() -> String? {
            return try! keychain.getString(key)
        }

        func saveApiToken(token: String) {
            try! keychain.set(token, key: key)
        }

        func destroyApiToken() {
            try! keychain.remove(key)
        }
    }
}
