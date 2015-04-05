TorToggle
=========
An OS X menubar app that toggles a SOCKS proxy on and off.


Pre-Requisites
==============
```
brew install tor
ln -sfv /usr/local/opt/tor/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.tor.plist
networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 9050 on
```

More information about configuring Tor [here](http://ramonski.de/blog/2012/07/03/using-tor-on-mac/) and [here](http://leonid.shevtsov.me/en/an-easy-way-to-use-tor-on-os-x).


Credits
=======
The sock icon used in the menubar was created by [Darius Lau](http://dariuslau.com) and uploaded to [The Noun Project]( https://thenounproject.com/term/sock/27503/). It's licensed as Public Domain.


Disclaimer
==========
This product is produced independently from the Tor® anonymity software and carries no guarantee from The Tor Project about quality, suitability or anything else. For more information, please visit https://www.torproject.org/.
