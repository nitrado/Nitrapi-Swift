open class DimensionPricing: Pricing {
    
    var dimensions: [String: String]
    
    public override init(nitrapi: Nitrapi, locationId: Int) {
        self.dimensions = [:]
        super.init(nitrapi: nitrapi, locationId: locationId)
    }
    
    open func addDimension(_ dimension: String, value: String) {
        dimensions[dimension] = value
    }
    
    open func getSelectedDimension(_ dimension: String) -> String {
        return dimensions[dimension]!
    }
    
    open func removeDimension(_ dimension: String) {
        dimensions.removeValue(forKey: dimension)
    }
    open func reset() {
        dimensions = [:]
    }
    
    open override func getPrice(_ service: Int, rentalTime: Int) throws -> Int {
        let information = try getPrices(service)
        
        let prices = information.prices
        
        var dims: [String?] = []
        
        let realDims = information.dimensions
        for dim in realDims! {
            if dimensions.keys.contains(dim.id) {
                dims.append(dimensions[dim.id]!)
            }
        }
        dims.append("\(rentalTime)")
        
        if !(prices?.keys.contains(calcPath(dims)))! {
            throw NitrapiError.nitrapiException(message: "Can't find price with dimensions \(calcPath(dims))")
        }
        
        let price = prices![calcPath(dims)]
        if let price = price as? PriceDimensionValue {
            var cost = price.value
            var advice = information.advice ?? 0
            if advice > cost {
                advice -= Int(Double(advice - cost) * (50.0 / 100.0))
            }
            cost -= advice
            return cost
        }
        throw NitrapiError.nitrapiException(message: "Misformated json for dimension \(calcPath(dims))")
    }
    
    open override func orderService(_ rentalTime: Int) throws {
        var params = [
            "price": "\(try getPrice(rentalTime))",
            "rental_time": "\(rentalTime)",
            "location": "\(locationId)"
        ]
        for (key, value) in self.dimensions {
            params["dimensions[\(key)"] = value
        }
        
        for (key, value) in self.additionals {
            params["additionals[\(key)"] = value
        }
        
        try nitrapi.client.dataPost("order/order/\(product as String)", parameters: params)
    }
    
    open override func switchService(_ service: Int, rentalTime: Int) throws {
        var params = [
            "price": "\(try getPrice(rentalTime))",
            "rental_time": "\(rentalTime)",
            "location": "\(locationId)",
            "method": "switch",
            "service_id": "\(service)"
        ]
        for (key, value) in self.dimensions {
            params["dimensions[\(key)"] = value
        }
        
        for (key, value) in self.additionals {
            params["additionals[\(key)"] = value
        }
        
        try nitrapi.client.dataPost("order/order/\(product as String)", parameters: params)
    }
}
