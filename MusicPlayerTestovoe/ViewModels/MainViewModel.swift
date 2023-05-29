//
//  MainViewModel.swift
//  MusicPlayerTestovoe
//
//  Created by MacBook Air on 27.05.2023.
//

import Foundation
import RxSwift
import AVFoundation

class MainViewModel {
    let tracks = Observable<[Track]>.of([
        Track(bandName: "Metallica", trackName: "the-unforgiven", timing: "6:27"),
        Track(bandName: "Radiohead", trackName: "karma-police", timing: "4:24"),
        Track(bandName: "Metallica", trackName: "if-darkness-had-a-son", timing: "6:36"),
        Track(bandName: "Van Der Graaf Generator", trackName: "killer", timing: "8:17"),
        Track(bandName: "Metallica", trackName: "st-anger", timing: "6:46"),
    ])
}
