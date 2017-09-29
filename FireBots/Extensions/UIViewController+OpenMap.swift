//
//  UIViewController+OpenMap.swift
//  ParentsHero
//
//  Created by Ant on 24/12/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import MapKit

extension UIViewController {
        
    func openDirections(to coordinate: CLLocationCoordinate2D, label: String? = nil) {
        // If Google Maps not available then just open regular Apple Maps
        if !UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            openDirectionsAppleMaps(to: coordinate, label: label)
            return
        }
        // Let the user choose
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Open in Maps", comment: ""), style: .default, handler: { _ in
            self.openDirectionsAppleMaps(to: coordinate, label: label)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Open in Google Maps", comment: ""), style: .default, handler: { _ in
            self.openDirectionsGoogleMaps(to: coordinate)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    private func openDirectionsAppleMaps(to coordinate: CLLocationCoordinate2D, label: String?) {
        let coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let item = MKMapItem(placemark: placemark)
        item.name = label
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func openDirectionsGoogleMaps(to coordinate: CLLocationCoordinate2D) {
        let dest = String(format: "%.6f,%.6f", coordinate.latitude, coordinate.longitude)
        UIApplication.shared.openURL(URL(string: "comgooglemaps://?saddr=&daddr=\(dest)")!)
    }
    
}
