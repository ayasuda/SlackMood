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

            let success = manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error)
            if !success {
                println("Failed to create directory \(path) : \(error)")
            }
        }

        private func documentDirectory() -> String? {
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, false)

            let root = paths[0] as? String
            return root.map {
                $0.stringByAppendingPathComponent("SlackMood").stringByExpandingTildeInPath
            }
        }

        private func dataFilePath(prefix: String) -> String {
            return prefix.stringByAppendingPathComponent("slack-api.plist")
        }
    }

    class KeychainStore: NSObject {
        private let keychain = Keychain()
        private let key = "slack-api-token"

        func loadApiToken() -> String? {
            let failable = keychain.getStringOrError(key)
            switch failable {
            case .Success:
                return failable.value
            case .Failure:
                println(failable.error)
                return nil
            }
        }

        func saveApiToken(token: String) {
            keychain.set(token, key: key)
        }

        func destroyApiToken() {
            keychain.remove(key)
        }
    }
}
