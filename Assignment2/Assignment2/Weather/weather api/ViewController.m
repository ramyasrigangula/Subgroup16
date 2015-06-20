//
//  ViewController.m
//  weather api
//
//  Created by Gangula, Ramya Sri (UMKC-Student) on 6/19/15.
//  Copyright (c) 2015 Gangula, Ramya Sri (UMKC-Student). All rights reserved.
//


#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *location;
@property (strong, nonatomic) IBOutlet UITextField *country;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getWeatherConditions:(id)sender {
    NSLog(@"starting the application");
    NSString *locationName=self.location.text;
    NSString *countryName=self.country.text;
    NSLog(@"locationName%@",locationName);
    NSLog(@"countryName%@",countryName);
    NSString *urlString=[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@,%@",locationName,countryName];
    
    NSLog(@"URL String%@", urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [responseObject objectForKey:@"main"];
        
        NSString *temperature= [dict objectForKey:@"temp"];
        
        NSString *grid_level=[dict objectForKey:@"grid_level"];
        
        NSString *humidiity=[dict objectForKey:@"humidity"];
        
        NSString *pressure=[dict objectForKey:@"pressure"];
        NSString *sealevel=[dict objectForKey:@"sea_level"];
        NSString *temp_min=[dict objectForKey:@"temp_min"];
        NSString *temp_max=[dict objectForKey:@"temp_max"];
        
        NSArray *array=[responseObject objectForKey:@"weather"];
        NSDictionary *dict2=[array objectAtIndex:0];
        NSString *description=[dict2 objectForKey:@"description"];
        
        
        
        
        NSLog(@"Temperature: %@", temperature);
        NSLog(@"temp_min: %@",temp_min);
        
        NSLog(@"description: %@",description);
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@",error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];
}

@end

