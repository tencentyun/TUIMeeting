//
//  TUIRoom.swift
//  TUIRoom
//
//  Created by jack on 2022/4/28.
//

import Foundation

@objc
public protocol TUIRoomDelegate: NSObjectProtocol {
    
    ///
    /// Create Room Callback
    ///
    /// - Parameters:
    ///   - code: 0: success. else: fail
    ///   - message: result message.
    @objc
    optional func onRoomCreate(code: Int, message: String)
    
    /// Enter room callback
    /// 
    /// - Parameters:
    ///   - code: 0: success. else: fail
    ///   - message: result message.
    @objc
    optional func onRoomEnter(code: Int, message: String)
    
}

@objcMembers
public class TUIRoom: NSObject {
    
    /// TUIRoom
    /// - note: TUIRoom Object（Singleton Pattern）
    public static let sharedInstance: TUIRoom = TUIRoom()
    
    /// TUIRoom
    /// - note: TUIRoom createRoom、enterRoom callback
    public weak var delegate: TUIRoomDelegate? = nil
    
    /// Enter Room Status: true is already in room, false is not.
    internal var isEnterRoom: Bool = false
    
    /// CreateRoom
    ///
    /// - Parameters:
    ///   - roomId Int roomID generated by the server.
    ///   - speechMode TUIRoomSpeechMode. eg. TUIRoomFreeSpeech/TUIRoomApplySpeech
    ///   - isOpenCamera Bool enableCamera.
    ///   - isOpenMicrophone Bool enableMicrophone.
    @objc
    public func createRoom(roomId: Int,
                           speechMode: TUIRoomSpeechMode,
                           isOpenCamera: Bool,
                           isOpenMicrophone: Bool) {
        if isEnterRoom {
            delegate?.onRoomCreate?(code: -1, message: .alreadyInRoom)
            return
        }
        if TUIRoomUserManage.currentUserId().isEmpty {
            delegate?.onRoomCreate?(code: -1, message: .noLoginToast)
            return
        }
        if roomId <= 0 {
            delegate?.onRoomCreate?(code: -1, message: .enterRoomIdErrorToast)
            return
        }
        let vc = TUIRoomMainViewController(roomId: String(roomId),
                                           isCreate: true,
                                           isVideoOn: isOpenCamera,
                                           isAudioOn: isOpenMicrophone,
                                           speechMode: speechMode)
        presentRoomController(vc: vc)
    }
    
    /// EnterRoom
    ///
    /// - Parameters:
    ///   - roomId Int roomID
    ///   - isOpenCamera Bool enableCamera.
    ///   - isOpenMicrophone Bool enableMicrophone.
    @objc
    public func enterRoom(roomId: Int,
                          isOpenCamera: Bool,
                          isOpenMicrophone: Bool) {
        if isEnterRoom {
            delegate?.onRoomEnter?(code: -1, message: .alreadyInRoom)
            return
        }
        if TUIRoomUserManage.currentUserId().isEmpty {
            delegate?.onRoomEnter?(code: -1, message: .noLoginToast)
            return
        }
        if roomId <= 0 {
            delegate?.onRoomEnter?(code: -1, message: .enterRoomIdErrorToast)
            return
        }
        let vc = TUIRoomMainViewController(roomId: String(roomId),
                                           isCreate: false,
                                           isVideoOn: isOpenCamera,
                                           isAudioOn: isOpenMicrophone)
        presentRoomController(vc: vc)
    }
    
    /// enableFloatWindow
    ///
    /// - Parameters:
    ///   - isEnable Bool enableFloatWindow
    @objc
    func enableFloatWindow(isEnable: Bool) {
        if isEnterRoom {
            floatWindowState = isEnable
        }
    }
}

// MARK: - Private
fileprivate extension TUIRoom {
    
    private func presentRoomController(vc: UIViewController) {
        let current = currentViewController()
        if let nav = current?.navigationController {
            vc.hidesBottomBarWhenPushed = true
            nav.pushViewController(vc, animated: true)
        } else {
            let navRoomVC = UINavigationController(rootViewController: vc)
            navRoomVC.modalPresentationStyle = .fullScreen
            current?.present(navRoomVC, animated: true)
        }
        isEnterRoom = true
    }
    
    private func currentViewController() -> UIViewController? {
        var keyWindow: UIWindow? = nil
        for window in UIApplication.shared.windows {
            if window.isMember(of: UIWindow.self), window.isKeyWindow {
                keyWindow = window
                break
            }
        }
        guard let rootController = keyWindow?.rootViewController else {
            return nil
        }
        func findCurrentController(from vc: UIViewController?) -> UIViewController? {
            if let nav = vc as? UINavigationController  {
                return findCurrentController(from: nav.topViewController)
            } else if let tabBar = vc as? UITabBarController {
                return findCurrentController(from: tabBar.selectedViewController)
            } else if let presented = vc?.presentedViewController {
                return findCurrentController(from: presented)
            }
            return vc
        }
        return findCurrentController(from: rootController)
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let alreadyInRoom = tuiRoomLocalize("TUIRoom.enter.error.already")
    static let noLoginToast = tuiRoomLocalize("TUIRoom.not.login.toast")
    static let enterRoomIdErrorToast = tuiRoomLocalize("TUIRoom.input.error.room.num.toast")
}
