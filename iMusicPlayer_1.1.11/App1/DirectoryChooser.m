//
//  DirectoryChooser.m
//  App1
//
//  Created by Han Eunsung on 11. 10. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DirectoryChooser.h"
#import "FileTable.h"
#import "DirCell.h"
#import "FSItem.h"
#import "SettingsData.h"
#import "Id3db.h"

@implementation DirectoryChooser

@synthesize ProcessView;
@synthesize ProcessViewTitle;
@synthesize ProcessViewNumber;
@synthesize CopyOrMove;
@synthesize makedirButton;
@synthesize pasteButton;
@synthesize selections;
@synthesize selectedPath;
@synthesize docPath;
@synthesize tableview;
@synthesize timer;
@synthesize fileIndex;
@synthesize filetable;
@synthesize files;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.tintColor = [UIColor purpleColor];
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
//    self.tableview.backgroundView.backgroundColor =  [UIColor clearColor];
//    self.tableview.separatorColor = [UIColor grayColor];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                initWithTitle:@"Edit"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(toggleEdit:)];
    self.navigationItem.leftBarButtonItem = editButton;
    [editButton release];

    
    NSLog(@"loaded");
    
    self.files = [[NSMutableArray alloc] initWithObjects:@"/", nil];
    
    // 파일 매니저 기본 도큐먼트 폴더 지정
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docPath = [docs objectAtIndex:0];
    fm = [NSFileManager defaultManager];
    [fm changeCurrentDirectoryPath:docPath];
    

    // 디렉토리 리스트 
    BOOL isDir;
    NSString *curDir = [NSString stringWithString:@""];
    NSDirectoryEnumerator* dirEnum = [fm enumeratorAtPath:docPath];
    while ((curDir = [dirEnum nextObject]) != nil){
        
        NSString *newDir = [NSString stringWithFormat:@"%@/%@", docPath, curDir];
        
        if([fm fileExistsAtPath:newDir isDirectory:&isDir] == isDir){
            
            // tmp dir pass
            if([curDir isEqualToString:@"tmp"] == TRUE 
               || [curDir isEqualToString:@"Inbox"] == TRUE) continue;
            
            [self.files addObject:[NSString stringWithFormat:@"/%@", curDir]];
//            NSLog(@"%@", curDir);
        }
    }
    
    // 셀 선택중이지 않으므로 비활성화 
    makedirButton.enabled = FALSE;
    pasteButton.enabled = FALSE;
    
    
    //[docs release];
    
}

- (void)viewDidUnload
{

    self.makedirButton = nil;
    self.pasteButton = nil;
    self.selections = nil;
    self.selectedPath = nil;
    self.docPath = nil;
    self.tableview = nil;
    self.timer = nil;
    self.filetable = nil;
    self.files = nil;
    
    
    
    [self setProcessView:nil];
    [self setProcessViewTitle:nil];
    [self setProcessViewNumber:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// IBAction

- (IBAction)createDirectory:(id)sender {
    
    
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Enter New Directory Name" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 55.0, 260.0, 30.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    [myAlertView addSubview:myTextField];
    
    myTextField.borderStyle = UITextBorderStyleBezel;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.font = [UIFont systemFontOfSize:18];
    
    
    [myTextField becomeFirstResponder];
    
    myAlertView.tag = 2000;
    [myAlertView show];
    [myAlertView release];
    [myTextField release];
    
    
}

- (IBAction)Cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)Paste:(id)sender {  
    
    NSLog(@"copy start");
    
    
    // 복사 진행상태는 타이머로 업데이트 
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    
    // 복사는 별도의 쓰레드에서 

    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(processThread)
                                                   object:nil];
    [myThread start];  // Actually create the thread
//    [NSThread detachNewThreadSelector:@selector(processThread) toTarget:self withObject:nil]; 
    

//    NSLog(@"paste : isupdate = %d", [SettingsData sharedSettingsData].isUpdatedForFileTable);
    [SettingsData sharedSettingsData].isUpdatedForFileTable = FALSE;
    
    // 복사진행중에 모든 터치 입력 중지 
    self.view.userInteractionEnabled = false;

    // 복사 진행 뷰 보기 
    ProcessView.hidden = FALSE;
    
}

- (void) processThread  {
    
    NSMutableArray *SuccessFiles = [NSMutableArray array];
    
    NSMutableArray *pathsArray = [NSMutableArray array];
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    //이곳에 처리할 코드를 넣는다.
    
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docPath = [docs objectAtIndex:0];
    fileIndex = 0;
    
    
    
    NSLog(@"Selected Path = %@", selectedPath);
    
    NSError *errCode = nil;    
    
    // true : copy, false: move
    if(CopyOrMove == TRUE){
        

        NSLog(@"copy");
        for (NSString *path in selections) {
            
            fileIndex++;
            NSString *newPath 
            = [NSString stringWithFormat:@"%@%@/%@", docPath, selectedPath, [path lastPathComponent]];
            
            // prevent self to self copy 자기폴더에 복사 방지
            NSString *oldPath = [path stringByReplacingOccurrencesOfString:docPath withString:@""];
            if ([oldPath isEqualToString:selectedPath]) {
                NSLog(@"self copy");
                
                NSString *msg = [NSString stringWithFormat:@"File : %@", [path lastPathComponent]];
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Don't copy to myself" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];    
                [myAlertView show];
                [myAlertView release];
            }
            
            // copy check
            else if([fm copyItemAtPath:path toPath:newPath error:&errCode] != TRUE){
               
                // copy fail
                NSString *msg = [NSString stringWithFormat:@"File : %@", [path lastPathComponent]];
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Can't copy file" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];    
                [myAlertView show];
                [myAlertView release];
                
                NSLog(@"Erro : %@", errCode);
            
            }
            
            // copy process
            else{
                
                [SuccessFiles addObject:path];
                NSLog(@"Copy Process : %@", [path lastPathComponent]);
            }
            
            // exit copy
            if(fileIndex == [selections count]){ 
                
                // send success file list
                [self addCacheFilesToDst:SuccessFiles Dst:[newPath stringByDeletingLastPathComponent]];
                [self dismissModalViewControllerAnimated:YES];
            }
            
            
        } // end for
    }
    else{
        
        NSLog(@"move");
        for (NSString *path in selections) {
            
            fileIndex++;
            NSString *newPath 
            = [NSString stringWithFormat:@"%@%@/%@", docPath, selectedPath, [path lastPathComponent]];
            
            
            // prevent self to self move
            NSString *oldPath = [path stringByReplacingOccurrencesOfString:docPath withString:@""];
            if ([oldPath isEqualToString:selectedPath]) {
                NSLog(@"self move");
                
                NSString *msg = [NSString stringWithFormat:@"File : %@", [path lastPathComponent]];
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Don't move to myself" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];    
                [myAlertView show];
                [myAlertView release];
            }
            
            // move process
            else if([fm moveItemAtPath:path toPath:newPath error:&errCode] != TRUE){
                
                NSString *msg = [NSString stringWithFormat:@"File : %@", [path lastPathComponent]];
                
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Can't move file" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];    
                //                myAlertView.tag = 10000;
                [myAlertView show];
                [myAlertView release];
                
                NSLog(@"Error : %@", errCode);
                
            }            
            
            // copy process
            else{
                
                [SuccessFiles addObject:path];
                NSLog(@"Move Process : %@", [path lastPathComponent]);
            }
            
            // exit copy
            if(fileIndex == [selections count]){ 
                
                // send success file list
                [self addCacheFilesToDst:SuccessFiles Dst:[newPath stringByDeletingLastPathComponent]];
                [self removeCacheFilesToDst:SuccessFiles Dst:[path stringByDeletingLastPathComponent]];
                [self dismissModalViewControllerAnimated:YES];
            }
            
            // add moved items path
            [pathsArray addObject:path];

            
        } // end for


        [self.filetable deleteFileFromTableInDatabase:pathsArray];
        NSLog(@"exit file action");
        
        // fsitem 오브젝트를 삭제하여 테이블 업데이트 구현 
        filetable.fsItem.children = nil;
        [filetable.fsItem children];        
        [filetable refreshFiles];
        
    }
    
    

    self.view.userInteractionEnabled = TRUE;
    
    [timer invalidate];
    ProcessView.hidden = TRUE;

    [autoreleasepool release];
    NSLog(@"Thread Done");
    [NSThread exit];
    
    
}



- (void) updateLabel{
    
    ProcessView.hidden = FALSE;
    ProcessViewTitle.text = (CopyOrMove) ? @"Copying..." : @"Moving...";        
    NSString *num = [NSString stringWithFormat:@"%d / %d", fileIndex, [selections count]];
//    NSLog(@"num = %@", num);
    ProcessViewNumber.text = num;

    
}

// alert delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 2000 && buttonIndex == 1){
        UITextField *TextField = [alertView.subviews objectAtIndex:5];
        
        // str check
        if([TextField.text isEqualToString:@"tmp"] == TRUE) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"Cause : Don't use the name" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            
            myAlertView.tag = 8000;
            [myAlertView show];
            [myAlertView release];
            return;   
        }

        
        
        if([TextField.text length] == 0) return;
        
        NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docPath = [docs objectAtIndex:0];
        
        NSString *newPath = [NSString stringWithFormat:@"%@%@/%@", docPath, selectedPath, TextField.text];
        [fm createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        
        
        // 디렉토리 리스트 
        [self.files release];
        self.files = [[NSMutableArray alloc] initWithObjects:@"/", nil];
        BOOL isDir;
        NSString *curDir = [NSString stringWithString:@""];
        NSDirectoryEnumerator* dirEnum = [fm enumeratorAtPath:docPath];
        while ((curDir = [dirEnum nextObject]) != nil){
            
            if([fm fileExistsAtPath:curDir isDirectory:&isDir] && isDir){
                
                if([curDir isEqualToString:@"tmp"] == TRUE) continue;
                [self.files addObject:[NSString stringWithFormat:@"/%@", curDir]];
                NSLog(@"%@", curDir);
            }
        }

        
        [self.tableview reloadData];
        
        
        int row  = 0;
        NSString *path = [NSString stringWithFormat:@"/%@", TextField.text];
        row = [self.files indexOfObject:path];
        NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
        
        // select cell
        [self.tableview selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];

        selectedPath = [self.files objectAtIndex:index.row];
        
//        [TextField release];
    }
    
}

// tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger row = [indexPath row];
	static NSString *MyIdentifier = @"Cell";

    DirCell *cell = (DirCell *)[tableview dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = (DirCell *)[[[NSBundle mainBundle] loadNibNamed:@"DirCell" owner:self options:nil] lastObject];        
    }
    
    NSString *cDir = [self.files objectAtIndex:row];
        
    cell.Label.text = [cDir lastPathComponent];
//    cell.Label.textColor = [UIColor whiteColor];
//    cell.backgroundView.backgroundColor = [UIColor clearColor];
//    cell.Label.backgroundColor = [UIColor clearColor];
    
    
    /////////////////////////////////////////////////////////////////////   
    // cell shift
    int numSubdir = [self checkDir:cDir];
    numSubdir = ([cDir isEqualToString:@"/"])? 0 : numSubdir;
    
//    NSLog(@"num = %d", numSubdir);
    
    CGRect p_label = cell.Label.frame;
    CGRect p_image = cell.CellImage.frame;
    
    p_label.origin.x += 20 * numSubdir;
    p_image.origin.x += 20 * numSubdir;
    
    cell.Label.frame     = p_label;
    cell.CellImage.frame = p_image;
    
    /////////////////////////////////////////////////////////////////////

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    makedirButton.enabled = TRUE;
    pasteButton.enabled = TRUE;    
    selectedPath = [self.files objectAtIndex:[indexPath row]];
    NSLog(@"path = %@", selectedPath);
        
}

- (int) checkDir:(NSString *)name{
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:name
                                                        options:0
                                                          range:NSMakeRange(0, [name length])];
    
    
    return numberOfMatches;
    
}


- (void)dealloc {
    [ProcessView release];
    [ProcessViewTitle release];
    [ProcessViewNumber release];
    
    
    [makedirButton release];
    [pasteButton release];
    [selections release];
    [selectedPath release];
    [docPath release];
    [tableview release];
    [timer release];
    [filetable release];
    
    
    [super dealloc];
}

// for cache control

- (void)addCacheFilesToDst:(NSArray *)successFiles Dst:(NSString *)path{
    
    NSLog(@"Copy Dst : %@", path);
    
    if([self checkPlaylist_plst:path] == TRUE){

        // loading dst folder cache
        NSString       *playlistFile = [path stringByAppendingPathComponent:@".cache.plst"];
        NSData         *decodedBook  = [NSData dataWithContentsOfFile:playlistFile];
        NSMutableArray *ID3Arrays    = [NSKeyedUnarchiver unarchiveObjectWithData:decodedBook];
    
        // add file caches to dst cache
        for (NSString *file in successFiles) {
            
            NSString *newFilePath = [NSString stringWithFormat:@"%@/%@", path, [file lastPathComponent]];
            
            NSLog(@"newfilepath : %@", newFilePath);
            Id3db *id3Item = [[Id3db alloc] initWithURL:[NSURL fileURLWithPath:newFilePath]];
            [id3Item id3ForFileAtPath];
            
            [ID3Arrays addObject:id3Item];
            
        }
        
        // save added cache file        
        NSData* encodedBook = [NSKeyedArchiver archivedDataWithRootObject:ID3Arrays];
        [encodedBook writeToFile:playlistFile atomically:YES];
        
        NSFileManager *fmgr = [[[NSFileManager alloc] init] autorelease];
        [fmgr changeCurrentDirectoryPath:path];
    
        if ([fmgr fileExistsAtPath:@".cache.plst"] == FALSE) {
            NSLog(@"Cache Save Fail");
        }else {
            [fm changeCurrentDirectoryPath:docPath];
            NSLog(@"Cache Save Done");
        }
    
    }else {
        
        NSLog(@"Dst folder cache doesn't exists");
    }
    
    
}

- (void)removeCacheFilesToDst:(NSArray *)successFiles Dst:(NSString *)path{
    
    NSLog(@"Remove Dst : %@", path);
    
    if([self checkPlaylist_plst:path] == TRUE){
        
        // loading dst folder cache
        NSString       *playlistFile = [path stringByAppendingPathComponent:@".cache.plst"];
        NSData         *decodedBook  = [NSData dataWithContentsOfFile:playlistFile];
        NSMutableArray *ID3Arrays    = [NSKeyedUnarchiver unarchiveObjectWithData:decodedBook];
        
        // remove file caches to dst cache
        for (NSString *file in successFiles) {
            
            NSString *newFilePath = [NSString stringWithFormat:@"%@/%@", path, [file lastPathComponent]];
            int idx = -1;
            for (Id3db *item in ID3Arrays) {
                
                NSString *itemPath 
                = [[item.path stringByReplacingOccurrencesOfString:@"file://localhost/private" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                // find from array
                if ([itemPath isEqualToString:newFilePath]) {
                    idx = [ID3Arrays indexOfObject:item];
                    break;
                }
            }
            
            // remove id3 item
            if (idx > -1) [ID3Arrays removeObjectAtIndex:idx];
            
        }
        
        // save added cache file        
        NSData* encodedBook = [NSKeyedArchiver archivedDataWithRootObject:ID3Arrays];
        [encodedBook writeToFile:playlistFile atomically:YES];
        
        NSFileManager *fmgr = [[[NSFileManager alloc] init] autorelease];
        [fmgr changeCurrentDirectoryPath:path];
        
        if ([fmgr fileExistsAtPath:@".cache.plst"] == FALSE) {
            NSLog(@"Cache Save Fail");
        }else {
            [fm changeCurrentDirectoryPath:docPath];
            NSLog(@"Cache Save Done");
        }
        
        // reassign new array
        self.filetable.id3dbArray = ID3Arrays;
        
    }else {
        
        NSLog(@"Dst folder cache doesn't exists");
    }
    
    
}

- (BOOL)checkPlaylist_plst:(NSString *)path{
    
    NSFileManager *fmgr = [[[NSFileManager alloc] init] autorelease];
    [fmgr changeCurrentDirectoryPath:path];
    
    if ([fmgr fileExistsAtPath:@".cache.plst"] == FALSE) {
        
        NSLog(@"Cache doesn't Exists");
        [fmgr changeCurrentDirectoryPath:docPath];
        
        return FALSE;        
    }
    
    NSLog(@"Cache Exists");
    return TRUE;
    
}

@end
