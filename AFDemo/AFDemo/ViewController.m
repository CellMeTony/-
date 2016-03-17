//
//  ViewController.m
//  AFDemo
//
//  Created by Xue on 16/3/16.
//  Copyright © 2016年 QQ:565007544. All rights reserved.
//


/**
 *  
 第一种POST 表单编码提交形式 application/x-www-form-urlencoded
 适用于value=key的形式 且没有文件上传
 
 POST http://www.example.com HTTP/1.1
 Content-Type: application/x-www-form-urlencoded;charset=utf-8
 title=test&sub%5B%5D=1&sub%5B%5D=2&sub%5B%5D=3
 
 
 第二种提交格式 表单数据上传 multipart/form-data
 适用于 value=key，上传文件并指定参数 以及上传多种类型数据
 
 Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryrGKCBY7qhFd3TrwA
 
 ------WebKitFormBoundaryrGKCBY7qhFd3TrwA
 
 Content-Disposition: form-data; name="text"
 
 title
 
 ------WebKitFormBoundaryrGKCBY7qhFd3TrwA
 
 Content-Disposition: form-data; name="file"; filename="chrome.png"
 
 Content-Type: image/png
 
 PNG ... content of chrome.png ...
 
 ------WebKitFormBoundaryrGKCBY7qhFd3TrwA--
 
 
 
 
 
 */

#import "ViewController.h"

#import <AFNetworking.h>


@interface ViewController ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     请求序列化器是弄啥嘞
     Request serializers create requests from URL strings, encoding parameters as either a query string or HTTP body.
     序列化器会根据URL和编码后的参数 来构建一个 查询URL或HTTP body
      */
    
    //例如原始数据如下 即这些就是我们要传给AF的数据
     NSString *URLString = @"http://example.com";
     NSDictionary *parameters = @{@"foo": @"bar", @"baz": @[@1, @2, @3]};
     
     
     /*Query String Parameter Encoding（查询字符串编码）
     *  将参数编排后组建一个查询字符串 即GET请求URL
     */
     [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:parameters error:nil];
    //构建后的字符串如下
    //GET http://example.com?foo=bar&baz[]=1&baz[]=2&baz[]=3
    
    // AF内部拼接参数假想
    NSMutableArray *array = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *pair = [NSString stringWithFormat:@"%@=%@", key, obj];
        [array addObject:pair];
    }];
    
    NSString *string = [array componentsJoinedByString:@"&"];
    NSLog(@"string___%@", string);
    
     /*URL Form Parameter Encoding URL  表单编码
      * 将参数编排后组建成一个HTTP body 即POST请求的请求体
      */
     [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parameters error:nil];
    
    /*(请求行)POST http://example.com/
     *(请求头)Content-Type: application/x-www-form-urlencoded  此种就是value=key格式
     *
     *(请求数据)foo=bar&baz[]=1&baz[]=2&baz[]=3
     */
    
    
    /*JSON Parameter Encoding  JSON编码
     * 将参数编排后组建成一个HTTP body 即POST请求的请求体
     */
     [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parameters error:nil];
    
    /*(请求行)POST http://example.com/
     *(请求头)Content-Type: application/json
     *
     *(请求数据){"foo": "bar", "baz": [1,2,3]}
     */
    
    
//    [self af_get];
//    [self af_post];
    
//    [self af_upload];
//    [self af_multiPart_upload];
    
//    [self af_download];
    
    [self af_network];
    
}

/**
 *  @author XSQ, 16-03-16 15:03:09
 *
 *  监测网络是否连接 监测一个放在一个合适的地方（在整个应用程序生命周期内都可以进行监测）
 */
- (void)af_network
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


- (void)af_download
{
    [self createManager];
    
    NSURL *url = [NSURL URLWithString:@"http://video.dispatch.tc.qq.com/54371892/f0016kk9vtn.p202.1.mp4?sdtfrom=v1001&type=mp4&vkey=6F666206A25FD65E16B0B4E7DA011F51C3DB7F23DD0FDA77B0BF69E36E1DF7A86F2798874222463A56DFBDFDC1085FB767927F76ED68559DC8CA8AC42DD181B216AEF3BA37E6BCE2239CF6FF1DCF6EC1287511C1FA673811&platform=11&br=98&fmt=hd&sp=350&guid=0783F8AF1863B59E29EB8083E07F94A6EDC84017"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = task = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"%f", downloadProgress.fractionCompleted);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSLog(@"%@", response);
        return targetPath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
    
    [task resume];
}


/**
 *  表单提交
 *  适用于上传多个图片和多个参数并存的情况
 */
- (void)af_multiPart_upload
{
    //2.00wzHcQGqT4AUC3643826c37zGLsiC
    /**
     *  请求参数      必选    类型及范围               说明
     access_token	false	string          采用OAuth授权方式为必填参数，其他授权方式不需要此参数，OAuth授权后获得。
     
     status         true	string          要发布的微博文本内容，必须做URLencode，内容不超过140个汉字。
     
     pic            true	binary          要上传的图片，仅支持JPEG、GIF、PNG格式，图片大小小于5M。
     */
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    /**
     *  @author XSQ, 16-03-16 14:03:35
     *
     *  本方法构建了一个以multipart/form-data形式请求数据的请求对象 注意不要再使用它的HTTPBody和HTTPBodyStream
     *  @param method HTTP请求方法
     *  @param URL  HTTP请求地址
     *  @param parameters 要向HTTPBody中放的参数 value1=key1，value2=key2的形式
     *  @param block block提供了一个AFMultipartFormData类型的对象 如果有需要向HTTPBody中添加的文件 可以放在此处添加
     */
    
    NSDictionary *params = @{@"access_token":@"2.00wzHcQGqT4AUC3643826c37zGLsiC", @"status":@"讲完Multi-Part 再发微博"};
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:@"https://upload.api.weibo.com/2/statuses/upload.json" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        //构建文件URL 将文件添加到 HTTP body中并指定参数名
        NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"]];
        [formData appendPartWithFileURL:fileURL name:@"pic" error:nil];

        // 以appendPartWithFormData:name:形式添加了access_token参数
//        [formData appendPartWithFormData:[@"2.00wzHcQGqT4AUC3643826c37zGLsiC" dataUsingEncoding:NSUTF8StringEncoding] name:@"access_token"];

        // 以appendPartWithFormData:name:形式添加了status参数
//        [formData appendPartWithFormData:[@"下午上课发个微博" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
//                          [progressView setProgress:uploadProgress.fractionCompleted];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@______%@", response, responseObject);
                      }
                  }];
    
    [uploadTask resume];
}

//上传文件 适用于上传不需要指定参数的文件
- (void)af_upload
{
    [self createManager];
    
    //因为我们服务器返回的既不是JSON 也不是XML 所以这里使用混合
    _manager.responseSerializer = [AFCompoundResponseSerializer serializer];

    NSURL *URL = [NSURL URLWithString:@"http://localhost:8080/UploadFileServer/UploadServlet"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    NSURL *filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"]];
    
    NSURLSessionUploadTask *uploadTask = [_manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"Success: %@————————%@", response, string);
        }
    }];
    [uploadTask resume];
}

- (void)af_post
{
    [self createManager];
    
    //负责序列化请求 请求超时时间，请求头
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    //通过请求序列化添加请求头
    [requestSerializer setValue:@"794a5a140ecc24933911a42c37b5e773" forHTTPHeaderField:@"apikey"];
    //设置af的请求序列化
    _manager.requestSerializer = requestSerializer;
    
    //af默认支持AFJSONResponseSerializer 如果你使用XML或Plist则需要更改响应序列化
    //支持二进制
//    _manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    
    NSDictionary *parameters = @{@"query": @"大主宰", @"resource": @"spo_novel"};
    NSString *URLPath = @"http://apis.baidu.com/baidu_openkg/xiaoshuo_kg/xiaoshuo_kg";
    NSURLSessionDataTask *task = [_manager POST:URLPath parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSLog(@"%@", responseObject);


        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    [task resume];
}

- (void)af_get
{
    [self createManager];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"794a5a140ecc24933911a42c37b5e773" forHTTPHeaderField:@"apikey"];
    _manager.requestSerializer = requestSerializer;
    
    NSDictionary *parameters = @{@"consName":@"双子座", @"type":@"today"};
    
    NSString *URLPath = @"http://apis.baidu.com/bbtapi/constellation/constellation_query";
    
    NSURLSessionDataTask *task = [_manager GET:URLPath parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSLog(@"%@", dic[@"summary"]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    [task resume];
}

- (void)createManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [AFHTTPSessionManager manager];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
