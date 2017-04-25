//
//  AppDelegate.swift
//  HueDollar
//
//  Created by Alan Sikora on 17/04/17.
//  Copyright © 2017 br.com.hue. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var currencyAPI: CurrencyAPI!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var dateMenuItem: NSMenuItem!
    var payoneerCurrencyItem: NSMenuItem!
    
    func getLastQuoteString() -> String {
        if(UserDefaults.standard.value(forKey: "last_quote") == nil) {
            UserDefaults.standard.setValue(0.0, forKey: "last_quote")
        }
        
        return String(format: "$ %.4f", UserDefaults.standard.value(forKey: "last_quote") as! Float)
    }
    
    func getLastQuoteDateString() -> String {
        if(UserDefaults.standard.value(forKey: "last_quote_date") == nil) {
            UserDefaults.standard.setValue("---", forKey: "last_quote_date")
        }
        
        return "Last Quote: \(UserDefaults.standard.value(forKey: "last_quote_date")!)"
    }
    
    func getLastPayonnerQuoteString() -> String {
        if(UserDefaults.standard.value(forKey: "last_payoneer_quote") == nil) {
            UserDefaults.standard.setValue(0.0, forKey: "last_payoneer_quote")
        }
        
        return String(format: "Payoneer: $ %.4f", UserDefaults.standard.value(forKey: "last_payoneer_quote") as! Float)
    }
    
    func getRate() {
        currencyAPI.fetchCurrency("USD") { currency in
            UserDefaults.standard.setValue(currency.quote, forKey: "last_quote")
            UserDefaults.standard.setValue(currency.quote * 0.98, forKey: "last_payoneer_quote")
            UserDefaults.standard.setValue(currency.when, forKey: "last_quote_date")
            
            self.statusItem.menu?.item(withTag: 0)?.title = self.getLastQuoteDateString()
            self.statusItem.menu?.item(withTag: 1)?.title = self.getLastPayonnerQuoteString()
            
            if let button = self.statusItem.button {
                button.title = self.getLastQuoteString()
            }
        }
    }
    
    func getRateEvent(sender: AnyObject) {
        getRate()
    }
    
    func quit(sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(self.getRate), userInfo: nil, repeats: true);
        
        currencyAPI = CurrencyAPI()
        
        if let button = statusItem.button {
            button.title = getLastQuoteString()
        }
        
        let menu = NSMenu()
        
        menu.autoenablesItems = false
        
        payoneerCurrencyItem = NSMenuItem(title: getLastPayonnerQuoteString(), action: nil, keyEquivalent: "")
        payoneerCurrencyItem.tag = 1
        payoneerCurrencyItem.isEnabled = false
        
        menu.addItem(payoneerCurrencyItem)
        
        dateMenuItem = NSMenuItem(title: getLastQuoteString(), action: nil, keyEquivalent: "")
        dateMenuItem.tag = 0
        dateMenuItem.isEnabled = false
        
        menu.addItem(dateMenuItem)
        
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

