### xApiMac [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://en.wikipedia.org/wiki/MIT_License)

#### API Explorer for Flex (TM) 6000 series radios (SwiftUI macOS version)

##### Built on:
*  macOS 11.2.3
*  Xcode 12.4 (12D4e) 
*  Swift 5.3 / SwiftUI

##### Runs on:
* macOS 11.0 (Big Sur) and higher

##### Builds
Compiled [RELEASE builds](https://github.com/K3TZR/xApi6000/releases)  will be created at relatively stable points, please use them.  If you require a DEBUG build you will have to build from sources. 

##### Comments / Questions
Please send any bugs / comments / questions to support@k3tzr.net

##### Credits
[CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)

[xLib6000](https://github.com/K3TZR/xLib6000.git)

[xClient](https://github.com/K3TZR/xClient.git)

[SwiftyUserDefaults](https://github.com/sunshinejr/SwiftyUserDefaults.git)

[XCGLogger](https://github.com/DaveWoodCom/XCGLogger.git)

[JWTDecode](https://github.com/auth0/JWTDecode.swift.git)

##### Other software
[![xSDR6000](https://img.shields.io/badge/K3TZR-xSDR6000-informational)]( https://github.com/K3TZR/xSDR6000) A SmartSDR-like client for the Mac.   
[![DL3LSM](https://img.shields.io/badge/DL3LSM-xDAX,_xCAT,_xKey-informational)](https://dl3lsm.blogspot.com) Mac versions of DAX and/or CAT and a Remote CW Keyer.  
[![W6OP](https://img.shields.io/badge/W6OP-xVoiceKeyer,_xCW-informational)](https://w6op.com) A Mac-based Voice Keyer and a CW Keyer.  

---
##### 1.1.6 Release Notes
* incorporated xClient 1.1.0

##### 1.1.5 Release Notes
* transition to xClient instead of xClientMac

##### 1.1.4 Release Notes
* incorporate xClientMac 1.0.4

##### 1.1.3 Release Notes
* changes to conform to xClientMac v1.0.3

##### 1.1.2 Release Notes
* changes to make similar to xApiIos

##### 1.1.1 Release Notes
* enabled sandboxing
* corrected Log View show/hide
* moved ConnectToFirst to TopButtonsView

##### 1.1.0 Release Notes
* initial release

##### 1.0.10 Release Notes
* continuing development

##### 1.0.9 Release Notes
* major reorganization & cleanup

##### 1.0.8 Release Notes
* removed KeyChain.swift (functionality moved to xClientMac)
* removed RadioManagerDelegate calls to KeyChain methods
* corrected comments

##### 1.0.7 Release Notes
* name changed to xApiMac
* corrected startTimestamp bug

##### 1.0.6 Release Notes
* Deployment target changed to macOS 11.0
* uses latest xLib6000 (which does not contain xClient_macOS or xClient_iOS)
* uses xClientMac standalone package
* major rework throughout as a result of testing

##### 1.0.5 Release Notes
* incorporated xLibClient 1.0.2

##### 1.0.4 Release Notes
* changed Log Window title to "Log Window"

##### 1.0.3 Release Notes
* initial release using xLibClient Package

##### 1.0.2 Release Notes
* preparation for removing xLibClient

##### 1.0.1 Release Notes
* added context menu in Radio Picker (right-click) to set/reset default
* added separate defaultConnection values, one for Gui, one for non-Gui connections
* changed "Select" buuton in Radio Picker to "Connect"
* added isDefault and connectionString properties to PickerPacket struct
* changes to RadioListView to support default connection
* updated defaultConnection values in MockRadioManagerDelegate
* added "Picker" button to Tester TopButtonsView
* added AppDelegate as @EnvironmentObject in multiple places
* now show the Picker when connection unsuccessful
* many small adjustments to views

##### 1.0.0 Release Notes
* initial version

##### 0.9.7 Release Notes
* added LogViewer
* misc corrections

##### 0.9.6 Release Notes
* working, needs additional testing
* needs to have xLibClient extracted to be a Swift Package

##### 0.9.5 Release Notes
* still testing

##### 0.9.0 Release Notes
* still testing

