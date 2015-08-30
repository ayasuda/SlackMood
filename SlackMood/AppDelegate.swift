import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
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
}
