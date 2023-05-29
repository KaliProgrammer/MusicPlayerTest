//
//  CustomCell.swift
//  MusicPlayerTestovoe
//
//  Created by MacBook Air on 27.05.2023.
//

import Foundation
import UIKit
import SnapKit
import AVFoundation

class CustomCell: UITableViewCell {
    
    //MARK: - UI Components
    
    private lazy var player: AVAudioPlayer = {
        let player = AVAudioPlayer()
        return player
    }()
    
    private lazy var bandNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.theme.accentColor
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.theme.accentColor
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup

    private func setupUIElements() {
        contentView.addSubviews([
            bandNameLabel,
            timeLabel])
        bandNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).offset(16)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(5)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-5)
        }
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing).offset(-16)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(5)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-5)
        }
    }
    
    func applyName(bandName: String, trackName: String) {
        bandNameLabel.text = bandName.replacingOccurrences(of: "-", with: "").capitalized + " - " + trackName.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    func applyTiming(time: String) {
        timeLabel.text = time
    }
}
