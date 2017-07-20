//
//  CurrencyLayer.swift
//  HueDollar
//
//  Created by Alan Sikora on 17/04/17.
//  Copyright © 2017 br.com.hue. All rights reserved.
//

import Foundation

class BitcoinAPI {
    let BASE_URL = "https://api.bitvalor.com/v1"
    
    func fetchCurrency(_ currencyCode: String, success: @escaping (Currency) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "\(BASE_URL)/ticker.json")
        let task = session.dataTask(with: url!) { data, response, err in
            // first check for a hard error
            if let error = err {
                NSLog("Bitcoin API error: \(error)")
            }
            
            // then check the response code
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200: // all good!
                    if let currency = self.currencyFromJSONData(data!, currencyCode) {
                        success(currency)
                    }
                case 401: // unauthorized
                    NSLog("Bitcoin API returned an 'unauthorized' response. Did you set your API key?")
                default:
                    NSLog("Bitcoin API returned response: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                }
            }
        }
        task.resume()
    }
    
    func currencyFromJSONData(_ data: Data,_ currencyCode: String) -> Currency? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        var ticker24hDict = json["ticker_24h"] as! JSONDict
        var exchangesDict = ticker24hDict["exchanges"] as! JSONDict
        var foxDict = exchangesDict["FOX"] as! JSONDict
        
        var timestampDict = json["timestamp"] as! JSONDict
        
        let timestamp = NSDate(timeIntervalSince1970: timestampDict["total"] as! Double)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.short
        let localDate = dateFormatter.string(from: timestamp as Date)
        
        let currency = Currency(
            currency: currencyCode,
            symbol: "฿",
            quote: foxDict["last"] as! Float,
            when: localDate
        )
        
        return currency
    }
}
