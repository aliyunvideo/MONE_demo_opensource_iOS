# Alibaba Cloud MediaBox SDK Sample

## Code Structure
```
├── Root Directory                                    
│   ├── AUIBaseKits                            // Source code files of dependent AUI basic components
│       ├── AUIBeauty                          // Dependent beauty component
│       ├── AUIFoundation                      // Dependent basic UI components
│   ├── AlivcLiveDemo                          // Live streaming module source code files
│   ├── AlivcPlayerDemo                        // Player module source code files
│   ├── AlivcRtcDemo                           // Interactive live streaming module source code files
│   ├── AlivcUgsvDemo                          // Short video production module source code files
│   ├── AlivcAIODemo                           // Integrated aggregate page module source code files
│   ├── AlivcAIODemo.xcodeproj                 // Project file of the demo
│   ├── AlivcAIODemo.xcworkspace               // Workspace file of the demo
│   ├── Podfile                                // Podfile file of the demo
│   ├── Resources                              // Resource files
│   ├── README.md                              // Readme file
```


## Running the sample code

- After downloading the source code, enter the root directory.
- Execute the command "pod install --repo-update" in the root directory to automatically install dependent SDKs.
- Open the project file "AlivcAIODemo.xcworkspace" and modify the package ID.
- Apply for a trial License on the console and obtain the License file and LicenseKey. If you already have them, proceed to the next step.
- Place the License file in the root directory and rename it to "license.crt".
- Copy the "LicenseKey" (if you don't have it, please copy from the console), open "AlivcAIODemo/Info.plist," and fill it in the value of the field "AlivcLicenseKey".
- Compile and run the application.
