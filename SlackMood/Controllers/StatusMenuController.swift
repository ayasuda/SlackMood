import Cocoa

class StatusMenuController: NSViewController {
    @IBOutlet weak var statusMenu: NSMenu!

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
}