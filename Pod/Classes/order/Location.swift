import ObjectMapper

open class Location: Mappable, CustomStringConvertible {
    open fileprivate(set) var id: Int!
    open fileprivate(set) var country: String!
    open fileprivate(set) var city: String!
    open fileprivate(set) var bouncer: Bool!
    open fileprivate(set) var cloudServer: Bool!
    open fileprivate(set) var gameserver: Bool!
    open fileprivate(set) var mumble: Bool!
    open fileprivate(set) var musicbot: Bool!
    open fileprivate(set) var teamspeak3: Bool!
    open fileprivate(set) var ventrilo: Bool!
    open fileprivate(set) var webspace: Bool!
    
    // MARK: - Initialization
    
    public required init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        id          <- map["id"]
        country     <- map["country"]
        city        <- map["city"]
        bouncer     <- map["products.bouncer"]
        cloudServer <- map["products.cloud_server"]
        gameserver  <- map["products.gameserver"]
        mumble      <- map["products.mumble"]
        musicbot    <- map["products.musicbot"]
        teamspeak3  <- map["products.teamspeak3"]
        ventrilo    <- map["products.ventrilo"]
        webspace    <- map["products.webspace"]
    }
    
    open func hasService(_ type: String) -> Bool {
        switch (type) {
            case "bouncer":
                return bouncer
            case "cloud_server":
                return cloudServer
            case "gameserver":
                return gameserver
            case "mumble":
                return mumble
            case "musicbot":
                return musicbot
            case "teamspeak3":
                return teamspeak3
            case "ventrilo":
                return ventrilo
            case "webspace":
                return webspace
            default:
                return false
        }
    }
    
    open var description: String {
        return "\(city as String) (\(country as String))"
    }
}
