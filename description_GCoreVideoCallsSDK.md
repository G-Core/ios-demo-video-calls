
# System requirements
* iOS: 12.1

# Integration Video calls SDK

## Importing the Video calls SDK and configuring the project  
1. Create a new project
2. Instaling Pod Dependencies

	**Podfile**
	```ruby
	pod "mediasoup_ios_client", '1.5.3'
	```
	
3. Copying the `GCoreVideoCallsSDK.xcframework` to the project folder
4. In the project target, in the section **General -> Framework, Libraries, and Embedded Content**, we set the value **Embed** to `Embed & Sign` for `GCoreVideoCallsSDK.xcframework`
5. In the **Build Settings** of the target set `ENABLE_BIT CODE = NO`
6. In the **Build Settings** of the target, we set `Validate Workspace = Yes`
7. In **Info.plist** we add a description for the parameters **NSCameraUsageDescription** and **NSMicrophoneUsageDescription**

## Initializing the Video calls SDK

1. Importing dependencies

	```swift
	import GCoreVideoCallsSDK
	import WebRTC
	```	
	
3. Activating logging

	Output of requests to the server and server responses
	```swift
	GCoreRoomLogger.activateLogger()
	```
	
4. Defining the parameters for connecting to the server

	```swift
	let options = RoomOptions(cameraPosition: .front)
	
	let parameters = MeetRoomParametrs(
	    roomId: "serv01234",
	    displayName: "Name",
	    peerId: "user09876",
	    clientHostName: "meet.gcorelabs.com"
	)
	```
| Parameter| Type | Description| 
|--|--|--|
| roomId | String | Room ID to connect to<br>*Example:* `roomId: "serv01234"` |
|displayName | String | Set display name of participant<br>[Link for extra details in knowledge base](https://gcorelabs.com/support/articles/4404682043665/#h_01FBPQAEZZ1GR7SF7G7TBAYJWZ)<br>*Example:* `displayName: "Name"`|
| peerId | String? (optional) | ID of a participant from your internal system. Please specify userID if you have your own. Or just leave this field blank, then the value will be generated automatically.<br>[Link for extra details in knowledge base](https://gcorelabs.com/support/articles/4404682043665/#h_01FBPQC18B1E3K58C05A8E81Y7)<br>*Example:* `peerId: "user0000000001"`|
| clientHostName | String? (optional) | In this parameter, the client passes the domain name that it uses to operate the web version of mit. Value: domain only without specifying the protocol.<br>*Example:* `clientHostName: "meet.gcorelabs.com"`|
	
5. Create an instance of the client object and connect

	```swift
	var client: GCoreRoomClient?
	
	client = GCoreRoomClient(roomOptions: options, requestParameters: parameters, roomListener: self)

	try? client?.open()
	```
	
6. Activating the audio session

	By default, the audio session ([AVAudioSession](https://developer.apple.com/documentation/avfaudio/avaudiosession)) The SDK does not know how to manage, to enable the basic functionality, you need to call the audio session activation method. The speakerphone will be activated when talking and switching to headphones when they are connected. If the audio session is not activated, the sound and microphone sources will be selected by default by the system (most likely it will be a conversational speaker that needs to be attached to the ear and an external microphone)
	
	```swift
	client?.audioSessionActivate()
	```
	
7. Subscribing to delegate methods `RoomListener`

	```swift
	///  Error received
	func  roomClientHandle(error: RoomError)

	/// Connecting the SDK to services
    func roomClientStartToConnectWithServices()
    
    /// SDK successfully connected to services
    func roomClientSuccessfullyConnectWithServices()

	///  Successful connection to the server
	func  roomClientDidConnected()

	///  Reconnecting to the server
	func  roomClientReconnecting()

	///  Failed reconnection to the server
	func  roomClientReconnectingFailed()

	///  The connection to the server is broken
	func  roomClientSocketDidDisconnected(roomClient: GCoreRoomClient)
    
    /// Returns the peers that are in the room at the time of entry
    func roomClient(roomClient: GCoreRoomClient, joinWithPeersInRoom peers: [PeerObject])
    
    /// The peer entered the room
    func roomClient(roomClient: GCoreRoomClient, handlePeer: PeerObject)
    
    /// Peer left the room
    func roomClient(roomClient: GCoreRoomClient, peerClosed: String)
    
    // Local peer
    /// Local video stream received
    func roomClient(roomClient: GCoreRoomClient, produceLocalVideoTrack videoTrack: RTCVideoTrack)
    
    /// Local audio stream received
    func roomClient(roomClient: GCoreRoomClient, produceLocalAudioTrack audioTrack: RTCAudioTrack)
    
    /// The local video stream was closed
    func roomClient(roomClient: GCoreRoomClient, didCloseLocalVideoTrack videoTrack: RTCVideoTrack?)
    
    /// The local audio stream was closed
    func roomClient(roomClient: GCoreRoomClient, didCloseLocalAudioTrack audioTrack: RTCAudioTrack?)

    // External peers
    /// An external video stream was received
    func roomClient(roomClient: GCoreRoomClient, handledRemoteVideo videoObject: VideoObject)
    
    /**
     The external video stream was closed
     - parameter byModerator - If the peer did not come out by itself, but was closed by the moderator
     */
    func roomClient(roomClient: GCoreRoomClient, didCloseRemoteVideoByModerator byModerator: Bool, videoObject: VideoObject)
    
    /// External audio stream received
    func roomClient(roomClient: GCoreRoomClient, produceRemoteAudio audioObject: AudioObject)
    
    /**
     The external audio stream was closed
     - parameter byModerator - If the peer did not come out by itself, but was closed by the moderator
     */
    func roomClient(roomClient: GCoreRoomClient, didCloseRemoteAudioByModerator byModerator: Bool, audioObject: AudioObject)
    
    /**
     In the array comes a peers with an active microphone. The microphone of the peer is considered active until
	until the same method is called, in the array of which there will be no corresponding peer
     - parameter peers - array of Id who have an active microphone
     */
    func roomClient(roomClient: GCoreRoomClient, activeSpeakerPeers peers: [String])

   /**
    disabling/enabling the camera/microphone/screen sharing by the moderator permission to turn on 
	- parameter kind: the type of stream to turn off (video, audio, share)
	- parameter status: disable or enable	
    */
   func roomClient(
       roomClient: GCoreRoomClient,
       toggleByModerator kind: String,
       status: Bool
   )

   /**
   Permission from the moderator to turn on the camera/microphone/sharing
	- parameter from Moderator: request from moderator
	- parameter peer: for which object to change the permission
    */
   func roomClient(
       roomClient: GCoreRoomClient,
       acceptedPermissionFromModerator fromModerator: Bool,
       peer: PeerObject,
       requestType: String
   )

   /**
    Permission from the moderator to turn off the camera/microphone/sharing
	- parameter kind: the type of stream to turn off audio/video/share
    */
   func roomClient(
       roomClient: GCoreRoomClient,
       disableProducerByModerator kind: String
   )

   /// We are waiting for permission from the moderator to enter the room
   func roomClientWaitingForModeratorJoinAccept()

   /// The moderator rejected the entrance to the room
   func roomClientModeratorRejectedJoinRequest()

   /// Method for moderator. Called when the Peer wants to enter the room
   /// - Parameters:
   ///   - moderatorIsAskedToJoin: The Peer's model who wants to enter the room
   func roomClient(
       roomClient: GCoreRoomClient,
       moderatorIsAskedToJoin: ModeratorIsAskedToJoin
   )

   /// Updating information about the current user and room
   /// - Parameters:
   ///   - updateMeInfo: a model with updated information about the current user and room
   func roomClient(
       roomClient: GCoreRoomClient,
       updateMeInfo: UpdateMeInfoObject
   )

   /// Request to the moderator to include something
   /// - Parameters:
   /// - requestToModerator: model with request type
   func roomClient(
       roomClient: GCoreRoomClient,
       requestToModerator: RequestToModerator
   )

   /// You were removed by the moderator from the room
   func roomClientRemovedByModerator()

   /// Current session and device that the SDK uses
   func roomClient(
       roomClient: GCoreRoomClient,
       captureSession: AVCaptureSession,
       captureDevice: AVCaptureDevice
   )
	```
    
8. Recommended settings after successful connection

The `roomClientDidConnected` method is called after a successful connection to the server. That is, we went into the room. For the subsequent connection of video and audio, we call the client's methods `toggleAudio(isOn: Bool)` and `toggleVideo(isOn: Bool)` respectively
	
	```swift
   func roomClientDidConnected() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.client?.toggleVideo(isOn: true)
			self.client?.toggleAudio(isOn: true)
		}
   }
	```
    
## Interaction with the client application

### Peers (participants)

1. If the connection is successful, a method is called that returns all the participants in the room, we save them, draw elements to display the participants

	```swift
	func joinWithPeersInRoom(_ peers: [PeerObject]) {
		// As an example, creating a peer object and adding a new view to the ScrollView
		peers.forEach { peer in
			let remoteItem = GCLRemoteItem(peerObject: peer)
			remoteItems.insert(remoteItem)
			mainScrollView.addSubview(remoteItem.view)
		}
	}
	```

2. When entering the room of a new participant, we also add it to the array of connected participants and to the ScrollView, respectively

	```swift
	func handledPeer(_ peer: PeerObject) {
		let remoteItem = GCLRemoteItem(peerObject: peer)
		remoteItems.insert(remoteItem)
		mainScrollView.addSubview(remoteItem.view)
	}
	```
	
3. When disconnecting a participant, we remove it from the array

	```swift
	func peerClosed(_ peer: String) {
		if let remoteItem = remoteItems.first(where: { $0.peerId == peer }) {
			remoteItem.view.removeFromSuperview()
			remoteItems.remove(remoteItem)
		}
	}
	```

### Video Streams

1. Creating RTCEAGLVideoView to display video streams

	Creating an RTCEAGLVideoView for a local stream and an array of views for a remote stream

	```swift
	private let localVideoView = RTCEAGLVideoView()
	
	struct RemoteVideoItem {
		let peerId: String
		let videoView: RTCEAGLVideoView
	}
	private var remoteItems = [RemoteVideoItem]()
	```
	
	We get a local stream in the delegate method and pass it a View to display the video

	```swift
	func roomClient(roomClient: GCoreRoomClient, produceLocalVideoTrack videoTrack: RTCVideoTrack) {
		videoTrack.add(localVideoView)
	}
	```
	
	The video streams of other participants come in the form of a `VideoObject`, which has a peer ID `peerId` and a video stream `rtcVideoTrack`
	
	```swift
	func roomClient(roomClient: GCoreRoomClient, handledRemoteVideo videoObject: VideoObject) {
		// Creating a peer object with a view that will display the stream
		let remoteItem = RemoteVideoItem(
			peerId: videoObject.peerid
			videoView: RTCEAGLVideoView()
		)
		remoteItems.add(remoteItem)
		
		// Adding a view to the stream
		videoObject.rtcVideoTrack.add(remoteItem.videoView)
	}
	```
	
	Since we have an array of Peers with views, we can manage them if an event comes to delete the video stream for a particular peer.
	
### Audio Streams

1. When changing the audio stream of one of the participants (microphone on/off), a method is called in which we can check the state of the stream and draw the appropriate icon.

	```swift
	func audioDidChanged(_ audioObject: AudioObject) {
		if let remoteItem = remoteItems.first(where: { $0.peerId == audioObject.peerId }) {
			remoteItem.isEnableAudio(audioObject.rtcAudioTrack.isEnabled)
		}
	}
	```

### Other events

1. The participants who are currently talking
	
	The **activeSpeakerPeers(_ peers: [String])** method returns the IDs of actively speaking peers, so we can draw the appropriate icon for a particular participant

	```swift
	func activeSpeakerPeers(_ peers: [String]) {
		remoteItems.forEach { item in
			item.isSpeekingActive(peers.contains(item.peerId))
		}
	}
	```

## Classes

***`PeerObject`***

peer - a new user in the room

| Parameter| Type | Description|
|--|--|--|
| id | String | user ID |
|displayName | String? | user name 

---

***`VideoObject`***

| Parameter| Type | Description|
|--|--|--|
| peerId | String | user ID |
|rtcVideoTrack | RTCVideoTrack | video stream 

---

***`AudioObject`***

| Parameter| Type | Description|
|--|--|--|
| peerId | String | user ID |
|rtcAudioTrack | RTCAudioTrack | audio stream  

## Types of errors

***`RoomError`***

Returned in the method

```swift
func  roomClientHandle(error: GCoreVideoCallsSDK.RoomError)
```

|Type  | Description |
|--|--|
| invalidSocketURL | invalid URL for connecting to the server |
| fatalError(Error) | an error comes from the server in the `Error` object, you can view its description and determine what the problem is


## Working in the background

At the moment, working in the background is not supported, the connection will be active only when the phone screen is turned on. If the conference is interrupted, if for some reason the application has been minimized, you need to re-initiate the connection to the server (log in to the room)
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE5ODA1NjM3NDQsMTE4MjgzMzc0MiwtMj
E3NjUwNjU1LC0xNDI3NjQzNDA3LC0xODg5MTg3ODg3LDUzMTQx
NzgxMCw4OTI2NTU0OTcsNTMwMDAwMzQzLC0xNjk5OTA3NjQzLC
0xOTQ5ODczNiwtMTE5MTc1NDk0NCw5Mjg4NjQ5NzYsMTc1MjA4
NDA5NSwtNjU1Njc4MDgsNjkwNzk5MzUyLC0xMzExODgxOTkyXX
0=
-->