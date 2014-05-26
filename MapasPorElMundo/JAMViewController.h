//
//  JAMViewController.h
//  MapasPorElMundo
//
//  Created by Juan Antonio Martin Noguera on 25/05/14.
//  Copyright (c) 2014 cloudonmobile. All rights reserved.
//

@import MapKit;
#import <UIKit/UIKit.h>

@interface JAMViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
