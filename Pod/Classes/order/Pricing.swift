import ObjectMapper

open class Pricing {
    var nitrapi: Nitrapi
    var product: String!
    var locationId: Int
    
    var additionals: Dictionary<String, String>
    
    var prices: [String: PriceList]
    
    
    public init(nitrapi: Nitrapi, locationId: Int) {
        self.nitrapi = nitrapi
        self.locationId = locationId
        self.prices = [:]
        self.additionals = [:]
    }
    
    /// returns a list of locations this service is available in
    open func getLocations() throws -> [Location] {
        if product == nil {
            // TODO: Exception
            return []
        }
        
        let data = try nitrapi.client.dataGet("order/order/locations", parameters: [:])
        let locations = Mapper<Location>().mapArray(JSONArray: data?["locations"] as! [[String : Any]])
        var avaiable: [Location] = []
        
        for loc in locations! {
            if loc.hasService(product!) {
                avaiable.append(loc)
            }
        }
        return avaiable
    }
    
    open func setLocationId(_ id: Int) {
        locationId = id
    }
    
    open func getPrices() throws -> PriceList {
        return try getPrices(-1)
    }
    
    open func getPrices(_ service: Int) throws -> PriceList {
        var cacheName = "\(locationId)"
        if service != -1 {
            cacheName += "/\(service)"
        }
        if prices.keys.contains(cacheName) {
            return prices[cacheName]!
        }
        
        var parameters: [String:String] = ["location": "\(locationId)"]
        
        if (service != -1) {
            parameters["sale_service"] = "\(service)"
        }
        
        let data = try nitrapi.client.dataGet("order/pricing/\(product as String)", parameters: parameters)
        
        prices[cacheName] = Mapper<PriceList>().map(JSON: data?["prices"] as! [String : Any])
        return prices[cacheName]!
    }
    
    open func getExtendPricesForService(_ service: Int) throws -> [ExtensionPrice]? {
        let data = try nitrapi.client.dataGet("order/pricing/\(product as String)", parameters: [
            "method": "extend",
            "service_id": "\(service)"])
        if let obj = data?["extend"] as? Dictionary<String, AnyObject> {
            let pricesRaw = obj["prices"]
            
            if let prices = obj["prices"]! as? Dictionary<String, AnyObject> {
                var list: [ExtensionPrice] = []
                for (key, value) in prices {
                    list.append(ExtensionPrice(rentalTime: Int(key)!, price: value as! Int)!)
                }
                return list
            }
        }
        return nil
    }
    
    open func doExtendService(_ service: Int, rentalTime: Int, price: Int) throws {
        try nitrapi.client.dataPost("order/order/\(product as String)", parameters: [
            "price": "\(price)",
            "rental_time": "\(rentalTime)",
            "service_id": "\(service)",
            "method": "extend"
            ])
    }
    
    
    
    
    open func getPrice(_ rentalTime: Int) throws -> Int {
        return try getPrice(-1, rentalTime: rentalTime)
    }
    open func getPrice(_ service: Int, rentalTime: Int) throws -> Int {
        return -1
    }
    open func orderService(_ rentalTime: Int) throws {
    }
    open func getSwitchPrice(_ service: Int, rentalTime: Int) throws -> Int {
        return try getPrice(service, rentalTime: rentalTime)
    }
    open func switchService(_ service: Int, rentalTime: Int) throws {
        
    }
}
