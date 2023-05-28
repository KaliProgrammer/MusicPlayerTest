# MusicPlayerTest

- Supports IOS 13+
- Swift 5+
- The layout is done by code.
- SPM for exterior dependencies - have been used (SnapKit).
- The application has dark design and has white design.


Application architecture:
- MVVM

Application Frameworks:
- RxSwift, RxCocoa, AVFoundation



MainViewController:

- Has a list of tracks with title and
duration of each track.

TrackViewController:

- Displays information about the track on the player screen: title,
artist, current time, track duration and close button.
- Has buttons: play/pause, next/previous track and bar
progress(slider). 
- After the end of the track, there is a switch to the next
track (to the first one, if the track is the last one in the list). 
- When returning to list screen, playback stops and switches
when you select another track.


<img width="240" alt="Screenshot 2023-05-28 at 21 10 51" src="https://github.com/KaliProgrammer/MusicPlayerTest/assets/100012767/51f974c0-83c7-4055-a44e-4ede6d9adfbe">

<img width="242" alt="Screenshot 2023-05-28 at 21 11 08" src="https://github.com/KaliProgrammer/MusicPlayerTest/assets/100012767/08e981d8-1dcd-4926-8595-a48fedca9888">

