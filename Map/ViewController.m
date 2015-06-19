//
//  ViewController.m
//  Map
//
//  Created by MAEDA HAJIME on 2014/04/04.
//  Copyright (c) 2014年 MAEDA HAJIME. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ViewController.h"

@interface ViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mkMap;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mak
// 地名検索（ジオコーティング）
- (IBAction)searchPlace:(UITextField *)sender {
    
    CLGeocoder *gc = [CLGeocoder new];
    
    // ジオコーティング実行
    
    CLGeocodeCompletionHandler hnd = ^(NSArray *placemarks, NSError *error){
        
        // 位置の設定
        CLPlacemark *pm = (CLPlacemark *) placemarks[0];
        CLLocationCoordinate2D lc = pm.location.coordinate;
        
        // 領域の確定
        MKCoordinateSpan cs = MKCoordinateSpanMake(0.01, 0.01);
        
        // 地図の表示
        MKCoordinateRegion cr = MKCoordinateRegionMake(lc, cs);
        [self.mkMap setRegion:cr animated:YES];
        
    };
    
    [gc geocodeAddressString:sender.text completionHandler:hnd];
    
}

#pragma mark - MKMapViewDelegate Method

// 地図表示の変更後

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    // 中央位置の取得
    CLLocationCoordinate2D crd = mapView.centerCoordinate;
    
    // 領域の取得
    MKCoordinateSpan spn = mapView.region.span;
    
    // 表示
    NSLog(@"位置{%.2f, %.2f}, 領域{%.2f, %.2f}",
          crd.latitude,      crd.longitude,
          spn.latitudeDelta, spn.longitudeDelta);
}

// アノテーション表示の管理
-(MKAnnotationView *)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation {
    
    // 再利用可能オブジェクト取得
    MKPinAnnotationView *pa = (MKPinAnnotationView *)
    [mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    
    if (pa == nil) {
        // オブジェクト作成
        pa = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        // 設定（ドロップ時のアニメーション）
        pa.animatesDrop = NO;
        // 設定（ピンの色）
        pa.pinColor = MKPinAnnotationColorPurple;
        // 設定（ピンタップ時の情報表示）
        pa.canShowCallout = YES;
        // 設定（ピン画像）
        pa.image = [UIImage imageNamed:@"pin.png"];
    }

    return pa;
}


#pragma mark - ActionMetod Method

- (IBAction)change3D:(id)sender {
    // 地図の中心地点
	CLLocationCoordinate2D centerCoordinate =
    CLLocationCoordinate2DMake(34.687277, 135.525856);
	
	// カメラのセット地点
	CLLocationCoordinate2D fromEyeCoordinate =
    CLLocationCoordinate2DMake(34.689659, 135.518367);
	
	// 500m上空からの視点
	CLLocationDistance eyeAltitude = 500.0;
	
	// カメラをセット
	MKMapCamera *camera =
    [MKMapCamera cameraLookingAtCenterCoordinate:centerCoordinate
                               fromEyeCoordinate:fromEyeCoordinate
                                     eyeAltitude:eyeAltitude];
	[self.mkMap setCamera:camera animated:YES];
}

// マップタイプ選択
- (IBAction)selectStyle:(UISegmentedControl *)sender {
    
    //self.mkMap.mapType = sender.selectedSegmentIndex;
    
    // ボタン判定
    switch (sender.selectedSegmentIndex ) {
        case 0:          // 標準地図
            self.mkMap.mapType = MKMapTypeStandard;
            break;
        case 1:          // 航空写真
            self.mkMap.mapType = MKMapTypeSatellite;
            break;
        case 2:          // ハイブリット
            self.mkMap.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

// トラッキングモード選択
- (IBAction)selectTracking:(UISegmentedControl *)sender {
    
    // ボタン判定
    switch (sender.selectedSegmentIndex) {
        case 0:          // 追跡なし
            [self.mkMap setUserTrackingMode:MKUserTrackingModeNone
                                   animated:YES];
            
            // 現在地印の消去
            self.mkMap.showsUserLocation = NO;
            
            break;
        case 1:          // 位置追跡
            [self.mkMap setUserTrackingMode:MKUserTrackingModeFollow
                                   animated:YES];
            break;
        case 2:          // 位置、方位追跡
            [self.mkMap setUserTrackingMode:MKUserTrackingModeFollowWithHeading
                                   animated:YES];
            break;
            
        default:
            break;
    }
}

// 地図のロングプレス時
- (IBAction)dorpPin:(UILongPressGestureRecognizer *)sender {
    
//    if (sender.state == UIGestureRecognizerStateRecognized) {
//        
//        //NSLog(@"%s", __func__);
//        
//        // MapView取得
//        MKMapView *mv = (MKMapView *)sender.view;
//        
//        // 位置情報を取得
//        CGPoint pnt = [sender locationInView:mv];
//        CLLocationCoordinate2D crd = [mv convertPoint:pnt
//                                 toCoordinateFromView:mv];
//        
//        // アノテーション追加
//        {
//            MKPointAnnotation *ant = [MKPointAnnotation new];
//            
//            // 設定（位置）
//            ant.coordinate = crd;
//            // 設定（表示テキスト）
//            ant.title = @"タイトル";
//            ant.subtitle = @"サブタイトル";
//            
//            [mv addAnnotation:ant];
//            
//        }
//        
//    }

    // ジェスチャーの確定判定
	if (sender.state == UIGestureRecognizerStateRecognized) {
		
		// MapView取得
		MKMapView *mv = (MKMapView *) sender.view;
		
		// 位置情報を取得
		CGPoint pnt = [sender locationInView:mv];
		CLLocationCoordinate2D crd = [mv convertPoint:pnt
								 toCoordinateFromView:mv];
		
		// 標高値の取得
		/*
		 国土地理院「電子国土ポータル」のAPIを使用
		 　http://portal.cyberjapan.jp/help/development.html#api
		 */
		
		// HTTPリクエスト設定
		NSString *url = [NSString stringWithFormat:
						 @"http://cyberjapandata2.gsi.go.jp/"
						 @"general/dem/scripts/getelevation.php"
						 @"?lon=%f&lat=%f&outtype=JSON",
						 crd.longitude, crd.latitude];
		NSLog(@"%@", url);
		
		NSURLRequest *req =
        [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                     timeoutInterval:3.0];
		
		// サーバ同期接続
		NSData *res =
        [NSURLConnection sendSynchronousRequest:req
                              returningResponse:nil
                                          error:nil];
		
		// JSONデータ取得
		NSDictionary *dir =
        [NSJSONSerialization JSONObjectWithData:res
                                        options:NSJSONReadingAllowFragments
                                          error:nil];
		
		// アノテーション追加
		{
			MKPointAnnotation *ant = [MKPointAnnotation new];
			
			// 設定（位置：緯度・経度を指定）
			ant.coordinate = crd;
			
			// 設定（表示テキスト）
			ant.title    = [NSString stringWithFormat:
							@"標高：%@m", dir[@"elevation"]];
			ant.subtitle = [NSString stringWithFormat:
							@"データソース：%@", dir[@"hsrc"]];
			
			[mv addAnnotation:ant];
		}
	}
}

@end
