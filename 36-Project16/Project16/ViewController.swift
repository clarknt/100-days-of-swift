//
//  ViewController.swift
//  Project16
//

import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    // challenge 2
    let mapTypes = ["hybrid": MKMapType.hybrid, "hybridFlyover": MKMapType.hybridFlyover, "mutedStandard": MKMapType.mutedStandard, "satellite": MKMapType.satellite, "satelliteFlyover": MKMapType.satelliteFlyover, "standard": MKMapType.standard]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics", wikipediaUrl: "https://en.wikipedia.org/wiki/London")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago", wikipediaUrl: "https://en.wikipedia.org/wiki/Oslo")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8546, longitude: 2.3508), info: "Often called the City of Light", wikipediaUrl: "https://en.wikipedia.org/wiki/Paris")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it", wikipediaUrl: "https://en.wikipedia.org/wiki/Rome")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself", wikipediaUrl: "https://en.wikipedia.org/wiki/Washington,_D.C.")

        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
        // challenge 2
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map type", style: .plain, target: self, action: #selector(selectMapType))
    }
    
    // challenge 2
    @objc func selectMapType() {
        let ac = UIAlertController(title: "Map type", message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        for mapType in Array(mapTypes.keys).sorted(by: <) {
            ac.addAction(UIAlertAction(title: mapType, style: .default, handler: mapTypeSelected))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(ac, animated: true)
    }

    // challenge 2
    func mapTypeSelected(action: UIAlertAction) {
        guard let title = action.title else { return }

        if let type = mapTypes[title] {
            mapView.mapType = type
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // If the annotation isn't from a capital city, it must return nil so iOS uses a default view.
        guard annotation is Capital else { return nil }
        
        // Define a reuse identifier. This is a string that will be used to ensure we reuse annotation views as much as possible.
        let identifier = "Capital"
        
        // Try to dequeue an annotation view from the map view's pool of unused views.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            // If it isn't able to find a reusable view, create a new one using
            // MKPinAnnotationView and sets its canShowCallout property to true. This
            // triggers the popup with the city name.
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            // Create a new UIButton using the built-in .detailDisclosure type. This is a small blue "i" symbol with a circle around it.
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        }
        else {
            // If it can reuse a view, update that view to use a different annotation.
            annotationView?.annotation = annotation
            
            // challenge 1
            // note: this will change the color to green only once the view is reused
            if let pinView = annotationView as? MKPinAnnotationView {
                pinView.pinTintColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        let placeName = capital.title
        let placeInfo = capital.info
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        // challenge 3
        ac.addAction(UIAlertAction(title: "Wikipedia", style: .default, handler: { [weak self] _ in
            self?.openWikipedia(url: capital.wikipediaUrl)
        }))
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // challenge 3
    func openWikipedia(url: String) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
            vc.website = url
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

