import Foundation

class PlayingItem {
    let name: String?
    let artist: String?
    let album: String?
    let url: String?

    init(name: String?, artist: String?, album: String?, url: String?) {
        self.name = name
        self.artist = artist
        self.album = album
        self.url = url
    }
}
