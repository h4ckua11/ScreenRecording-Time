@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

// Set two vars - Should be self explanatory
BOOL isRecording;
NSString *recordingTime;

@interface _UIStatusBarStringView : UILabel
@property (nullable, nonatomic, copy) NSString *text; 
@end

// This is responsible for settings all the text in the StatusBar

%hook _UIStatusBarStringView

- (instancetype)initWithFrame:(CGRect)arg1 {
    // Adding Observer to get notifications posted with a specific name
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRecordingTime) name:@"com.h4ckua11.screenrecordingtime" object:nil];
    
    return %orig;
}

// Set the Text of the StatusBar
-(void)setText:(id)text {

    // Check if it recording and if the text contains ":" cause text could also contain the carriere and the battery percentage
    if(isRecording){
        if([text containsString:@":"]){
            text = recordingTime;
        }
    }

    %orig;
}

// New method to set the StatusBar Text
%new
-(void)updateRecordingTime {
    if([self.text containsString:@":"]){
        [self setText:recordingTime];
    }
}

%end

// Get if Recording is active

%hook RPScreenRecorder

// Method that updates every 0.5 seconds with the current recording time
-(void)recordingTimerDidUpdate:(id)arg1 {
    if(![recordingTime isEqualToString:arg1]){
        recordingTime = arg1;
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.h4ckua11.screenrecordingtime" object:nil userInfo:nil];
    }
	%orig;
}

%end

%hook RPControlCenterClient

-(void)startRecordingWithHandler:(/*^block*/id)arg1 {
	%orig;
	isRecording = YES;
}

%end

%hook RPControlCenterModule
-(void)didStopRecordingOrBroadcast {
  %orig;
  isRecording = NO;
}
%end

%ctor
{
    //Got this code from https://github.com/gilshahar7/DNDMyRecording/
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"])
    {
        NSBundle* moduleBundle = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle"];
        if (!moduleBundle.loaded)
            [moduleBundle load];
        %init;
    }
}