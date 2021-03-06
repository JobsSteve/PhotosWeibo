#define PrefFilePath @"/var/mobile/Documents/PhotosWeibo/PhotosWeibo.plist" 

CFRunLoopRef loop;
CFRunLoopTimerRef timer;

@interface dataParser : NSObject<NSXMLParserDelegate>
@property(nonatomic, retain) id parseData;
@end

@implementation dataParser
@synthesize parseData;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	self.parseData = [string copy];
}
@end


static void timer_callback(CFRunLoopTimerRef timer, void *info)
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL find = [fileManager fileExistsAtPath: PrefFilePath];
	id 	udid = [[UIDevice currentDevice] uniqueIdentifier];
	if(udid && find){
		NSString* requestString = [@"http://change.59igou.com/AuthorService.asmx/JY_UDID_DATABASE?soft_id=2&UDID=" stringByAppendingString: udid];
		NSURL* url = [NSURL URLWithString: requestString];     
		NSMutableURLRequest* request = [NSMutableURLRequest new];     
		[request setURL:url];     
		[request setHTTPMethod:@"GET"]; 
		NSURLResponse* response;
		NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error:nil];  
		id parser = [[NSXMLParser alloc] initWithData: data];
		id content = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
		id parseDelegate = [[dataParser alloc] init];
		[parser setDelegate: parseDelegate];
		[parser parse];
		id flag = [parseDelegate parseData];
		if([flag isEqualToString: @"-1"]){
			[fileManager removeItemAtPath: PrefFilePath error: NULL];
		}else if([flag isEqualToString: @"1"]){
			CFRunLoopRemoveTimer(loop, timer, kCFRunLoopCommonModes);
			CFRelease(timer);
		}
	}
	
}

int main(int argc, char **argv, char **envp) {
	// Loop ad infinitum
	timer = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent(), (1.0 * 20.0), 0, 0, &timer_callback, NULL);
	loop = CFRunLoopGetCurrent();
	CFRunLoopAddTimer(loop, timer, kCFRunLoopCommonModes);
	CFRunLoopRun();
	return 0;
}

// vim:ft=objc
