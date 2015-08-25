import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let api_url = "https://slack.com/api/chat.postMessage"
    let api_channel = "#music" // channel to post
    let api_token = "xoxp-your-api-token" // your slack token
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSDistributedNotificationCenter.defaultCenter().addObserver(
            self, selector: "update:", name: "com.apple.iTunes.playerInfo", object: nil)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        NSDistributedNotificationCenter.defaultCenter().removeObserver(
            self, name: "com.apple.iTunes.playerInfo", object: nil)
    }
    
    
    func update(notification: NSNotification?) {
        if (notification?.userInfo?["Player State"] as? String ?? "none") != "Playing"
        {
            return
        }
        let name   = notification?.userInfo?["Name"] as? String ?? "none"
        let artist = notification?.userInfo?["Artist"] as? String ?? "none"
        let album = notification?.userInfo?["Album"] as? String ?? "none"
        let moodMessage = "Now Playing: *" + name + "* by *" + artist + "* from *" + album + "*"
        
        var params: [String: AnyObject] = [
            "channel" : api_channel,
            "token" : api_token,
            "as_user" : true,
            "text" : moodMessage
        ]
        
        Alamofire
            .request(.POST, api_url, parameters: params, encoding: ParameterEncoding.URL, headers: nil)
            .response { (request, response, data, error) -> Void in
                println(response)
        }
    }
}
