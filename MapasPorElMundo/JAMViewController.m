//
//  JAMViewController.m
//  MapasPorElMundo
//
//  Created by Juan Antonio Martin Noguera on 25/05/14.
//  Copyright (c) 2014 cloudonmobile. All rights reserved.
//

#import "JAMViewController.h"

@interface JAMViewController () {
    CLLocationManager *locationManager;
    CLLocation *lastKnowPostion;
    id<MKOverlay> rutaOverlay;
    
}

@end

@implementation JAMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mapView.delegate  = self;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPostion:)];
    
    tap.numberOfTapsRequired = 1;
   
    [self.mapView addGestureRecognizer:tap];
    [self warmUpGPS];
}

//    lastKnowPostion = [[CLLocation alloc]initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
//    MKCoordinateRegion regionCurrentUser ;
//    regionCurrentUser.center.latitude = lastKnowPostion.coordinate.latitude;
//    regionCurrentUser.center.longitude = lastKnowPostion.coordinate.longitude;
//
//
//
//    [self.mapView setRegion:regionCurrentUser animated:YES];
-(void)tapPostion:(UITapGestureRecognizer *)gesture{
    
    
    // detectamos el numero de taps
    // 1 -> geocoding
    // 2 -> Rutas
    
    
    CGPoint point = [gesture locationInView:self.mapView];
    
    
    CLLocationCoordinate2D coordinates = [self.mapView convertPoint:point
                                               toCoordinateFromView:self.mapView];
 
    switch (gesture.numberOfTouches ) {
        case 2:
        {
            // GEolocalización de las coordenadas al cp, calle, zona ...
            
            CLGeocoder *geocoder = [[CLGeocoder alloc]init];
            
            [geocoder reverseGeocodeLocation:lastKnowPostion completionHandler:^(NSArray *placemarks, NSError *error) {
                
                if (!error) {
                    
                    CLPlacemark *placeMark = [placemarks objectAtIndex:0];
                    NSLog(@"%@ ", placeMark.addressDictionary);

                }
                
            }];
            
        }
            break;
        case 1:{
            // calculamos rutas
            
            // tenemos que configurar un request para calcular la ruta, necesitamos las coordenadas de inicio y fin + tipo de transporte
            
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
            request.transportType = MKDirectionsTransportTypeWalking;
        
            // covertir las coordenadas LAt/LONG  en MKMapItem
            request.destination = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:coordinates addressDictionary:nil]];
            
            request.source =[[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:lastKnowPostion.coordinate addressDictionary:nil]];
            
            
            MKDirections * directions = [[MKDirections alloc]initWithRequest:request];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                
                if (!error) {
                    
                    MKRoute *route = response.routes[0];
                    [self drawRoute:route];
                }
            }];
            
        }
            break;
        default:
            break;
    }
    
        
}

- (void)drawRoute:(MKRoute *)route{
    
    if (rutaOverlay) {
        [self.mapView removeOverlay:rutaOverlay];
    }
    
    [self.mapView addOverlay:route.polyline];


}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    rutaOverlay = overlay;
    
    
    MKPolylineRenderer *renderLine = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    
    renderLine.strokeColor = [UIColor redColor];
    renderLine.lineWidth = 3.0;
    
    return renderLine;
    
    
    
  
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - corelocation


-(void)warmUpGPS{
    
    locationManager = [[CLLocationManager alloc]init];
    
    // configurar la precision de la captura de la posicion
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    
    
    locationManager.delegate = self;
    //iniciar la captura de la señal del GPS
    [locationManager startUpdatingLocation];
    
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    // aqui sabemos si tenemos permiso para usar GPS
    
    NSLog(@"el estado es---> %d", status  );
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // obtener la posicion
    // KVC
//    NSLog(@"LAT %f -- LONG %f", [[[[locations firstObject]objectForKey:@"coordinate"]valueForKey:@"latitude"]doubleValue],
//          [[[[locations firstObject]objectForKey:@"coordinate"]valueForKey:@"longitude"]doubleValue]);

    
    lastKnowPostion = [locations firstObject];
    NSLog(@"LAT %f -- LONG %f", lastKnowPostion.coordinate.latitude, lastKnowPostion.coordinate.longitude);
    //es un buen sitio para detener la localización
    [locationManager stopUpdatingLocation];
    
    
    // actualizar el mapa
    
    MKCoordinateRegion regionCurrentUser ;
    regionCurrentUser.center.latitude = lastKnowPostion.coordinate.latitude;
    regionCurrentUser.center.longitude = lastKnowPostion.coordinate.longitude;
    
    
    
    [self.mapView setRegion:regionCurrentUser animated:YES];
    
    
    
    
}





#pragma mark - Mapkit



- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    return nil;
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    
}



#pragma mark - lipiar al salir

-(void)dealloc{
    
    self.mapView = nil;
    
}



















@end
