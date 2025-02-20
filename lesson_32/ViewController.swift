//
//  ViewController.swift
//  lesson_32
//
//  Created by Сергей Недведский on 18.02.25.
//

import AVFoundation
import CoreLocation
import SnapKit
import MapKit
import UIKit
import AVKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private let mapView = MKMapView()

    private var player: AVAudioPlayer?

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Constansts.viewString", for: .normal)
        button.backgroundColor = .blue
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func configureUI() {
//        view.addSubview(mapView)
//        mapView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        mapView.showsUserLocation = true

//        let recognizer = UILongPressGestureRecognizer(
//            target: self, action: #selector(longPressedDetected))
//        mapView.addGestureRecognizer(recognizer)

        view.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let playAudio = UIAction { _ in
            self.playVideo2()
        }
        playButton.addAction(playAudio, for: .touchUpInside)
    }
    
    private func playAudio() {
        guard let url = Bundle.main.url(forResource: "Big City Nights", withExtension: "mp3") else { return }
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            self.player?.stop()
            //MARK: - Hello DEVELOP
            self.player?.stop()
        }
    }
    
    private func playVideo() {
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "mp4") else { return }
        
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        //MARK: - Player
        player.play()
    }
    
    private func playVideo2() {
        guard let url = URL(string: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_30mb.mp4") else { return }
        
        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true){
            controller.player?.play()
        }
    }

    @objc func longPressedDetected(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began { return }
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

        //        let annotation = MKPointAnnotation()
        //        annotation.coordinate = coordinate
        //        annotation.title = "annotaion"
        //        annotation.subtitle = "sub annotation"
        //        mapView.addAnnotation(annotation)
        getAddress(from: coordinate)
    }

    func getAddress(from center: CLLocationCoordinate2D) {
        let geocoder: CLGeocoder = CLGeocoder()
        let location: CLLocation = CLLocation(
            latitude: center.latitude, longitude: center.longitude)

        geocoder.reverseGeocodeLocation(
            location,
            completionHandler: { (placemarks, error) in
                if error != nil {
                    print(
                        "reverse geodcode fail: \(error!.localizedDescription)")
                    return
                }

                guard let placemarks = placemarks else { return }
                if placemarks.count > 0 {
                    let pm = placemarks.first!
                    print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
                    var addressString: String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }

                    print(addressString)

                    let point = MKPointAnnotation()
                    point.coordinate = center
                    point.title = addressString
                    self.mapView.addAnnotation(point)

                }
            })

    }

    func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        if let coordinates = locations.last?.coordinate {
            if let location = locations.last {
                print("Coordinates: \(coordinates)")
                mapView.centerToLoaction(location)
            }
        }
    }
}

extension MKMapView {
    fileprivate func centerToLoaction(
        _ location: CLLocation, regionRadius: CLLocationDistance = 1000
    ) {
        let region = MKCoordinateRegion(
            center: location.coordinate, latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(region, animated: true)
    }
}
