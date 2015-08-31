import Cocoa

class StatusMenuController: NSViewController {
    @IBOutlet weak var statusMenu: NSMenu!

    var topLevelObjects: NSArray?

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    override func awakeFromNib() {
        setupMenu()
    }

    func setupMenu() {
        statusItem.title = "SlackMood"
        statusItem.highlightMode = true
        statusItem.menu = statusMenu
    }

    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    @IBAction func slackConfiguration(sender: NSMenuItem) {
        var objects: NSArray?
        NSBundle.mainBundle().loadNibNamed("SlackConfiguration", owner: self, topLevelObjects: &objects)
        topLevelObjects = objects
    }
}