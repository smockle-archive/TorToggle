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
        let isDisabled = SOCKSIsDisabled();
        
        /* Show disabled icon variant if the SOCKS proxy is disabled */
        statusItem.button?.appearsDisabled = isDisabled
        
        /* Modify menu item text if the SOCKS proxy is disabled */
        if (isDisabled) {
            (statusMenu.itemArray[0] as! NSMenuItem).title = "Enable Tor"
        } else {
            (statusMenu.itemArray[0] as! NSMenuItem).title = "Disable Tor"
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true)
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        updateStatusMenuState()
    }
    
    func SOCKSIsDisabled() -> Bool {
        /* Check whether Tor is already enabled */
        let task = NSTask()
        let pipe = NSPipe()
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-getsocksfirewallproxy", "Wi-Fi"]
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        let array = string.componentsSeparatedByString("\n").filter { ($0 as NSString).containsString("Enabled:") && !($0 as NSString).containsString(" Enabled:") }
        
        return array[0].lowercaseString == "enabled: no"
    }
    
    /* Toggle Tor launchctl */
    func toggleTor(command: String) {
        let task = NSTask()
        task.launchPath = "/bin/launchctl"
        task.arguments = [command, "/usr/local/opt/tor/homebrew.mxcl.tor.plist"]
        task.launch()
        task.waitUntilExit()
    }

    /* Toggle SOCKS proxy */
    func toggleSOCKS(command: String) {
        let task = NSTask()
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-setsocksfirewallproxystate", "Wi-Fi", command]
        task.launch()
        task.waitUntilExit()
    }
    
    @IBAction func menuClicked(sender: NSMenuItem) {
        if (sender.title == "Disable Tor") {
            toggleSOCKS("off")
            if (SOCKSIsDisabled()) {
                toggleTor("unload")
            }
        } else {
            toggleSOCKS("on")
            if (!SOCKSIsDisabled()) {
                toggleTor("load")
            }
        }
        updateStatusMenuState()
    }
    
    @IBAction func terminateApplication(sender: AnyObject) {
        if (!SOCKSIsDisabled()) {
            toggleSOCKS("off")
            if (SOCKSIsDisabled()) {
                toggleTor("unload")
            }
        }
        NSApplication.sharedApplication().terminate(self)
    }
}

