//
//  TrackViewController.swift
//  MusicPlayerTestovoe
//
//  Created by MacBook Air on 27.05.2023.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import AVFoundation

class TrackViewController: UIViewController {
    
    let bandName: BehaviorRelay = BehaviorRelay<String>(value: "")
    let trackName: BehaviorRelay = BehaviorRelay<String>(value: "")
    let disposeBag = DisposeBag()
    let viewModel = MainViewModel()

    
    public var position: BehaviorRelay = BehaviorRelay<Int>(value: 0)
    var tracks: [Track] = []
    var isPlaying: Bool = false
    var playerItem: AVPlayerItem?
    fileprivate let seekDuration: Float64 = 10

    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    //MARK: - UI Components

    private lazy var slider: UISlider = {
        let progressView = UISlider()
        progressView.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        return progressView
    }()
    
    private lazy var startingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.theme.accentColor
        return label
    }()
    
    private lazy var endingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.theme.accentColor
        return label
    }()
    
    private lazy var bandLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.theme.accentColor
        return label
    }()
    
    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textColor = UIColor.theme.accentColor
        return label
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        button.setBackgroundImage(UIImage.pause, for: .normal)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(goToNext), for: .touchUpInside)
        button.setBackgroundImage(UIImage.forward, for: .normal)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(goToBack), for: .touchUpInside)
        button.setBackgroundImage(UIImage.backward, for: .normal)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Close", for: .normal)
        return button
    }()
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        view.backgroundColor = UIColor.theme.backgroundColor
        setupUIElements()
        bindLabels()
        Task {
            await configurePlayer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    @objc func closeBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Stop and play button processing
    
    @objc func playPause() {
        
        if player.rate == 0
        {
            player.play()
            playPauseButton.setBackgroundImage(UIImage.pause, for: .normal)
        } else {
            player.pause()
            playPauseButton.setBackgroundImage(UIImage.play, for: .normal)
        }
    }
    
    //Skip to the next track
    
    @objc func goToNext() {
        if position.value == tracks.count - 1 {
            position.accept(tracks.startIndex - 1)
        }
        
        if position.value < (tracks.count - 1) {
            position.accept(position.value + 1)
            
            Task {
                await configurePlayer()
            }
        }
    }
    
    //Skip to the previous track

    @objc func goToBack() {
        
        if position.value == tracks.startIndex {
            position.accept(tracks.count)
        }
        
        player.rate = 0
        if position.value > 0 {
            position.accept(position.value - 1)
        
            Task {
                await configurePlayer()
            }
        }
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        Task {
            if position.value == tracks.count - 1 {
                position.accept(tracks.startIndex - 1)
            }
            position.accept(position.value + 1)
            await configurePlayer()
        }
    }
    
    //Binding of bandName and trackName labels
    
    private func bindLabels() {
        bandName
            .bind(to: bandLabel
                .rx
                .text)
            .disposed(by: disposeBag)
        
        trackName
            .bind(to: trackNameLabel
                .rx
                .text)
            .disposed(by: disposeBag)
        viewModel.tracks.subscribe { [weak self] tracks in
            self?.tracks = tracks
        }
        .disposed(by: disposeBag)
    }
    
    //time converter
    
    func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        return String(format: "%02i:%02i", minute, second)
    }
    
    // Player configuration
    
    private func configurePlayer() async {
        let track = tracks[position.value]
        
        guard let path = Bundle.main.path(forResource: track.trackName, ofType:"mp3") else {
            debugPrint("video.mp3 not found")
            return
        }
        
        let playerItem: AVPlayerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
      
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        trackNameLabel.text = tracks[position.value].trackName.replacingOccurrences(of: "-", with: " ").capitalized
        bandLabel.text = tracks[position.value].bandName
        playPauseButton.setBackgroundImage(UIImage.pause, for: .normal)

        do {
            let duration : CMTime = try await playerItem.asset.load(.duration)
            let seconds : Float64 = CMTimeGetSeconds(duration)
            endingTimeLabel.text = self.timeString(time: seconds)
            
            let duration1 : CMTime = playerItem.currentTime()
            let seconds1 : Float64 = CMTimeGetSeconds(duration1)
            startingTimeLabel.text = self.timeString(time: seconds1)
            
            slider.maximumValue = Float(seconds)
            slider.isContinuous = true
            player.play()
            isPlaying = true
            
        } catch let error {
            print(error)
        }
   
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player.currentTime());
                self.slider.value = Float ( time )
                
                self.startingTimeLabel.text = self.timeString(time: time)
            }
        }
    }
    
    // MARK: - UI Setup

    private func setupUIElements() {
        view.addSubviews([
            slider,
            playPauseButton,
            nextButton,
            backButton,
            bandLabel,
            trackNameLabel,
            startingTimeLabel,
            endingTimeLabel,
            closeButton,
            cancelButton])
        
        trackNameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.top).offset(400)
            make.centerX.equalToSuperview()
            make.height.equalTo(23)
        }
        
        bandLabel.snp.makeConstraints { make in
            make.top.equalTo(self.trackNameLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        slider.snp.makeConstraints { make in
            make.top.equalTo(self.bandLabel.snp.bottom).offset(50)
            make.leading.equalTo(self.view.snp.leading).offset(16)
            make.trailing.equalTo(self.view.snp.trailing).offset(-16)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(35)
            make.centerX.equalTo(slider.snp.centerX)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(35)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.trailing.equalTo(playPauseButton.snp.leading).offset(-25)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(35)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.leading.equalTo(playPauseButton.snp.trailing).offset(25)
        }
        
        startingTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.view.snp.leading).offset(16)
            make.bottom.equalTo(slider.snp.top).offset(-12)
            make.height.equalTo(12)
        }
        
        endingTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.view.snp.trailing).offset(-16)
            make.bottom.equalTo(slider.snp.top).offset(-12)
            make.height.equalTo(12)
        }
        
        closeButton.snp.makeConstraints { make in
            make.leading.equalTo(self.view.snp.leading).offset(16)
            make.trailing.equalTo(cancelButton.snp.leading).offset(-2)
            make.top.equalTo(self.view.snp.top).offset(16)
            make.height.equalTo(20)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(closeButton.snp.trailing).offset(2)
            make.top.equalTo(self.view.snp.top).offset(16)
            make.height.equalTo(20)
            make.width.equalTo(50)
        }
    }
}
