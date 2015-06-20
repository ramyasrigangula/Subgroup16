//
//  ViewController.m
//  SKSpeechSynthesizerExample
//
//  Created by Saroj Sharma on 06/05/14.
//  Copyright (c) 2014 Saroj Sharma. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
@interface ViewController ()
@property(nonatomic,retain) IBOutlet UITextView *tvTextToSpeak;
@property(nonatomic,retain) IBOutlet UISegmentedControl *scVoice;
@property(nonatomic,retain) IBOutlet UISegmentedControl *scSpeed;
@property(nonatomic,retain) IBOutlet UIButton *btnStartSpeaking;
@property(nonatomic,retain) IBOutlet UIButton *btnStopSpeaking;
@property(nonatomic,retain) IBOutlet UIButton *btnPauseSpeaking;
@property(nonatomic,retain) AVSpeechSynthesizer *synthesizer;
@property(nonatomic,retain) NSString *voice;
@property(nonatomic,assign) float speed;
@property (strong, nonatomic) IBOutlet UITextField *location;
@property (strong, nonatomic) IBOutlet UITextField *country;
@end

@implementation ViewController
@synthesize synthesizer = _synthesizer;

- (void)viewDidLoad{
    
    // Initialze with defaults
    _voice = @"en-US";
    _speed = .09f;
}

- (IBAction)startSpeaking:(id)sender{
    
    NSLog(@"starting the application");
    NSString *locationName=self.location.text;
    NSString *countryName=self.country.text;
    NSLog(@"locationName%@",locationName);
    NSLog(@"countryName%@",countryName);
    NSString *messageBody;
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
        NSLog(@"Msg Body: %@", messageBody);
        messageBody = [NSString stringWithFormat:@"Temperature %@,Minimum Temperature %@,description %@",temperature,temp_min,description];
        
        
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

    
    
    if ([_synthesizer isPaused]) {
        [_synthesizer continueSpeaking];
    }else{
        //[self speakText:_tvTextToSpeak.text];
        NSLog(@"message Body: %@",messageBody);
        [self speakText:messageBody];
    }
}

- (IBAction)pauseSpeaking:(id)sender{
    if ([_synthesizer isSpeaking]) {
        [_synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (IBAction)stopSpeaking:(id)sender{
    if ([_synthesizer isSpeaking]) {
        [_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (IBAction)segmentControlValueChanged:(id)sender{
    UISegmentedControl *control = (UISegmentedControl*)sender;
    if (control == _scVoice) {
        switch (control.selectedSegmentIndex) {
            case 0:
                _voice = @"en-US";
                break;
            case 1:
                _voice = @"ar-SA";
                break;
            case 2:
                _voice = @"fr-FR";
                break;
            case 3:
                _voice = @"zh-CN";
                break;
        }
    }else{
        switch (control.selectedSegmentIndex) {
            case 0:
                _speed = .25f;
                break;
            case 1:
                _speed = .50f;
                break;
            case 2:
                _speed = 1.0f;
                break;
            case 3:
                _speed = 2.0f;
            break;
        }
    }
}

- (void)speakText:(NSString*)text{
    
    if(_synthesizer == nil)
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    _synthesizer.delegate = self;
    
    AVSpeechUtterance *utterence = [[AVSpeechUtterance alloc] initWithString:text];
    utterence.rate = _speed;
    
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:_voice];
    [utterence setVoice:voice];
    
    [_synthesizer speakUtterance:utterence];
}

// Enable all buttons at once

- (void)enableAllButton{
    _btnStartSpeaking.enabled = YES;
    _btnPauseSpeaking.enabled = YES;
    _btnStopSpeaking.enabled = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return YES;
    }
    return YES;
}

#pragma mark- AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    [self enableAllButton];
    _btnStartSpeaking.enabled = NO;
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{

    // Enable/Disable buttons accordingly
    
    [self enableAllButton];
    _btnPauseSpeaking.enabled = NO;
    _btnStopSpeaking.enabled = NO;
    
    // Set the text back in its original state.
    
    NSString *string = [utterance speechString];
    [_tvTextToSpeak setText:string];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    // Enable/Disable buttons accordingly
    
    [self enableAllButton];
    _btnPauseSpeaking.enabled = NO;
    _btnStopSpeaking.enabled = NO;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    // Enable/Disable buttons accordingly
    
    [self enableAllButton];
    _btnStartSpeaking.enabled = NO;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{

    // Enable/Disable buttons accordingly
    
    [self enableAllButton];
    _btnPauseSpeaking.enabled = NO;
    _btnStopSpeaking.enabled = NO;
    
    // Set the text back in its original state.
    
    NSString *string = [utterance speechString];
    [_tvTextToSpeak setText:string];

}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    
    // Get the text
    NSString *text = [utterance speechString];
    
    // apply attribute
    
    NSMutableAttributedString * all = [[NSMutableAttributedString alloc] initWithString:text];
    [all addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:characterRange];
    
    // set the attributed text to textView
    
    [_tvTextToSpeak setAttributedText:all];
}


@end
