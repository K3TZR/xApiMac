### xApi6000 [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://en.wikipedia.org/wiki/MIT_License)

#### API Explorer for Flex (TM) 6000 series radios (SwiftUI version)

##### Built on:
*  macOS 10.15.7
*  Xcode 12.1 (12A7403) 
*  Swift 5.3 / SwiftUI
*  xLib6000 1.4.0
*  SwiftyUserDefaults 5.0.0
*  XCGLogger 7.0.1

##### Runs on:
* macOS 10.15 and higher

##### Builds
Compiled [RELEASE builds](https://github.com/K3TZR/xApi6000/releases)  will be created at relatively stable points, please use them.  If you require a DEBUG build you will have to build from sources. 

##### Comments / Questions
Please send any bugs / comments / questions to support@k3tzr.net

##### Credits
[xLib6000](https://github.com/K3TZR/xLib6000.git)
[SwiftyUserDefaults](https://github.com/sunshinejr/SwiftyUserDefaults.git)
[XCGLogger](https://github.com/DaveWoodCom/XCGLogger.git)

##### Other software
[![xSDR6000](https://img.shields.io/badge/K3TZR-xSDR6000-informational)]( https://github.com/K3TZR/xSDR6000) A SmartSDR-like client for the Mac.   
[![DL3LSM](https://img.shields.io/badge/DL3LSM-xDAX,_xCAT,_xKey-informational)](https://dl3lsm.blogspot.com) Mac versions of DAX and/or CAT and a Remote CW Keyer.  
[![W6OP](https://img.shields.io/badge/W6OP-xVoiceKeyer,_xCW-informational)](https://w6op.com) A Mac-based Voice Keyer and a CW Keyer.  

---
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

##### 1.0.2 Release Notes
* initial version

##### 1.0.1 Release Notes
* initial version

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

