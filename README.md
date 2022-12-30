
# G-Core Labs Demo - Video Calls

# Introduction  
Setup real-time communication between users  in 15 minutes in your iOS project instead of 7 days of work and setting parameters of codecs, network, etc. This demo project is a quick tutorial how to video call from your own mobile app to many users  

# Feature

1. Real time communication with WebRTC   
2. Playback video from remote users  
3. Flip camera, connection, moderator mode, portrait/lanscape, preview  

# Quick start  
1. Launching the application via xcode (it must be run on a real device, since the simulator does not support the camera)  
2. Сonnect to the room using the link (check mark for Moderator mode)  
3. Enter a name, turn on video/audio on the preview screen  
4. Click connect button and enjoy real-time communication!  

# Setup of project  
Clone this project and try it or create a new one.

1. SDK - [GCoreVideoCallsSDK](https://bitbucket.gcore.lu/projects/VP/repos/ios_video_calls/browse/description_GCoreVideoCallsSDK.md?at=v1.0.1)   
To work with G-Core Labs services (video calls), we need GCoreVideoCallsSDK. This SDK allows you to establish a connection to the server and receive events from it, as well as send and receive data streams from other users.
2. Permissions  
To use the camera and microphone, you need to request the user's permission for this. To do this, add to the plist (Info) of the project: Privacy - Camera Usage Description and Privacy - Microphone Usage Description.
3. API   
The SDK receives events from the server and passes them to the client application using the RootListener delegate, the full set of methods is available [here](https://bitbucket.gcore.lu/projects/VP/repos/ios_video_calls/browse/description_GCoreVideoCallsSDK.md?at=v1.0.1)

# Requirements

1. iOS min - 12.1
2. Real device (the simulator does not work correctly)
3. The presence of an Internet connection on the device,
4. The presence of a camera and microphone on the device.

# License
Copyright 2022 G-Core Labs Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at


    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


# Screenshots

 <img src="https://github.com/G-Core/ios-demo-video-calls/blob/v2.0.0/Screenshots/1.jpg?raw=true" width="200"> <img src="https://github.com/G-Core/ios-demo-video-calls/blob/v2.0.0/Screenshots/2.jpg?raw=true" width="200">   <img src="https://github.com/G-Core/ios-demo-video-calls/blob/v2.0.0/Screenshots/3.jpg?raw=true" width="200"> <img src="https://github.com/G-Core/ios-demo-video-calls/blob/v2.0.0/Screenshots/4.jpg?raw=true" width="200"> <img src="https://github.com/G-Core/ios-demo-video-calls/blob/v2.0.0/Screenshots/5.jpg?raw=true" width="200">
