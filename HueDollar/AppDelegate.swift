//
//  AppDelegate.swift
//  HueDollar
//
//  Created by Alan Sikora on 17/04/17.
//  Copyright © 2017 br.com.hue. All rights reserved.
//

import Cocoa

struct Currency : CustomStringConvertible {
    var currency: String
    var symbol: String
    var quote: Float
    var when: String
    
    var description: String {
        return String(format: "%@ %.4f", symbol, quote)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var dollarAPI: DollarAPI!
    var bitvalorAPI: BitValorAPI!
    var coinDeskAPI: CoinDeskAPI!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var dateMenuItem: NSMenuItem!
    var payoneerCurrencyItem: NSMenuItem!
    var coindeskCurrencyItem: NSMenuItem!
    var btcBrCurrencyItem: NSMenuItem!
    
    func getLastQuoteString() -> String {
        return String(format: "$ %.2f",
                      UserDefaults.standard.value(forKey: "last_quote") as! Float)
    }
    
    func getLastQuoteDateString() -> String {
        return "Last Quote: \(UserDefaults.standard.value(forKey: "last_quote_date")!)"
    }
    
    func getLastPayonnerQuoteString() -> String {
        return String(format: "Payoneer: $ %.4f", UserDefaults.standard.value(forKey: "last_payoneer_quote") as! Float)
    }
    
    func getLastCoinDeskQuoteString() -> String {
        return String(format: "BTC: $ %.2f", UserDefaults.standard.value(forKey: "last_coindesk_quote") as! Float)
    }
    
    func getLastBtcBrQuoteString() -> String {
        return String(format: "BTC BR: $ %.2f", UserDefaults.standard.value(forKey: "last_bitvalor_quote") as! Float)
    }
    
    @objc func getRate() {
        dollarAPI.fetchCurrency("USD") { currency in
            UserDefaults.standard.setValue(currency.quote, forKey: "last_quote")
            UserDefaults.standard.setValue(currency.quote * 0.98, forKey: "last_payoneer_quote")
            UserDefaults.standard.setValue(currency.when, forKey: "last_quote_date")
            
            self.statusItem.menu?.item(withTag: 0)?.title = self.getLastQuoteDateString()
            self.statusItem.menu?.item(withTag: 1)?.title = self.getLastPayonnerQuoteString()
            self.statusItem.menu?.item(withTag: 2)?.title = self.getLastCoinDeskQuoteString()
            self.statusItem.menu?.item(withTag: 3)?.title = self.getLastBtcBrQuoteString()
            
            if let button = self.statusItem.button {
                DispatchQueue.main.async {
                    button.title = self.getLastQuoteString()
                }
            }
        }
        
        bitvalorAPI.fetchCurrency("BTC") { currency in
            UserDefaults.standard.setValue(currency.quote, forKey: "last_bitvalor_quote")
        }
        
        coinDeskAPI.fetchCurrency("BTC") { currency in
            UserDefaults.standard.setValue(currency.quote, forKey: "last_coindesk_quote")
        }
    }
    
    @objc func getRateEvent(sender: AnyObject) {
        getRate()
    }
    
    @objc func quit(sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(self.getRate), userInfo: nil, repeats: true);
        
        dollarAPI = DollarAPI()
        bitvalorAPI = BitValorAPI()
        coinDeskAPI = CoinDeskAPI()
        
        // Initialize
        if(UserDefaults.standard.value(forKey: "last_coindesk_quote") == nil) {
            UserDefaults.standard.setValue(0.0, forKey: "last_coindesk_quote")
        }
        if(UserDefaults.standard.value(forKey: "last_bitvalor_quote") == nil) {
            UserDefaults.standard.setValue(0.0, forKey: "last_bitvalor_quote")
        }
        if(UserDefaults.standard.value(forKey: "last_payoneer_quote") == nil) {
            UserDefaults.standard.setValue(0.0, forKey: "last_payoneer_quote")
        }
        if(UserDefaults.standard.value(forKey: "last_quote") == nil) {
            UserDefaults.standard.setValue(0.0, forKey: "last_quote")
        }
        if(UserDefaults.standard.value(forKey: "last_quote_date") == nil) {
            UserDefaults.standard.setValue("---", forKey: "last_quote_date")
        }
        
        if let button = statusItem.button {
            button.title = getLastQuoteString()
        }
        
        let menu = NSMenu()
        
        menu.autoenablesItems = false
        
        // Payoneer
        payoneerCurrencyItem = NSMenuItem(title: getLastPayonnerQuoteString(), action: nil, keyEquivalent: "")
        payoneerCurrencyItem.tag = 1
        payoneerCurrencyItem.isEnabled = false
        
        menu.addItem(payoneerCurrencyItem)
        
        // CoinDesk
        coindeskCurrencyItem = NSMenuItem(title: getLastCoinDeskQuoteString(), action: nil, keyEquivalent: "")
        coindeskCurrencyItem.tag = 2
        coindeskCurrencyItem.isEnabled = false
        
        menu.addItem(coindeskCurrencyItem)
        
        // Bitcoin - Brazil
        btcBrCurrencyItem = NSMenuItem(title: getLastBtcBrQuoteString(), action: nil, keyEquivalent: "")
        btcBrCurrencyItem.tag = 3
        btcBrCurrencyItem.isEnabled = false
        
        menu.addItem(btcBrCurrencyItem)
        
        // Date
        dateMenuItem = NSMenuItem(title: getLastQuoteString(), action: nil, keyEquivalent: "")
        dateMenuItem.tag = 0
        dateMenuItem.isEnabled = false
        
        menu.addItem(dateMenuItem)
        
        // Extra
        menu.addItem(NSMenuItem(title: "Get Rate", action: #selector(AppDelegate.getRateEvent(sender:)), keyEquivalent: "R"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(sender:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        self.getRate()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

