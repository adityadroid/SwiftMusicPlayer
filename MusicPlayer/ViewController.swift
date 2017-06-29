//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Aditya Gurjar on 6/1/17.
//  Copyright © 2017 Aditya Gurjar. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
class ViewController: UIViewController {

    var audio_player : AVAudioPlayer  = AVAudioPlayer()
    
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var currentSeekTimeLabel: UILabel!
    @IBOutlet weak var totalSeekTimeLabel: UILabel!
    
    
    @IBOutlet weak var songSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    weak var forwardTimer : Timer!
    weak var rewindTimer : Timer!
    var songs = ["Phenomenal","Smack that","Beautiful","Forever","Guts Over Fear"]
    var currentIndex = 0
    let pauseImg : UIImage = UIImage(named: "pause(3).png")!
    let playImg : UIImage = UIImage(named: "play-button(2).png")!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let thumbImage : UIImage = UIImage(named: "dot-and-circle(1).png")!
        volumeSlider.setThumbImage(thumbImage, for: UIControlState.normal)
        
               updateSongDetails()
        
        
       initGestures()
        
    }

    func initGestures(){
        
        forwardButton.addTarget(self, action: #selector(ViewController.fastForwardHold), for: UIControlEvents.touchDown)
        
        forwardButton.addTarget(self, action: #selector(ViewController.fastForwardRelease), for: UIControlEvents.touchUpInside)
        rewindButton.addTarget(self, action: #selector(ViewController.rewindHold), for: UIControlEvents.touchDown)
        rewindButton.addTarget(self, action: #selector(ViewController.rewindRelease), for: UIControlEvents.touchUpInside)
        
        albumArtImageView.isUserInteractionEnabled = true
        let swipeLeft  = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.prevSong))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        albumArtImageView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.nextSong))
        albumArtImageView.addGestureRecognizer(swipeRight)
        
        
    }
    
    
    
    
    
    func updateSongDetails(){
        
        let audioPath = Bundle.main.path(forResource: songs[currentIndex], ofType: "mp3")
        
        
        do {
            try audio_player = AVAudioPlayer.init(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            
        } catch{
            print("could not load audio")
        }
        
        songSlider.maximumValue = Float( audio_player.duration)
        
        let min = Int(audio_player.duration/60)
        let sec = Int(audio_player.duration - TimeInterval(min*60))
        let totalSeekTime : String = "\(min):\(sec)"
        totalSeekTimeLabel.text = totalSeekTime
        
        print("DURATION: "+String(audio_player.duration))
        
        _ =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateSeekSlider), userInfo: nil, repeats: true)
        
        
        
        
        
        let url : URL = URL(fileURLWithPath: audioPath!)
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.commonMetadata
        var foundTitle = false
        var foundAlbumArt = false
        var foundAlbum = false
        for item in metadataList {
            if item.commonKey == "title" {
                songTitleLabel.text = item.stringValue
                foundTitle = true
                print("Title = " + item.stringValue!)
            }
            if(!foundTitle)
            {
                songTitleLabel.text = "Unknown Artist"
            }
            
            if item.commonKey == "albumName" {
                albumLabel.text = item.stringValue
                print("Album = " + item.stringValue!)
                foundAlbum = true
            }
            
            if(!foundAlbum){
                albumLabel.text = "Unknown Album"
            }
            
            if item.commonKey  == "artwork" {
                if let image = UIImage(data: item.value as! Data) {
                    albumArtImageView.image = image
                    print(image.description)
                    foundAlbumArt = true
                }
            }
            if(!foundAlbumArt){
                    albumArtImageView.image = UIImage(named: "default.png")
            }
            
            
        }
        
        
        
    }
    
    
    
    
    
    func fastForwardHold(){
        forwardTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(ViewController.repeatForward), userInfo: nil, repeats: true)
        print("Forward Hold")
        
    }
    
    func repeatForward(){
        var time : TimeInterval = audio_player.currentTime
        time += 2.0 // forward 5 secs
        if (time > audio_player.duration)
        {
            
            // stop, track skip or whatever you want
        }
        else{
            audio_player.currentTime = time;
            
        }
    }
    
    
    func fastForwardRelease(){

            print("Forward Release")
            forwardTimer.invalidate()
    }
    
    
    
    
    
    
    func rewindHold(){
        rewindTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(ViewController.repeatRewind), userInfo: nil, repeats: true)
        
        print("Rewind Hold")
    }

    func repeatRewind(){
        var time : TimeInterval = audio_player.currentTime
        time -= 2.0 // rewind 5 secs
        if (time < 0 )
        {
            
            // stop, track skip or whatever you want
        }
        else{
            audio_player.currentTime = time;
            
        }
    }
    func rewindRelease(){
        print("Rewing Release")
       rewindTimer.invalidate()
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
  
    
    @IBAction func playButton(_ sender: UIButton) {

        
        if(audio_player.isPlaying){
            playButton.setImage(playImg, for: UIControlState.normal)
            audio_player.pause()
        }else{
            audio_player.play()
            playButton.setImage(pauseImg, for: UIControlState.normal)
        }
    }
    
    
    @IBAction func volumeAction(_ sender: UISlider) {
        audio_player.setVolume(sender.value, fadeDuration: 3)

    }
    
    
    @IBAction func seekAction(_ sender: UISlider) {
        audio_player.currentTime  = TimeInterval(songSlider.value)

    }
    
    
    
    func nextSong() {
        print("nextSong")
        if(currentIndex<songs.count-1)
        {
            currentIndex = currentIndex+1
        }else{
            currentIndex=0
        }
        updateSongDetails()
        audio_player.play()
        playButton.setImage(pauseImg, for: UIControlState.normal)
        
    }
    
    
    func prevSong() {
        print("prevSong")
        if(currentIndex>0){
            currentIndex = currentIndex-1
        }else{
            currentIndex = songs.count-1
        }
        updateSongDetails()
        audio_player.play()
        playButton.setImage(pauseImg, for: UIControlState.normal)
        
    }
    
    
    func updateSeekSlider(){
       
        songSlider.value = Float(audio_player.currentTime)
        if(songSlider.value >= (songSlider.maximumValue-1)){
            nextSong()
        
        }
        let min = Int(audio_player.currentTime/60)
        let sec = Int(audio_player.currentTime - TimeInterval(min*60))
        
        let playedTime : String = "\(min):\(sec)"
        currentSeekTimeLabel.text = playedTime
        
        
    }
    
}

