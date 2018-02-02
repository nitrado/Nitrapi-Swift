import ObjectMapper

/// This class represents a Firewall.
open class Firewall: Mappable {
    fileprivate var nitrapi: Nitrapi!
    fileprivate var id: Int!

    public class FirewallProtocol: Value, CustomStringConvertible {
        public static let TCP = FirewallProtocol("tcp")

        public static let UDP = FirewallProtocol("udp")

        public static let ICMP = FirewallProtocol("icmp")

        public static let ANY = FirewallProtocol("any")
        public var description: String {
            return value
        }
    }

    /// Returns enabled.
    open fileprivate(set) var enabled: Bool?
    /// Returns rules.
    open fileprivate(set) var rules: [FirewallRule]?

    init() {
    }

    required public init?(map: Map) {
    }

    public func mapping(map: Map) {
        enabled <- map["enabled"]
        rules <- map["rules"]
    }

    /// This class represents a FirewallRule.
    open class FirewallRule: Mappable {
        /// Returns targetPort.
        open fileprivate(set) var targetPort: Int?
        /// Returns targetIp.
        open fileprivate(set) var targetIp: String?
        /// Returns firewallProtocol.
        open fileprivate(set) var firewallProtocol: FirewallProtocol?
        /// Returns number.
        open fileprivate(set) var number: Int?
        /// Returns comment.
        open fileprivate(set) var comment: String?
        /// Returns sourceIp.
        open fileprivate(set) var sourceIp: String?

        init() {
        }

        required public init?(map: Map) {
        }

        public func mapping(map: Map) {
            targetPort <- map["target_port"]
            targetIp <- map["target_ip"]
            firewallProtocol <- (map["protocol"], ValueTransform<FirewallProtocol>())
            number <- map["number"]
            comment <- map["comment"]
            sourceIp <- map["source_ip"]
        }
    }

    /// Deletes a specific rule by number
    /// - parameter number: number
    open func deleteRule(_ number: Int) throws {
        _ = try nitrapi.client.dataDelete("services/\(id as Int)/cloud_servers/firewall/remove", parameters: [
           "number": number
        ])
    }

    /// Enables the firewall
    open func enableFirewall() throws {
        _ = try nitrapi.client.dataPost("services/\(id as Int)/cloud_servers/firewall/enable", parameters: [:])
    }

    /// Disables the firewall
    open func disableFirewall() throws {
        _ = try nitrapi.client.dataPost("services/\(id as Int)/cloud_servers/firewall/disable", parameters: [:])
    }

    /// Creates a new firewall rule
    /// - parameter sourceIp: sourceIp
    /// - parameter targetIp: targetIp
    /// - parameter targetPort: targetPort
    /// - parameter firewallProtocol: firewallProtocol
    /// - parameter comment: comment
    open func addRule(_ sourceIp: String?, targetIp: String?, targetPort: Int?, firewallProtocol: FirewallProtocol, comment: String?) throws {
        _ = try nitrapi.client.dataPost("services/\(id as Int)/cloud_servers/firewall/add", parameters: [
           "source_ip": sourceIp,
           "target_ip": targetIp,
           "target_port": targetPort,
           "protocol": firewallProtocol,
           "comment": comment
        ])
    }

    // MARK: - Internally used
    func postInit(_ nitrapi: Nitrapi, id: Int) {
        self.nitrapi = nitrapi
        self.id = id
    }
}
