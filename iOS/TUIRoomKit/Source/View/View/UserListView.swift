//
//  UserListView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class UserListView: UIView {
    let viewModel: UserListViewModel
    var attendeeList: [UserModel]
    var searchArray: [UserModel] = []
    
    let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = .searchMemberText
        controller.searchBar.setBackgroundImage(UIColor(0x1B1E26).trans2Image(), for: .top, barMetrics: .default)
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()
    
    let muteAllAudioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.allMuteAudioText, for: .normal)
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        button.setTitle(.allUnMuteAudioText, for: .selected)
        button.setTitleColor(UIColor(0xF2504B), for: .selected)
        button.backgroundColor = UIColor(0x292D38)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        let userRole = EngineManager.shared.store.currentUser.userRole
        let roomInfo = EngineManager.shared.store.roomInfo
        button.isHidden = (userRole != .roomOwner)
        button.isSelected = !roomInfo.enableAudio
        return button
    }()
    
    let muteAllVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.allMuteVideoText, for: .normal)
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        button.setTitle(.allUnMuteVideoText, for: .selected)
        button.setTitleColor(UIColor(0xF2504B), for: .selected)
        button.backgroundColor = UIColor(0x292D38)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        let userRole = EngineManager.shared.store.currentUser.userRole
        let roomInfo = EngineManager.shared.store.roomInfo
        button.isHidden = (userRole != .roomOwner)
        button.isSelected = !roomInfo.enableVideo
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "room_back_white", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.setTitleColor(UIColor(0xD1D9EC), for: .normal)
        button.setTitle(.memberText, for: .normal)
        return button
    }()
    
    lazy var userListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(0x1B1E26)
        tableView.register(UserListCell.self, forCellReuseIdentifier: "UserListCell")
        tableView.tableHeaderView = searchController.searchBar
        return tableView
    }()
    
    lazy var userListManagerView: UserListManagerView = {
        let viewModel = UserListManagerViewModel()
        let view = UserListManagerView(viewModel: viewModel)
        view.isHidden = true
        return view
    }()
    
    lazy var userListMuteView: UserListMuteView = {
        let view = UserListMuteView(viewModel: viewModel)
        view.isHidden = true
        return view
    }()
    
    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        self.attendeeList = EngineManager.shared.store.attendeeList
        super.init(frame: .zero)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ChangeSelfAsRoomOwner, responder: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0x1B1E26)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(userListTableView)
        addSubview(muteAllAudioButton)
        addSubview(muteAllVideoButton)
        addSubview(userListManagerView)
        addSubview(userListMuteView)
    }
    
    func activateConstraints() {
        userListTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(10.scale375())
            make.bottom.equalToSuperview()
        }
        muteAllAudioButton.snp.makeConstraints { make in
            make.trailing.equalTo(snp.centerX).offset(-10)
            make.bottom.equalToSuperview().offset(-40 - kDeviceSafeBottomHeight)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(30)
        }
        muteAllVideoButton.snp.remakeConstraints { make in
            make.leading.equalTo(snp.centerX).offset(10)
            make.bottom.equalTo(muteAllAudioButton)
            make.height.equalTo(50)
            make.trailing.equalToSuperview().offset(-30)
        }
        userListManagerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        userListMuteView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(278.scale375())
            make.height.equalTo(128.scale375())
        }
    }
    
    func bindInteraction() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        RoomRouter.shared.currentViewController()?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        RoomRouter.shared.currentViewController()?.navigationItem.hidesSearchBarWhenScrolling = true
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        muteAllVideoButton.addTarget(self, action: #selector(muteAllVideoAction(sender:)), for: .touchUpInside)
        muteAllAudioButton.addTarget(self, action: #selector(muteAllAudioAction(sender:)), for: .touchUpInside)
    }
    
    @objc func backAction(sender: UIButton) {
        viewModel.backAction(sender: sender)
    }
    
    @objc func muteAllAudioAction(sender: UIButton) {
        viewModel.muteAllAudioAction(sender: sender, view: self)
    }
    
    @objc func muteAllVideoAction(sender: UIButton) {
        viewModel.muteAllVideoAction(sender: sender, view: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchController.searchBar.endEditing(true)
        attendeeList = EngineManager.shared.store.attendeeList
        userListTableView.reloadData()
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ChangeSelfAsRoomOwner, responder: self)
        debugPrint("deinit \(self)")
    }
}

extension UserListView: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchArray = EngineManager.shared.store.attendeeList.filter({ model -> Bool in
            if let searchText = searchController.searchBar.text {
                return (model.userName == searchText)
            } else {
                return false
            }
        })
        attendeeList = searchArray
        userListTableView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        attendeeList = EngineManager.shared.store.attendeeList
        userListTableView.reloadData()
    }
}

extension UserListView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendeeList.count
    }
}

extension UserListView: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendeeModel = attendeeList[indexPath.row]
        let cell = UserListCell(attendeeModel: attendeeModel, viewModel: viewModel)
        cell.selectionStyle = .none
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.endEditing(true)
        let attendeeModel = attendeeList[indexPath.row]
        viewModel.showUserManageViewAction(userId: attendeeModel.userId, view: self)
    }
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.scale375()
    }
}

extension UserListView: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        if key == .TUIRoomKitService_RenewUserList {
            attendeeList = EngineManager.shared.store.attendeeList
            userListTableView.reloadData()
        }
        if key == .TUIRoomKitService_ChangeSelfAsRoomOwner {
            let roomInfo = EngineManager.shared.store.roomInfo
            let userInfo = EngineManager.shared.store.currentUser
            muteAllAudioButton.isHidden = !(roomInfo.owner == userInfo.userId)
            muteAllVideoButton.isHidden = !(roomInfo.owner == userInfo.userId)
            muteAllAudioButton.isSelected = !roomInfo.enableAudio
            muteAllVideoButton.isSelected = !roomInfo.enableVideo
        }
    }
}

class UserListCell: UITableViewCell {
    var attendeeModel: UserModel
    var viewModel: UserListViewModel
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD1D9EC)
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let muteAudioButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_mic_on", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "room_mic_off", in: tuiRoomKitBundle(), compatibleWith: nil), for: .selected)
        return button
    }()
    
    let muteVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "room_camera_on", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "room_camera_off", in: tuiRoomKitBundle(), compatibleWith: nil), for: .selected)
        return button
    }()
    
    let inviteStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = UIColor(0x0565FA)
        button.setTitle(.inviteSeatText, for: .normal)
        button.setTitleColor(UIColor(0xFFFFFF), for: .normal)
        return button
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x2A2D38)
        return view
    }()
    
    init(attendeeModel: UserModel ,viewModel: UserListViewModel) {
        self.attendeeModel = attendeeModel
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: "UserListCell")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userLabel)
        contentView.addSubview(muteAudioButton)
        contentView.addSubview(muteVideoButton)
        contentView.addSubview(inviteStageButton)
        contentView.addSubview(downLineView)
    }
    
    func activateConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        muteVideoButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(self.avatarImageView)
        }
        muteAudioButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.right.equalTo(self.muteVideoButton.snp.left).offset(-12)
            make.centerY.equalTo(self.avatarImageView)
        }
        inviteStageButton.snp.makeConstraints { make in
            make.width.equalTo(62.scale375())
            make.height.equalTo(24.scale375())
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(self.avatarImageView)
        }
        userLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.width.equalTo(150.scale375())
            make.height.equalTo(48)
        }
        downLineView.snp.makeConstraints { make in
            make.left.equalTo(userLabel)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.3)
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x1B1E26)
        setupViewState(item: attendeeModel)
        inviteStageButton.addTarget(self, action: #selector(inviteStageAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: UserModel) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: item.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        if item.userId == EngineManager.shared.store.currentUser.userId {
            userLabel.text = item.userName + "(" + .meText + ")"
        } else {
            userLabel.text = item.userName
        }
        muteAudioButton.isSelected = !item.hasAudioStream
        muteVideoButton.isSelected = !item.hasVideoStream
        inviteStageButton.isHidden = true
        //判断是否显示邀请上台的按钮(房主在举手发言房间中可以邀请其他没有上台的用户)
        if EngineManager.shared.store.roomInfo.enableSeatControl && !attendeeModel.isOnSeat && attendeeModel.userRole != .roomOwner
            && EngineManager.shared.store.currentUser.userRole == .roomOwner {
            muteAudioButton.isHidden = true
            muteVideoButton.isHidden = true
            inviteStageButton.isHidden = false
        }
    }
    
    @objc func inviteStageAction(sender: UIButton) {
        viewModel.userId = attendeeModel.userId
        viewModel.inviteSeatAction(sender: sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static let allMuteAudioText = localized("TUIRoom.all.mute")
    static let allMuteVideoText = localized("TUIRoom.all.mute.video")
    static let allUnMuteAudioText = localized("TUIRoom.all.unmute")
    static let allUnMuteVideoText = localized("TUIRoom.all.unmute.video")
    static let memberText = localized("TUIRoom.conference.member")
    static let searchMemberText = localized("TUIRoom.search.meeting.member")
    static let inviteSeatText = localized("TUIRoom.invite.seat")
    static let meText = localized("TUIRoom.me")
}
