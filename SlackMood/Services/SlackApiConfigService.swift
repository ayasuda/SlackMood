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
            if let rootUrl = documentRootUrl() {
                ensureRootUrl(rootUrl)

                let data: NSDictionary = [
                    "channel": config.channel,
                ]
                let path = dataFileUrl(rootUrl)
                data.writeToURL(path, atomically: true)
            }
        }

        func load() -> NSDictionary? {
            if let rootUrl = documentRootUrl() {
                let url = dataFileUrl(rootUrl)
                return NSDictionary(contentsOfURL: url)
            }
            return nil
        }

        private func ensureRootUrl(url: NSURL) {
            let manager = NSFileManager.defaultManager()
            do {
                try manager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("Failed to create directory \(url): \(error)")
            }
        }

        private func documentRootUrl() -> NSURL? {
            let manager = NSFileManager.defaultManager()
            if let baseUrl = try? manager.URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true) {

                return baseUrl.URLByAppendingPathComponent("SlackMood")
            }
            return nil
        }

        private func dataFileUrl(baseUrl: NSURL) -> NSURL {
            return baseUrl.URLByAppendingPathComponent("slack-api.plist")
        }
    }

    class KeychainStore: NSObject {
        private let keychain = Keychain()
        private let key = "slack-api-token"

        func loadApiToken() -> String? {
            if let value = try? keychain.getString(key) {
                return value
            }
            return nil
        }

        func saveApiToken(token: String) {
            do {
                try keychain.set(token, key: key)
            }
            catch {
                print("Failed to save API token in the keychain: \(error)")
            }
        }

        func destroyApiToken() {
            do {
                try keychain.remove(key)
            }
            catch {
                print("Failed to remove API token in the keychain: \(error)")
            }
        }
    }
}
