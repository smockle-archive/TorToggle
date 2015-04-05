//
//  AppDelegate.swift
//  TorToggle
//
//  Created by Clay Miller on 4/3/15.
//  Copyright (c) 2015 Clay Miller. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    func updateStatusMenuState() {
        /* Check whether Tor is already enabled */
        let task = NSTask()
        let pipe = NSPipe()
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-getsocksfirewallproxy", "Wi-Fi"]
        task.standardOutput = pipe
        task.launch()
        
        /* Show disabled icon variant if Tor is disabled */
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string = NSString(data: data, encoding: NSUTF8StringEncoding) as String
        let array = string.componentsSeparatedByString("\n").filter { ($0 as NSString).containsString("Enabled:") && !($0 as NSString).containsString(" Enabled:") }
        let disabled = array[0].lowercaseString == "enabled: no"
        statusItem.button?.appearsDisabled = disabled
        
        /* Modify menu item text if Tor is disabled */
        if (disabled) {
            (statusMenu.itemArray[0] as NSMenuItem).title = "Enable Tor"
        } else {
            (statusMenu.itemArray[0] as NSMenuItem).title = "Disable Tor"
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true)
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        updateStatusMenuState()
    }

    @IBAction func menuClicked(sender: NSMenuItem) {
        let task = NSTask()
        task.launchPath = "/usr/sbin/networksetup"
        
        if (sender.title == "Disable Tor") {
            task.arguments = ["-setsocksfirewallproxystate", "Wi-Fi", "off"]
        } else {
            task.arguments = ["-setsocksfirewallproxystate", "Wi-Fi", "on"]
        }
        
        task.launch()
        task.waitUntilExit()
        
        updateStatusMenuState()
    }
    
    @IBAction func terminateApplication(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
}

