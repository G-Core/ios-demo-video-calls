//
//  VideoCallViewController.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 31.03.2022.
//

import UIKit
import AVFoundation
import GCoreVideoCallsSDK

struct ScreenSize {
    static let width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    static let height = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
}

final class GCVideoCallViewController: GCBaseViewController {
    private let model = GCModel.shared
    private let cellId = "VideoCellId"
    private let blurView = GCVideoCallBlurView(frame: .zero)
    private let localVideoView = GCLocalVideoView(frame: .zero)
    
    private var moderatorControlView: GCModeratorControlView?
    
    private lazy var waitingView = GCWaitingView(frame: view.bounds)
    
    private lazy var bottomButtons = GCVideoCallControlButtonsView(withMicrophone: model.userSettings.audioIsOn,
                                                                   withVideo: model.userSettings.videoIsOn)
    
    private lazy var videoCallWrapper = VideoCallWrapper(roomID: model.roomData.id,
                                                         displayName: model.userName,
                                                         cameraPosition: model.userSettings.cameraPosition ?? .front,
                                                         isModerator: model.userSettings.isModerator)
    
    private lazy var collectionView = GCVideoCallCollectionView(cellId: cellId)
    private lazy var moderatorVC = GCModeratorViewController()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurView.isHidden = true
        blurView.frame = view.bounds
        
        collectionView.dataSource = self
        collectionView.delegate = self
        videoCallWrapper.delegate = self
        bottomButtons.buttonsDelegate = self
        
        localVideoView.isHidden = true
        initConstraints()
        
        try? videoCallWrapper.client?.open()
    }
    
    override func becomeFirstResponder() -> Bool {
        blurView.isHidden = !super.becomeFirstResponder()
        moderatorControlView?.removeFromSuperview()
        moderatorControlView = nil
        return !blurView.isHidden
    }
    
    private func addModeratorMode() {
        view.addSubview(moderatorVC.view)
        addChild(moderatorVC)
        moderatorVC.roomClient = videoCallWrapper.client
        videoCallWrapper.moderator = moderatorVC
        moderatorVC.didMove(toParent: self)
        moderatorVC.view.frame = view.bounds
        moderatorVC.view.bounds.size.height -= 90
        moderatorVC.view.frame.origin.y = -view.bounds.height
        moderatorVC.view.layer.cornerRadius = 20
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
        blurView.addGestureRecognizer(gesture)
    }
    
    private func collectionReloadInMainThread() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        waitingView.frame.size = size
    }
}

//MARK: - VideoCallWrapperDelegate

extension GCVideoCallViewController: VideoCallWrapperDelegate {
    func connectionProccess(state: VideoCallConnectionState) {
        guard videoCallWrapper.isDisconnected == false else { return }
        waitingView.state = state
        
        switch state {
        case .reconnectingFailed: try? videoCallWrapper.client?.open()
            
        case .removedByModerator:
            let closure = { [weak self] in
                self?.navigationController?.pushViewController(GCEndScreenViewController(), animated: true)
            }
            
            let alert = AlertFabric.newAlert(type: .kickByModerator, handler: { _ in closure() })
            present(alert, animated: true, completion: nil)
            
        case .moderatorRejectedJoinRequest:
            let closure = { [weak self] in
                self?.navigationController?.pushViewController(GCEndScreenViewController(), animated: true)
            }
            
            let alert = AlertFabric.newAlert(type: .moderatorRejectedJoinRequest, handler: { _ in closure() })
            present(alert, animated: true, completion: nil)
            
        default: break
        }
    }
    
    func removeTrackByModerator(_ media: MediaTrackKind) {
        switch media {
        case .video: toggleCamera()
        case .share: return
        case .audio: toggleMicrophone()
        }
    }
    
    func initialPermissions(tracks: [MediaTrackKind : Bool]) {
        RoomInitialStateSetter.initialPermissions(tracks, for: model, and: bottomButtons)
    }
    
    func togglePermissions(track: MediaTrackKind, isEnabled: Bool) {
        if !model.userSettings.isModerator {
            switch (track, isEnabled) {
                
            case (.video, true) where !model.userSettings.videoIsOn:
                bottomButtons.changeButtonState(button: .camera, to: .deactive)
                
            case (.video, false):
                bottomButtons.changeButtonState(button: .camera, to: .unavailable)
                model.userSettings.videoIsOn = isEnabled
                videoCallWrapper.client?.toggleVideo(isOn: isEnabled)
                
            case (.audio, true) where !model.userSettings.audioIsOn:
                bottomButtons.changeButtonState(button: .microphone, to: .deactive)
                
            case (.audio, false):
                bottomButtons.changeButtonState(button: .microphone, to: .unavailable)
                model.userSettings.audioIsOn = isEnabled
                videoCallWrapper.client?.toggleAudio(isOn: isEnabled)
                
            default: break
            }
        }
        
        switch track {
        case .video: model.roomSettings.videoIsEnable = isEnabled
        case .share: model.roomSettings.shareIsEnable = isEnabled
        case .audio: model.roomSettings.audioIsEnable = isEnabled
        }
    }
    
    func requestByModerator(_ mediaKind: MediaTrackKind) {
        let buttonType: GCVideoCallButton.ButtonType
        
        switch mediaKind {
        case .video: buttonType = .camera
        case .share: return
        case .audio: buttonType = .microphone
        }
        
        let closure = { [weak self] in
            guard let self = self else { return }
            
            switch mediaKind {
            case .video:
                if !self.model.userSettings.videoIsOn {
                    self.toggleCamera()
                }
                
            case .share:
                return
                
            case .audio:
                if !self.model.userSettings.audioIsOn {
                    self.toggleMicrophone()
                }
            }
        }
        
        bottomButtons.changeButtonState(button: buttonType, to: .deactive)
        let alert = AlertFabric.newAlert(type: .requestByModerator(mediaKind), handler: { _ in closure() })
        present(alert, animated: true)
    }
    
    func handlePeer(_ item: RemoteVideoItem) {
        model.remoteVideoItems.append(item)
        collectionReloadInMainThread()
        
        if model.userSettings.isModerator {
            model.deleteUserFromWaitingRoom(id: item.userData.id)
            
            DispatchQueue.main.async { [weak self] in
                self?.moderatorVC.moderatorTableView.reloadData()
            }
        }
    }
    
    func peerClosed(_ peerId: String) {
        guard let index = model.findIndexFor(peerId: peerId) else { return }
        model.remoteVideoItems.remove(at: index)
        collectionReloadInMainThread()
    }
    
    func changeLocalVideo(_ videoTrack: RTCVideoTrack?, isClose: Bool) {
        videoTrack?.add( model.localVideoItem.videoView)
        model.localVideoItem.trackId = videoTrack?.trackId
        model.localVideoItem.hasCamera = !isClose
        DispatchQueue.main.async { [weak self] in
            self?.localVideoView.isHidden = isClose
        }
    }
    
    func changeLocalAudio(_ audioTrack: RTCAudioTrack?, isClose: Bool) {
        model.localVideoItem.hasMicrophone = !isClose
    }
    
    func videoChangeFor(_ peerId: String, isClose: Bool) {
        guard let index = model.findIndexFor(peerId: peerId) else { return }
        model.remoteVideoItems[index].hasCamera = !isClose
        collectionReloadInMainThread()
    }
    
    func audioChangeFor(_ peerId: String, isClose: Bool) {
        guard let index = model.findIndexFor(peerId: peerId) else { return }
        model.remoteVideoItems[index].hasMicrophone = !isClose
        collectionReloadInMainThread()
    }
    
    func talkingUsers(_ peers: [String]) {
        model.localVideoItem.isSpeak = peers.contains(model.localVideoItem.userData.id)
        
        for item in model.remoteVideoItems {
            if let index = model.findIndexFor(peerId: item.userData.id) {
                model.remoteVideoItems[index].isSpeak = peers.contains(item.userData.id)
            }
        }
        
        collectionReloadInMainThread()
    }
    
    func didAddVideoTrack(_ videoObject: VideoObject) {
        DispatchQueue.main.async { [self] in
            if let index = model.remoteVideoItems.firstIndex(where: { $0.userData.id == videoObject.peerId }) {
                if model.remoteVideoItems[index].trackId == nil {
                    videoObject.rtcVideoTrack.add(model.remoteVideoItems[index].videoView)
                    model.remoteVideoItems[index].trackId = videoObject.rtcVideoTrack.trackId
                }
            }
            collectionReloadInMainThread()
        }
    }
    
    func didCreateRemoteItems(_ items: [RemoteVideoItem]) {
        model.remoteVideoItems = items
        collectionReloadInMainThread()
    }
    
    func didReceiveUserInfo(_ info: UpdateMeInfoObject) {
        RoomInitialStateSetter.initLocalUserInfo(info, for: model)
        localVideoView.addRTC(model.localVideoItem.videoView)
        bottomButtons.setModeratorButtonVisability(isHidden: !model.userSettings.isModerator)
        
        if model.userSettings.isModerator {
            addModeratorMode()
        }
    }
    
    var presetCallSettings: (isAudioOn: Bool, isVideoOn: Bool) {
        (model.userSettings.audioIsOn, model.userSettings.videoIsOn)
    }
}

//MARK: - Layout

extension GCVideoCallViewController {
    private func initConstraints() {
        view.addSubview(collectionView)
        view.addSubview(localVideoView)
        view.addSubview(bottomButtons)
        view.addSubview(blurView)
        view.addSubview(waitingView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 20),
            collectionView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            
            bottomButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomButtons.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor),
            bottomButtons.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor),
            bottomButtons.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            bottomButtons.heightAnchor.constraint(equalToConstant: 70),
            
            localVideoView.widthAnchor.constraint(equalToConstant: ScreenSize.width/4),
            localVideoView.heightAnchor.constraint(equalTo: localVideoView.widthAnchor, multiplier: 16/9),
            localVideoView.leftAnchor.constraint(equalTo: collectionView.leftAnchor),
            localVideoView.bottomAnchor.constraint(equalTo: bottomButtons.topAnchor, constant: -10)
        ])
    }
    
    private func initModeratorViewConstraints(_ moderatorView: GCModeratorControlView) {
        view.addSubview(moderatorView)
        
        NSLayoutConstraint.activate([
            moderatorView.widthAnchor.constraint(equalToConstant: 180),
            moderatorView.heightAnchor.constraint(equalToConstant: 360),
            moderatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moderatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - UICollectionViewDataSource

extension GCVideoCallViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.remoteVideoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GCVideoCallCollectionCell
        cell.setupCellWith(remoteItem: model.remoteVideoItems[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard model.userSettings.isModerator else { return }
        let moderatorView = GCModeratorControlView(frame: .zero, user: model.remoteVideoItems[indexPath.row].userData)
        moderatorView.delegate = moderatorVC
        moderatorView.translatesAutoresizingMaskIntoConstraints = false
        moderatorControlView = moderatorView
        blurView.isHidden = false
        initModeratorViewConstraints(moderatorView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.transform = .init(scaleX: 0.9, y: 0.9)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.transform = .init(scaleX: 1, y: 1)
        }
    }
}

//MARK: - GCVideoCallButtonsStackViewDelegate

extension GCVideoCallViewController: GCVideoCallButtonsStackViewDelegate {
    func tapUnavailableButton(_ button: GCVideoCallButton.ButtonType) {
        let media: MediaTrackKind
        
        switch button {
        case .microphone: media = .audio
        case .camera: media = .video
        case .cameraPosition: media = .video
        default: return
        }
        
        let closure: ((UIAlertAction) -> Void) = { [weak self] _ in
            self?.videoCallWrapper.client?.askModeratorToEnableTrack(kind: media.rawValue)
        }
        
        let alert = AlertFabric.newAlert(type: .askToModeratorToTurn(media), handler: closure)
        present(alert, animated: true, completion: nil)
    }
    
    func toggleModeratorModeView() {
        guard let view = self.moderatorVC.view else { return }
        let y = view.frame.origin.y
        
        UIView.animate(withDuration: 0.3) {
            y == 20 ? (view.frame.origin.y = -ScreenSize.height) : (view.frame.origin.y = 20)
        }
    }
    
    func copyRoomURL() {
        guard let str = model.roomData.url?.absoluteString else { return }
        UIPasteboard.general.string = str
    }
    
    func toggleMicrophone() {
        model.userSettings.audioIsOn = !model.userSettings.audioIsOn
        model.localVideoItem.hasMicrophone = model.userSettings.audioIsOn
        videoCallWrapper.client?.toggleAudio(isOn: model.userSettings.audioIsOn)
        let newState: GCVideoCallButton.ButtonState = model.userSettings.audioIsOn ? (.active) : (.deactive)
        bottomButtons.changeButtonState(button: .microphone, to: newState)
    }
    
    func toggleCamera() {
        bottomButtons.isUserInteractionEnabled = false
        model.userSettings.videoIsOn = !model.userSettings.videoIsOn
        model.localVideoItem.hasCamera = model.userSettings.videoIsOn
        videoCallWrapper.client?.toggleVideo(isOn: model.userSettings.videoIsOn)
        localVideoView.isHidden = !model.userSettings.videoIsOn
        let newState: GCVideoCallButton.ButtonState = model.userSettings.videoIsOn ? (.active) : (.deactive)
        bottomButtons.changeButtonState(button: .camera, to: newState)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.bottomButtons.isUserInteractionEnabled = true
        }
    }
    
    func toggleCameraPosition() {
        bottomButtons.isUserInteractionEnabled = false
        
        let comlpletion: ((Error?) -> Void)? = { [self] error in
            if let error = error  {
                let error = error as NSError
                print(error.localizedFailureReason as Any)
            }
            DispatchQueue.main.async { [weak self] in
                self?.bottomButtons.isUserInteractionEnabled = true
            }
        }
        
        switch model.userSettings.cameraPosition {
        case .front:
            videoCallWrapper.client?.toggleCameraPosition(completion: comlpletion)
            model.userSettings.cameraPosition = .back
            
        case .back:
            videoCallWrapper.client?.toggleCameraPosition(completion: comlpletion)
            model.userSettings.cameraPosition = .front
            
        default:
            bottomButtons.isUserInteractionEnabled = true
        }
    }
    
    func endCall() {
        navigationController?.pushViewController( GCEndScreenViewController(), animated: true)
        videoCallWrapper.client?.close()
    }
}
