import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let api_url = "https://slack.com/api/chat.postMessage"
    let api_channel = "#music" // channel to post
    let api_token = "xoxp-your-api-token" // your slack token
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        startServices()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        stopServices()
    }

    private func startServices() {
        PlayerListeningService.sharedService().start()
        SlackPostingService.sharedService().start()
    }
    
    private func stopServices() {
        PlayerListeningService.sharedService().stop()
        SlackPostingService.sharedService().stop()
    }
    
    func update(notification: NSNotification?) {
        if (notification?.userInfo?["Player State"] as? String ?? "none") != "Playing"
        {
            return
        }
        let name   = notification?.userInfo?["Name"] as? String ?? "none"
        let artist = notification?.userInfo?["Artist"] as? String ?? "none"
        let moodMessage = "listening... " + name + " - " + artist

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
