//
//  STCASRStreamNetworkingManager.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 04.06.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCASRStreamNetworkingManager.h"
#import "STCNetworkingManager+Requests.h"
#import "STCNetworkingManager+Error.h"
#import "STCASRURLManager.h"

@interface STCASRStreamNetworkingManager()

@property (nonatomic) NSString *package;

@end

@implementation STCASRStreamNetworkingManager

-(NSString *)method {
    return @"POST";
}

-(NSDictionary *)body {
    return @{ @"package_id":self.package,
                    @"mime":@"audio/L16" };
}

-(NSString *)package {
    return ( _package==nil ) ? @"CommonRus" : _package;
}

-(NSString *)request {
    return STCASRURLManager.asrRecognizeStream;
}

-(void)recognize {
    NSLog(@"POST %@",[STCASRURLManager asrRecognizeStream]);
    NSURLSessionDataTask *task = [self taskRequestWithTypeRequest:@"POST"
                                                         withBody:self.body
                                                     forURLString:self.request
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSURLResponse * _Nullable response,
                                                                    NSError * _Nullable error) {
                                                    
                                                    NSError *responseError = [self checkError:error
                                                                                 withResponse:response
                                                                                withErrorData:data];
                                                    if (responseError) {
                                                        self.completionHandler(responseError, nil);
                                                        return ;
                                                    }
                                                    
                                                    self.result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                    
                                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                    self.transactionId = [httpResponse allHeaderFields][@"X-Transaction-Id"];
                                                    self.completionHandler(nil, self.result);
                                                }];
    [task resume];
}

-(void)startStreamWithCompletionHandler:(CompletionHandler)completionHandler {
    self.package = nil;
    self.completionHandler = completionHandler;
    [self obtainWithCompletionHandler:completionHandler];
}

-(void)startStreamWithPackage:(NSString *)package
        withCompletionHandler:(CompletionHandler)completionHandler {
    self.package = package;
    self.completionHandler = completionHandler;
    [self obtainWithCompletionHandler:completionHandler];
}

-(void)closeStreamWithCompletionHandler:(CompletionHandler)completionHandler {
    self.completionHandler = completionHandler;
    NSLog(@"DELETE %@",STCASRURLManager.asrRecognizeStream);
    NSURLSessionDataTask *task = [self taskRequestWithTypeRequest:@"DELETE"
                                                         withBody:self.body
                                                     forURLString:self.request
                                                completionHandler:^(NSData * _Nullable data,
                                                             NSURLResponse * _Nullable response,
                                                                   NSError * _Nullable error) {
                                                    
                                                    NSError *responseError = [self checkError:error
                                                                                 withResponse:response
                                                                                withErrorData:data];
                                                    if (responseError) {
                                                        self.completionHandler(responseError, nil);
                                                        return ;
                                                    }
                                                    
                                                    self.result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                    
                                                    [self finalizeRequest];
                                                }];
    [task resume];
}

@end
