//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import "MyHTTPConnection.h"
#import "HTTPServer.h"
#import "HTTPResponse.h"
#import "AsyncSocket.h"
#import "SettingsData.h"

#import "WifiViewController.h"

@implementation MyHTTPConnection

/**
 * Returns whether or not the requested resource is browseable.
**/
- (BOOL)isBrowseable:(NSString *)path
{
	// Override me to provide custom configuration...
	// You can configure it for the entire server, or based on the current request
	
	return YES;
}


/**
 * This method creates a html browseable page.
 * Customize to fit your needs
**/
- (NSString *)_createBrowseableIndex:(NSString *)path
{
    //NSArray *array = [[NSFileManager defaultManager] directoryContentsAtPath:path];
    
    NSString *newPath = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Request Path : %@", newPath);
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newPath error:nil];
    
    NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head>"];
	[outdata appendFormat:@"<title>Files from %@</title>", server.name];
    [outdata  appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>"];
    
//    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:10x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    
    
    [outdata appendString:@"<style>html {} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:10x; margin-left:30%; margin-right:30%; border:3px groove #006600; padding:15px; } </style>"];
    
    
    [outdata appendString:@"</head>"];
    
    
    [outdata appendString:@"<style type=\"text/css\">"];
    
    [outdata appendString:@"th, td { font: 90% monospace; text-align: left;}th { font-weight: bold; padding-right: 14px; padding-bottom: 3px;}td {padding-right: 14px;}"];
    
    [outdata appendString:@"</style>"];
    
//    <style type="text/css">
//    a, a:active {text-decoration: none; color: blue;}
//a:visited {color: #48468F;}
//a:hover, a:focus {text-decoration: underline; color: red;}
//    body {background-color: #F5F5F5;}
//    h2 {margin-bottom: 12px;}
//    table {margin-left: 12px;}
//    th, td { font: 90% monospace; text-align: left;}
//    th { font-weight: bold; padding-right: 14px; padding-bottom: 3px;}
//    td {padding-right: 14px;}
//    td.s, th.s {text-align: right;}
//    div.list { background-color: white; border-top: 1px solid #646464; border-bottom: 1px solid #646464; padding-top: 10px; padding-bottom: 14px;}
//    div.foot { font: 90% monospace; color: #787878; padding-top: 4px;}
//    </style>
    
    
    [outdata appendString:@"<body>"];

//	[outdata appendFormat:@"<h1>Files from %@</h1>", server.name];
    [outdata appendString:@"<bq>iMusicPlayer's Docs folder.</bq>"];
    [outdata appendString:@"<p>"];
    [outdata appendString:@"<table summary=\"Directory Listing\" cellpadding=\"0\" cellspacing=\"0\">"];
    [outdata appendString:@"<thead><tr><th class=\"n\">Name</th><th class=\"m\">Last Modified</th><th class=\"s\">Size</th></tr></thead>"];
    [outdata appendString:@"<tbody>"];
    
        
    // .. 
    [outdata appendString:@"<tr><td class=\"n\"><a href=\"..\">..</a></td><td class=\"m\"></td><td class=\"s\"></td><td class=\"t\"></td></tr>"];

    // files
    for (NSString *fname in array)
    {
//        NSDictionary *fileDict = [[NSFileManager defaultManager] fileAttributesAtPath:[path stringByAppendingPathComponent:fname] traverseLink:NO];
        
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:fname] error:nil];

		//NSLog(@"fileDict: %@", fileDict);
        NSString *modDate = [[fileDict objectForKey:NSFileCreationDate] description] ;
		if ([[fileDict objectForKey:NSFileType] isEqualToString: @"NSFileTypeDirectory"]) 
            fname = [fname stringByAppendingString:@"/"];
        
//		[outdata appendFormat:@"<a href=\"%@\">%@</a>		(%8.1f Kb, %@)<br />\n", fname, fname, [[fileDict objectForKey:NSFileSize] floatValue] / 1024, modDate];
        
        [outdata appendFormat:@"<tr><td class=\"n\"><a href=\"%@\">%@</a></td><td class=\"m\">%@</td><td class=\"s\">%8.1f kByte</td><td class=\"t\"></td></tr>",fname ,fname, modDate, [[fileDict objectForKey:NSFileSize] floatValue] / 1024];

    }
    
    

    [outdata appendString:@"</tbody></table>"];

    
    [outdata appendString:@"</p>"];
	
	if ([self supportsPOST:path withSize:0])
	{
		[outdata appendString:@"<form action=\"\" method=\"post\" enctype=\"multipart/form-data\" name=\"form1\" id=\"form1\">"];
		[outdata appendString:@"<label>upload file"];
		[outdata appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
		[outdata appendString:@"</label>"];
		[outdata appendString:@"<label>"];
		[outdata appendString:@"<input type=\"submit\" name=\"button\" id=\"button\" value=\"Submit\" />"];
		[outdata appendString:@"</label>"];
		[outdata appendString:@"</form>"];
	}
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
}

- (NSString *)createBrowseableIndex:(NSString *)path
{
    //NSArray *array = [[NSFileManager defaultManager] directoryContentsAtPath:path];
    
    NSString *newPath = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Request Path : %@", newPath);
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newPath error:nil];
    
    NSMutableString *outdata = [NSMutableString new];
    
    [outdata appendString:@"<html>"];
    [outdata appendString:@"<meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\">"];
    [outdata appendString:@"<title>iMusicPlayer</title>"];
    [outdata appendString:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"/tmp/server.css\" />"];
    [outdata appendString:@"<link rel=\"stylesheet\" href=\"http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.5/themes/base/jquery-ui.css\" id=\"theme\">"];
    [outdata appendString:@"<link rel=\"stylesheet\" href=\"/tmp/jquery.fileupload-ui.css\">"];
    [outdata appendString:@"<script type=\"text/javascript\" src=\"/tmp/server.js\"></script>"];
    
    
//    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:10x;} </style>"];
    
    
    [outdata appendString:@"<style>html {} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:10x; margin-left:10%; margin-right:10%; border:3px groove #006600; padding:15px; } </style>"];

    
    [outdata appendString:@"<style type=\"text/css\">th, td { font: 90% monospace; text-align: left;}th { font-weight: bold; padding-right: 14px; padding-bottom: 3px;}td {padding-right: 14px;}</style>"];

    [outdata appendString:@"<style type=\"text/css\">a, a:active {text-decoration: none; color: blue;}a:visited {color: #48468F;}a:hover, a:focus {text-decoration: underline; color: red;}    body {background-color: #F5F5F5;}    h2 {margin-bottom: 12px;}    table {margin-left: 12px;}    th, td { font: 90% monospace; text-align: left;}    th { font-weight: bold; padding-right: 14px; padding-bottom: 3px;}    td {padding-right: 14px;}    td.s, th.s {text-align: right;}div.list { background-color: white; border-top: 1px solid #646464; border-bottom: 1px solid #646464; padding-top: 10px; padding-bottom: 14px;}    div.foot { font: 90% monospace; color: #787878; padding-top: 4px;}</style>"];
    
    
    [outdata appendString:@"</head>"];
    [outdata appendString:@"<body>"];
    [outdata appendString:@"<div id=\"header-\">"];
//    [outdata appendString:@"<div id=\"logo_gp\"></div>"];
//    [outdata appendString:@"</div>"];
//    [outdata appendString:@"<div id=\"main-\">"];
//    [outdata appendString:@"<div id=\"content-\">"];
//    [outdata appendString:@"<div id=\"content_top\"></div>"];
    [outdata appendString:@"<div id=\"content_mid\">"];
    [outdata appendString:@"<div id=\"upload\">"];
//    [outdata appendString:@"<div id=\"upload_header\">"];
//    [outdata appendString:@"<div id=\"upload_icon\"></div>"];
    
//    [outdata appendString:@"<b>Upload Files</b><br>"];
//    [outdata appendString:@"<div id=\"upload_label\">Upload your files</div>"];
//    [outdata appendString:@"</div>"];
    [outdata appendString:@"<div id=\"upload_btn\">"];
    
    [outdata appendString:@"<form class=\"upload\" action=\"Command/Send\" method=\"POST\" enctype=\"multipart/form-data\">"];    
//    [outdata appendString:@"<form class=\"upload\" action=\"\" method=\"POST\" enctype=\"multipart/form-data\">"];
    [outdata appendString:@"<div id=\"upload_choose_files\"><input height=\"100px\" type=\"file\" name=\"file\" multiple=\"multiple\" /></div>"];
    [outdata appendString:@"<button id=\"upload_add_files\">Add files</button>"];
    [outdata appendString:@"<div>Drag and drop Your Files Here</div>"];
    [outdata appendString:@"</form>"];
    
    
    [outdata appendString:@"<table class=\"upload_files\"></table>"];
    [outdata appendString:@"<table class=\"download_files\"></table>"];
    
    
    [outdata appendString:@"<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js\"></script>"];
    [outdata appendString:@"<script src=\"http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.5/jquery-ui.min.js\"></script>"];
    [outdata appendString:@"<script src=\"/tmp/jquery.fileupload.js\"></script>"];
    [outdata appendString:@"<script src=\"/tmp/jquery.fileupload-ui.js\"></script>"];
    
    
    
    [outdata appendString:@"<script>"];
    [outdata appendString:@"    $(function () {"];
    [outdata appendString:@"        $('.upload').fileUploadUI({"];
    [outdata appendString:@"        uploadTable: $('.upload_files'),"];
    [outdata appendString:@"        downloadTable: $('.download_files'),"];
    [outdata appendString:@"        buildUploadRow: function (files, index) {"];
    [outdata appendString:@"            var file = files[index];"];
    [outdata appendString:@"            return $("];
    [outdata appendString:@"                     '<tr style=\"display:none\">' +"];
    [outdata appendString:@"                     '<td style=\"font-family: Arial; font-size: 14px; color: #000\">' + file.name + '<\\/td>' +"];
    [outdata appendString:@"                     '<td class=\"file_upload_progress\"><div><\\/div><\\/td>' +"];
    [outdata appendString:@"                     '<td class=\"file_upload_cancel\">' +"];
    [outdata appendString:@"                     '<div class=\"ui-state-default ui-corner-all ui-state-hover\" title=\"Cancel\">' +"];
    [outdata appendString:@"                     '<span class=\"ui-icon ui-icon-cancel\"><\\/span>' +"];
    [outdata appendString:@"                     '<\\/div>' +"];
    [outdata appendString:@"                     '<\\/td>' +"];
    [outdata appendString:@"                     '<\\/tr>'"];
    [outdata appendString:@"                     );"];
    [outdata appendString:@"        },"];
    [outdata appendString:@"        buildDownloadRow: function (file) {"];
    [outdata appendString:@"            return $("];
    [outdata appendString:@"                     '<tr style=\"display:none\"><td>' + file.name + '<\\/td><\\/tr>'"];
    [outdata appendString:@"                     );"];
    [outdata appendString:@"        }"];
    [outdata appendString:@"        });"];
    [outdata appendString:@"    });"];
    [outdata appendString:@"</script>"];
     
     
    [outdata appendString:@"    </div>"];
    [outdata appendString:@"    </div>"];

//    [outdata appendString:@"    <div id=\"score_list\">"];
//    [outdata appendString:@"    <div id=\"score_list_header\">"];
//    [outdata appendString:@"    <div id=\"score_list_icon\"></div>"];
//    [outdata appendString:@"    <div id=\"score_list_label\">Scores already on your device</div>"];
//    [outdata appendString:@"    <div id=\"score_list_label_small\">(Click on title to download file)</div>"];
//    [outdata appendString:@"    </div>"];
//    [outdata appendString:@"    <div id=\"score_list_content\">"];
//    [outdata appendString:@"    <div id=\"fileList\">"];
//    [outdata appendString:@"    %FILELIST%"];
//    [outdata appendString:@"    </div>"];
//    [outdata appendString:@"    <div id=\"score_list_bottom\">"];
//    [outdata appendString:@"    <div id=\"score_count\">%SCORECOUNT%</div>"];
//    [outdata appendString:@"    <div id=\"delete_btn\">"];
//    [outdata appendString:@"    <form action="" method=\"get\">"];
//    [outdata appendString:@"    <input type=\"button\" name=\"score1\" value=\"Delete files\" onclick=\"deleteFiles();\" />"];
//    [outdata appendString:@"    </form>"];
//    [outdata appendString:@"    </div>"];
//    [outdata appendString:@"    </div>"];
//    [outdata appendString:@"    </div>	"];			
//    [outdata appendString:@"    </div>"];
    [outdata appendString:@"    </div>"];
//    [outdata appendString:@"    <div id=\"content_bottom\"></div>"];
//    [outdata appendString:@"    <div id=\"banner\">"];
//    [outdata appendString:@"    </div>"];
//    [outdata appendString:@"    </div>"];
//    [outdata appendString:@"	</div>"];
    
    
    
//    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:10x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];

    
    
    
    [outdata appendString:@"<b>Directory List</b><br><br>"];

//    [outdata appendString:@"<p></p>"];
    [outdata appendString:@"<table summary=\"Directory Listing\" cellpadding=\"0\" cellspacing=\"0\">"];
    [outdata appendString:@"<thead><tr><th class=\"n\">Name</th><th width=\"150px\"class=\"m\">Last Modified</th><th width=\"50px\" class=\"s\">Size</th></tr></thead>"];
    [outdata appendString:@"<tbody>"];
    
    
    // .. 
    [outdata appendString:@"<tr><td class=\"n\"><a href=\"..\"> .. </a></td><td class=\"m\"></td><td class=\"s\"></td><td class=\"t\"></td></tr>"];

    
    // files
    for (NSString *fname in array)
    {
        //        NSDictionary *fileDict = [[NSFileManager defaultManager] fileAttributesAtPath:[path stringByAppendingPathComponent:fname] traverseLink:NO];
        
        
        NSString *nPath = [path stringByAppendingPathComponent:fname];
        nPath = [nPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:nPath error:nil];
        
        NSString *modDate = [[fileDict objectForKey:NSFileCreationDate] description];
        modDate = [modDate stringByReplacingOccurrencesOfString:@"+0000" withString:@""];
        
        // directory
		if ([[fileDict objectForKey:NSFileType] isEqualToString: @"NSFileTypeDirectory"]) 
        { 
            
            if([fname isEqualToString:@"tmp"] == TRUE || [fname isEqualToString:@"Inbox"] == TRUE) continue;
            
            fname = [fname stringByAppendingString:@"/"];    
            [outdata appendFormat:@"<tr><td class=\"n\"><a href=\"%@\">+ %@</a></td><td class=\"m\">%@</td><td class=\"s\">-.- MB</td><td class=\"t\"></td></tr>\n",fname ,fname, modDate];
            
        }
        // file
        else{
        
        [outdata appendFormat:@"<tr><td class=\"n\"><a href=\"%@\">- %@</a></td><td class=\"m\">%@</td><td class=\"s\">%02.1f MB</td><td class=\"t\"></td></tr>\n",fname ,fname, modDate, [[fileDict objectForKey:NSFileSize] floatValue] / 1024 / 1024];
        }
    }
    
    [outdata appendString:@"</table>"];
    
    
    
    [self supportsPOST:path withSize:0];
//	if ([self supportsPOST:path withSize:0])
//	{
//		[outdata appendString:@"<form action=\"\" method=\"post\" enctype=\"multipart/form-data\" name=\"form1\" id=\"form1\">"];
//		[outdata appendString:@"<label>upload file"];
//		[outdata appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
//		[outdata appendString:@"</label>"];
//		[outdata appendString:@"<label>"];
//		[outdata appendString:@"<input type=\"submit\" name=\"button\" id=\"button\" value=\"Submit\" />"];
//		[outdata appendString:@"</label>"];
//		[outdata appendString:@"</form>"];
//	}
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
}



- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)relativePath
{
	if ([@"POST" isEqualToString:method])
	{
		return YES;
	}
	
	return [super supportsMethod:method atPath:relativePath];
}


/**
 * Returns whether or not the server will accept POSTs.
 * That is, whether the server will accept uploaded data for the given URI.
**/
- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength
{
	NSLog(@"Support POST:%@", path);
	
	dataStartIndex = 0;
	multipartData = [[NSMutableArray alloc] init];
    
	postHeaderOK = FALSE;
    
    NSLog(@"Multipart alloc : %d", [multipartData count]);
	
	return YES;
}


/**
 * This method is called to get a response for a request.
 * You may return any object that adopts the HTTPResponse protocol.
 * The HTTPServer comes with two such classes: HTTPFileResponse and HTTPDataResponse.
 * HTTPFileResponse is a wrapper for an NSFileHandle object, and is the preferred way to send a file response.
 * HTTPDataResopnse is a wrapper for an NSData object, and may be used to send a custom response.
**/
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	NSLog(@"httpResponseForURI: method:%@ path:%@", method, path);
	
	NSData *requestData = [(NSData *)CFHTTPMessageCopySerializedMessage(request) autorelease];
	
	NSString *requestStr = [[[NSString alloc] initWithData:requestData encoding:NSASCIIStringEncoding] autorelease];
	NSLog(@"\n=== Request ====================\n%@\n================================", requestStr);
	
	if (requestContentLength > 0)  // Process POST data
	{
		NSLog(@"processing post data: %llu", requestContentLength);
		
        if ([multipartData count] < 2) {
            
            for (NSObject *obj in multipartData) {
                 NSLog(@"multi = %@", obj);
            }
            
            
            return nil;
        
        }
		
		NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes]
													  length:[[multipartData objectAtIndex:1] length]
													encoding:NSUTF8StringEncoding];
		
		NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
		postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
		postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
		NSString* filename = [postInfoComponents lastObject];
		
        NSLog(@"postinfocomponents = %@", postInfoComponents);
        NSLog(@"filename = %@ ", filename);
        
		if (![filename isEqualToString:@""]) //this makes sure we did not submitted upload form without selecting file
		{
			UInt16 separatorBytes = 0x0A0D;
			NSMutableData* separatorData = [NSMutableData dataWithBytes:&separatorBytes length:2];
            [separatorData appendData:[multipartData objectAtIndex:0]];
            
            
//			int l = [separatorData length];
//			int count = 2;	//number of times the separator shows up at the end of file data

			// write a File 
            
//            NSData *postData = [multipartData lastObject];
            
            

            
//            NSLog(@"postData size = %d", [postData length]);
//            
//            if([postData writeToFile:[postInfoComponents objectAtIndex:0] atomically:YES] != TRUE){
//                NSLog(@"write fail");
//            }else{
//                NSLog(@"write done");
//            }
            
//            const void *data = malloc([postData length]);
//            data = [postData bytes];
//            
//            
//            for(int i = 0;i < [postData length];i++){
//                
//                
//                if (i % 16 == 0 ) {
//                    NSLog(@"\n %4d ", i);
//                }
//                NSLog(@"%02X ", *((unsigned char *)data + i));
//
//                
//            }
//

            
//			NSFileHandle* dataToTrim = [multipartData lastObject];
//			for (unsigned long long i = [dataToTrim offsetInFile] - l; i > 0; i--)
//			{
//				[dataToTrim seekToFileOffset:i];
//				if ([[dataToTrim readDataOfLength:l] isEqualToData:separatorData])
//				{
//					[dataToTrim truncateFileAtOffset:i];
//					i -= l;
//					if (--count == 0) break;
//				}
//			}
			
			NSLog(@"NewFileUploaded");
            [SettingsData sharedSettingsData].isUpdatedForFileTable = FALSE;
            
		}
		
		for (int n = 1; n < [multipartData count] - 1; n++)
			NSLog(@"%@", [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:n] bytes] length:[[multipartData objectAtIndex:n] length] encoding:NSUTF8StringEncoding]);
		
		[postInfo release];
        
        //?????????????
		[multipartData release];
		requestContentLength = 0;
		
	}
	
	NSString *filePath = [self filePathForURI:path];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		return [[[HTTPFileResponse alloc] initWithFilePath:filePath] autorelease];
	}
	else
	{
		NSString *folder = [path isEqualToString:@"/"] ? [[server documentRoot] path] : [NSString stringWithFormat: @"%@%@", [[server documentRoot] path], path];

		if ([self isBrowseable:folder])
		{
			//NSLog(@"folder: %@", folder);
			NSData *browseData = [[self createBrowseableIndex:folder] dataUsingEncoding:NSUTF8StringEncoding];
			return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
		}
	}
	
	return nil;
}


/**
 * This method is called to handle data read from a POST.
 * The given data is part of the POST body.
**/
- (void)processDataChunk:(NSData *)postDataChunk
{
	// Override me to do something useful with a POST.
	// If the post is small, such as a simple form, you may want to simply append the data to the request.
	// If the post is big, such as a file upload, you may want to store the file to disk.
	// 
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.

	NSLog(@"Chunk Size = %d", [postDataChunk length]);
	
    // 포스트 헤더가 아닐 경우 -> 단순헤더인경우
	if (!postHeaderOK)
	{
		UInt16 separatorBytes = 0x0A0D;
		NSData* separatorData = [NSData dataWithBytes:&separatorBytes length:2];
		
		int l = [separatorData length];
        
        // 포스트 데이터 길이 만큼 i 증가 
		for (int i = 0; i < [postDataChunk length] - l; i++)
		{
			NSRange searchRange = {i, l};
            
            // i 를 1 씩 증가 시켜 separatorByte =  0x0a0d 와 같으면 
			if ([[postDataChunk subdataWithRange:searchRange] isEqualToData:separatorData])
			{
                
				NSRange newDataRange = {dataStartIndex, i - dataStartIndex};
				dataStartIndex = i + l;
				i += l - 1;
				NSData *newData = [postDataChunk subdataWithRange:newDataRange];

				if ([newData length])
				{
                    // 새로운 멀티파트 데이터가 있을 경우 추가 
                    
                    if(multipartData == nil) {
                        multipartData = [[NSMutableArray alloc] init];
                        NSLog(@"Mulitpart = nil");   
                    }

                    
					[multipartData addObject:newData];
                    NSLog(@"Multipart added = %i", [newData length]);
                    
                    NSString *str = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
                    NSLog(@"Multipart : %d : %@",[multipartData count], str);
                    
                    
                }
				else
				{
                    NSLog(@"multipart data countinue");

                    
                    if(multipartData == nil) NSLog(@"Mulitpart = nil");
                    
                    
                    NSLog(@"multipart count = %d retain = %d", [multipartData count], [multipartData retainCount]);
                    
					postHeaderOK = TRUE;
					
					NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes] length:[[multipartData objectAtIndex:1] length] encoding:NSUTF8StringEncoding];
                    
                    
                    //NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes] length:[[multipartData objectAtIndex:1] length] encoding:0x80000940]; //euc-kr
                    
                    NSLog(@"postInfo = %@", postInfo);
                    
					NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
					postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
					postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
				
                
                    
                    
                    NSData *requestData = [(NSData *)CFHTTPMessageCopySerializedMessage(request) autorelease];
                    NSString *requestStr = [[[NSString alloc] initWithData:requestData encoding:NSASCIIStringEncoding] autorelease];
                
                    NSArray *strArray = [requestStr componentsSeparatedByString:@" "];
                    
                    NSLog(@"request Str = %@", requestStr);
                    
                    NSString *folder = [strArray objectAtIndex:1];
                    
                    // check Command Send
//                    if([fpath rangeOfString:@"ipod-library"].location == NSNotFound){

                    if ([folder rangeOfString:@"/Command/Send"].location != NSNotFound) {
                        folder = [folder stringByReplacingOccurrencesOfString:@"/Command/Send" withString:@""];
                    }
                    
                    
                    folder = [folder stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    NSLog(@"path = %@", folder);
                    
                    NSString* filename = [[[[server documentRoot] path] 
                                           stringByAppendingString:folder] 
                                          stringByAppendingPathComponent:[postInfoComponents lastObject]];
					
    
                    
                    NSLog(@"filename = %@", filename);
                    
                    NSRange fileDataRange = {dataStartIndex, [postDataChunk length] - dataStartIndex};
					
					[[NSFileManager defaultManager] createFileAtPath:filename contents:[postDataChunk subdataWithRange:fileDataRange] attributes:nil];
                    
					NSFileHandle *file = [[NSFileHandle fileHandleForUpdatingAtPath:filename] retain];
                    
					if (file)
					{
						[file seekToEndOfFile];
						[multipartData addObject:file];
                        NSLog(@"Multipart add file : %d", [multipartData count]);
					}
					
                    NSLog(@"multipart retain = %d", [multipartData retainCount]);
                    
					[postInfo release];
					
					break;
				}
			}
		}
	}
	else
	{
        // add data 
        NSLog(@"File Write : %d", [postDataChunk length]);
//		[(NSFileHandle*)[multipartData lastObject] writeData:postDataChunk];
    
        
	}
    
    
}

@end



