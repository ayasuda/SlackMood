import Cocoa

class SlackConfigurationController: NSWindowController {
    class Config: NSObject {
        var channel: String = ""
        var token: String = ""

        func isValid() -> Bool {
            return channel != "" && token != ""
        }
    }

    let conf: Config = Config()

    @IBOutlet weak var channelText: NSTextField!
    @IBOutlet weak var tokenText: NSTextField!
    @IBOutlet weak var okButton: NSButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        loadConfig()
    }

    private func loadConfig() {
        let service = SlackApiConfigService.sharedService()
        if let config = service.load() {
            channelText.stringValue = config.channel
            tokenText.stringValue = config.token
        }
        syncTexts()
    }

    override func controlTextDidChange(obj: NSNotification) {
        syncTexts()
    }

    private func syncTexts() {
        conf.channel = channelText.stringValue
        conf.token = tokenText.stringValue
        okButton.enabled = conf.isValid()
    }

    @IBAction func okClicked(sender: NSButton) {
        let config = SlackApiConfig(channel: conf.channel, token: conf.token)
        let service = SlackApiConfigService.sharedService()
        service.save(config)
        close()
    }

    @IBAction func cancelClicked(sender: NSButton) {
        close()
    }
}