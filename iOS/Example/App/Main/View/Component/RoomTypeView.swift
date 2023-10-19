//
//  RoomTypeView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import UIKit

class RoomTypeView: UIView {
    weak var rootViewController: CreateRoomViewController?
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(.cancelText, for: .normal)
        button.setTitleColor(UIColor(0xD1D9EC), for: .normal)
        button.setTitleColor(UIColor(0x146EFA), for: .selected)
        button.backgroundColor = .clear
        return button
    }()
    
    let sureButton: UIButton = {
        let button = UIButton()
        button.setTitle(.okText, for: .normal)
        button.setTitleColor(UIColor(0xD1D9EC), for: .normal)
        button.setTitleColor(UIColor(0x146EFA), for: .selected)
        button.backgroundColor = .clear
        return button
    }()
    
    let freedomButton: UIButton = {
        let button = UIButton()
        button.setTitle(.freedomSpeakText, for: .normal)
        button.setTitleColor(UIColor(0xFFFFFF), for: .normal)
        button.setBackgroundImage(UIColor.tui_color(withHex: "2A2D38").trans2Image(), for: .normal)
        button.setBackgroundImage(UIColor.tui_color(withHex: "4F515A").trans2Image(), for: .selected)
        button.backgroundColor = .clear
        return button
    }()
    
    let raiseHandButton: UIButton = {
        let button = UIButton()
        button.setTitle(.raiseHandSpeakText, for: .normal)
        button.setTitleColor(UIColor(0xFFFFFF), for: .normal)
        button.setBackgroundImage(UIColor.tui_color(withHex: "2A2D38").trans2Image(), for: .normal)
        button.setBackgroundImage(UIColor.tui_color(withHex: "4F515A").trans2Image(), for: .selected)
        button.backgroundColor = .clear
        return button
    }()
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0x2A2D38)
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(cancelButton)
        addSubview(sureButton)
        addSubview(freedomButton)
        addSubview(raiseHandButton)
    }
    
    func activateConstraints() {
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(20.scale375())
            make.width.equalTo(80.scale375())
            make.height.equalTo(30.scale375())
        }
        sureButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.top.width.height.equalTo(cancelButton)
        }
        freedomButton.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(20.scale375())
            make.width.equalToSuperview()
            make.height.equalTo(46.scale375())
        }
        raiseHandButton.snp.makeConstraints { make in
            make.top.equalTo(freedomButton.snp.bottom)
            make.width.height.equalTo(freedomButton)
        }
    }
    
    func bindInteraction() {
        setupViewState()
        cancelButton.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
        sureButton.addTarget(self, action: #selector(sureAction(sender:)), for: .touchUpInside)
        freedomButton.addTarget(self, action: #selector(freedomAction(sender:)), for: .touchUpInside)
        raiseHandButton.addTarget(self, action: #selector(raiseHandAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState() {
        switch rootViewController?.roomSpeechMode {
        case .freeToSpeak:
            freedomButton.isSelected = true
            raiseHandButton.isSelected = false
        case .applySpeakAfterTakingSeat:
            freedomButton.isSelected = false
            raiseHandButton.isSelected = true
        default : break
        }
    }
    
    @objc func cancelAction(sender: UIButton) {
        rootViewController?.cancelAction(sender: sender, view: self)
    }
    
    @objc func sureAction(sender: UIButton) {
        rootViewController?.sureAction(sender: sender, view: self)
    }
    
    @objc func freedomAction(sender: UIButton) {
        rootViewController?.freedomAction(sender: sender, view: self)
    }
    
    @objc func raiseHandAction(sender: UIButton) {
        rootViewController?.raiseHandAction(sender: sender, view: self)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var okText: String {
        RoomDemoLocalize("Demo.TUIRoomKit.ok")
    }
    static var cancelText: String {
        RoomDemoLocalize("Demo.TUIRoomKit.cancel")
    }
    static var raiseHandSpeakText: String {
        RoomDemoLocalize("Demo.TUIRoomKit.raise.speak.model")
    }
    static var freedomSpeakText: String {
        RoomDemoLocalize("Demo.TUIRoomKit.freedom.speak.model")
    }
}