import Foundation

struct RoomConfigurator {
    static var userName: String? = "no name"
    static var roomId: String? = "no id"
    static var host: String?
    static var inviteURL: String? = ""

    static func checkRoomId(from userText: String) -> Bool {
        inviteURL = userText

        let roomId = "roomId="

        guard let url = URL(string: userText), userText.contains(roomId), var query = url.query else {
            return false 
        }

        setupHost(url: userText)

        let range = Range(uncheckedBounds: (lower: query.startIndex, upper: roomId.endIndex))
        query.removeSubrange(range)

        self.roomId = query

        return true
    }

    static private func setupHost(url: String) {
        do {
            let regex = try NSRegularExpression(pattern: "(https:\\/\\/).+?(\\/)")
            let matchedStrings: [String] = regex.matches(in: url,
                                                         range: NSRange(url.startIndex..., in: url)).compactMap {
                guard let range = Range($0.range, in: url) else { return nil }
                return String(url[range])
            }
            
            if let matchedString = matchedStrings.first {
                host = matchedString
            }

        } catch let error as NSError {
            print("Regex error \(error.localizedDescription)")
        }
    }
}
