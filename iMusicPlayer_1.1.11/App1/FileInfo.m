//
//  FileInfo.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 1. 22..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileInfo.h"
#import "Id3db.h"
#import "Settings.h"
#import <sqlite3.h>

@implementation FileInfo

@synthesize fsItem;
@synthesize infoDic;
@synthesize infoKeys;
@synthesize attribute;
@synthesize total_size;
@synthesize total;
@synthesize id3dbArray;

@synthesize docInteractionController;




- (void)dealloc{
    
    
    [self.docInteractionController release];
    [fsItem release];
    [infoKeys release];
    [infoDic release];
    [attribute release];
    [super dealloc];
}


- (id)initWithFilePath:(FSItem *)item{

    fsItem = [item retain]; 
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


    
    self.navigationItem.title = @"File Info";
    
    self.attribute = [NSDictionary dictionaryWithDictionary:self.fsItem.attributes];
    
    self.infoDic 
    = [[NSDictionary alloc] initWithObjectsAndKeys:
       [NSArray arrayWithObjects:
        @"Type",
        @"File", 
        @"FileSize",
        @"Creation Date",
        @"Modification Date", nil], 
       @"key 1",
       [NSArray arrayWithObjects:
        @"Change Name",
        @"Open with other Apps ...",
        nil], 
       @"key 2",
       nil];
    
//    infoDic = fsItem.attributes;
    self.infoKeys = [self.infoDic allKeys];
    
    
    if ([self.attribute.fileType isEqualToString:@"NSFileTypeDirectory"]) {
        total_size = 0;
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        NSString *curDir = [NSString stringWithString:@""];
        NSDirectoryEnumerator* dirEnum = [fm enumeratorAtPath:fsItem.path];
        
        while ((curDir = [dirEnum nextObject]) != nil){
            
            
            if([fm fileExistsAtPath:curDir isDirectory:&isDir] == isDir)continue;
            
            NSString *newPath = [fsItem.path stringByAppendingPathComponent:curDir];
            NSDictionary *att = [fm attributesOfItemAtPath:newPath error:nil];
            
            NSNumber *numSize = [att objectForKey:NSFileSize];
            
            total_size += [numSize longLongValue];
            total++;
            
        }
    }else{
        total = 1;
        total_size = self.attribute.fileSize;
    }
    
}

- (void)dismissThis{
    
    [self dismissModalViewControllerAnimated:YES];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.infoKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSString *key = [self.infoKeys objectAtIndex:section];
    NSArray *array = [self.infoDic objectForKey:key];
    
    return [array count];
    
//    return [self.infoKeys count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return self.fsItem.filename;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSString *key = [self.infoKeys objectAtIndex:section];
    NSArray *arr = [self.infoDic objectForKey:key];
    NSString *str = [arr objectAtIndex:row];    
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    cell.textLabel.text = str;
    
    
    if(section == 0){
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;                
        
        switch (row) {
                
            case 0:                
                
                if ([self.attribute.fileType isEqualToString:@"NSFileTypeDirectory"]) {
                    cell.detailTextLabel.text = @"Directory";
                }else{
                    
                    cell.detailTextLabel.text = [self.fsItem.filename pathExtension];
                }
                
                break;
                
            case 1:
                
                cell.textLabel.text = @"Files";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", total];
                
                break;
            case 2:
            {
                
                // dir
                if ([self.attribute.fileType isEqualToString:@"NSFileTypeDirectory"]) {
                    
                    
                    NSString *size = [NSString stringWithFormat:@"%llu", total_size];
                    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
                    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSString *formatedSize = [formatter stringFromNumber:[formatter numberFromString:size]];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Byte", formatedSize];
                    cell.textLabel.text = @"TotalSize";
                    
                }
                // file
                else{
                    
                    NSString *size = [NSString stringWithFormat:@"%llu", total_size];
                    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
                    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSString *formatedSize = [formatter stringFromNumber:[formatter numberFromString:size]];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Byte", formatedSize];
                }

            }
                break;
                
            case 3:
                cell.detailTextLabel.text = [[self.attribute.fileCreationDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                break;
                
            case 4:

                cell.detailTextLabel.text = [[self.attribute.fileModificationDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                break;

            default:
                break;
        }
        
    }
    
    else if(section == 1){
        
        switch (row) {
            case 0:
                if ([self.attribute.fileType isEqualToString:@"NSFileTypeDirectory"]) {
                    cell.textLabel.text = @"Change Directory Name";
                }else{
                    cell.textLabel.text = @"Change File Name";
                }
                break;
                
                
            case 1:
                
                if ([self.attribute.fileType isEqualToString:@"NSFileTypeDirectory"]) {

                    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
                    cell.textLabel.textColor = [UIColor grayColor];
                
                }
                
            default:
                break;
        }
        
        
        
        
    }
    
    return cell;
}

- (void)alertChangeName{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Type New Name" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 55.0, 260.0, 30.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    [myAlertView addSubview:myTextField];
    
    myTextField.borderStyle = UITextBorderStyleBezel;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.font = [UIFont systemFontOfSize:18];
    [myTextField becomeFirstResponder];
    
    myTextField.text = self.fsItem.filename;
    
    
    myAlertView.tag = 10000;
    [myAlertView show];
    [myAlertView release];
    [myTextField release];
    
    // set focus
    

    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 10000 && buttonIndex == 1){

        UITextField *TextField = [alertView.subviews objectAtIndex:5];
        // text null check
        if([TextField.text length] == 0) return;
        NSString *newName = TextField.text;

        // file manager
        NSArray *docs 
        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath 
        = [docs objectAtIndex:0];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm changeCurrentDirectoryPath:docPath];
        
        NSString *oldPath = [NSString stringWithString:self.fsItem.path];
        NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
        
        NSLog(@"new path : %@", [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName]);
        
        // rename
        NSError *errCode = nil;    
        if([fm moveItemAtPath:self.fsItem.path toPath:newPath error:&errCode] == FALSE){
            
            // copy fail
            NSString *msg = [NSString stringWithFormat:@"File : %@", newName];
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Can't change name" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];    
            [myAlertView show];
            [myAlertView release];
            
            NSLog(@"Erro : %@", errCode);
            
            return;
       
        };
        
        
        // db open
        NSString *dbFile = [docPath stringByAppendingPathComponent:@"/tmp/data.sqlite3"];
        sqlite3 *database;
        if (sqlite3_open([dbFile UTF8String], &database) != SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(0, @"Failed to open database");
        }
        
        
        BOOL isDir;
            
        // dir delete
        if([fm fileExistsAtPath:newPath isDirectory:&isDir] && isDir){
            
            NSLog(@"this is a dir");
//            NSString *path = [newPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", docPath] withString:@""];
            
            NSString *path = [oldPath stringByReplacingOccurrencesOfString:
                       [docPath stringByAppendingString:@"/"] 
                                                         withString:@""];
            NSString *query = [NSString stringWithFormat:@"DELETE FROM ID3DATA WHERE PATH = \"%@\"", path];
            NSLog(@"DirDelete : Query = %@", query);        
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            }
            
            if (sqlite3_step(stmt) != SQLITE_DONE){
                NSLog(@"Delete Dir Error");
            }else{
                NSLog(@"Delete Dir Success");
            }
            sqlite3_finalize(stmt);
            
            
            
            // 하위 디렉토리 리스트 
            NSError *er;
            BOOL isDir;
            NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:newPath];
            
            NSString *curDir = [NSString stringWithString:@"/"];
            while ((curDir = [dirEnum nextObject]) != nil){
                
                curDir = [newPath stringByAppendingPathComponent:curDir];
                
                // dir check, if not dir, pass
                if([fm fileExistsAtPath:curDir isDirectory:&isDir] != isDir) continue;
                    
                NSString *cacheFile = [curDir stringByAppendingPathComponent:@".cache.plst"];
                NSLog(@"%@", cacheFile);
                
                // .cache.plst exists check, if cache file doesn't exists, pass
                if([fm fileExistsAtPath:cacheFile] != TRUE) continue;
                
                NSLog(@"%@", cacheFile);                                        
                if([fm removeItemAtPath:cacheFile error:&er] == FALSE){
                    // when remove error
                    NSLog(@"err : %@", [er description]);
                };


            }

            
        }
        // file delete
        else{
            
            NSString *path = [newPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", docPath] withString:@""];
            NSString *query = [NSString stringWithFormat:@"DELETE FROM ID3DATA WHERE FILEPATH = \"%@\"", path];
            NSLog(@"FileDelete : Query = %@", query);        
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) != SQLITE_OK) {
                //                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
                NSLog(@"%@", sqlite3_errmsg(database));
                
            }
            
            if (sqlite3_step(stmt) != SQLITE_DONE){
                NSLog(@"Delete File Error");
            }else{
                NSLog(@"Delete File Success");
            }
            sqlite3_finalize(stmt);
            
            // cache delete
            NSString *curDir    = [newPath stringByDeletingLastPathComponent];
            NSString *cacheFile = [curDir stringByAppendingPathComponent:@".cache.plst"];
            
            NSError *err;
            if([fm fileExistsAtPath:cacheFile] == TRUE){
                
                if([fm removeItemAtPath:cacheFile error:&err] == TRUE){
                    NSLog(@"Delete cache file");                    
                }else{
                    NSLog(@"Delete fail cache file");
                }

            }else{
                NSLog(@"No cache file");
            }

            
        }
        
        SettingsData *sets = [SettingsData sharedSettingsData];
        sets.isUpdatedForFileTable = FALSE;

//        // if dir
//        BOOL isDir;
//        if([fm fileExistsAtPath:newPath isDirectory:&isDir] && isDir){
//            
//            // ex) /var/mobile/Applications/F9764823-9595-43FC-B2D4-16ECEB46BC0A/Documents/test -> test/
//            NSString *conditionPath 
//            = [newPath stringByReplacingOccurrencesOfString:[docPath stringByAppendingString:@"/"] withString:@""];
//            
//            oldPath = [oldPath stringByReplacingOccurrencesOfString:[docPath stringByAppendingString:@"/"] withString:@""];            
//            NSString *query 
//            = [NSString stringWithFormat:@"UPDATE ID3DATA SET "
//               @"PATH     = REPLACE(PATH, \"%@\", \"%@\") ,"
//               @"FILEPATH = REPLACE(FILEPATH, \"%@\", \"%@\") "
//               @"WHERE PATH LIKE \"%@%%\""
//               , oldPath
//               , conditionPath
//               , oldPath
//               , conditionPath
//               , oldPath];
//            
//            NSLog(@"query : %@", query);
//
//            sqlite3_stmt *stmt;
//            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) != SQLITE_OK) {
//                NSLog(@"Rename Error Directory");
//            }
//            
//            if (sqlite3_step(stmt) != SQLITE_DONE){
//                NSLog(@"Rename Dir  Error");
//            }else{
//                NSLog(@"Rename Dir Success");
//            }
//            sqlite3_finalize(stmt);
//            
//            
//            // query check
//            
//            query = [NSString stringWithFormat:@"SELECT FILEPATH FROM ID3DATA WHERE PATH LIKE \"%@%%\"", oldPath];
//            NSLog(@"check query : %@", query);
//            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK) {
//                
//                
//                while (sqlite3_step(stmt) == SQLITE_ROW) {
//                    
//                    char *path  = (char *)sqlite3_column_text(stmt, 0);
//                    NSString *str = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
//                    NSLog(@"path : %@", str);
//                    
//                }
//                
//            }
//            sqlite3_finalize(stmt);
//            
//            //
//            // cache delete
//            //
//            
//            // 하위 디렉토리 리스트 
//            NSError *er;
//            BOOL isDir;
//            NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:newPath];
//            
//            NSString *curDir = [NSString stringWithString:@"/"];
//            while ((curDir = [dirEnum nextObject]) != nil){
//                
//                curDir = [newPath stringByAppendingPathComponent:curDir];
//                
//                // dir check, if not dir, pass
//                if([fm fileExistsAtPath:curDir isDirectory:&isDir] != isDir) continue;
//                    
//                NSString *cacheFile = [curDir stringByAppendingPathComponent:@".cache.plst"];
//                NSLog(@"%@", cacheFile);
//                
//                // .cache.plst exists check, if cache file doesn't exists, pass
//                if([fm fileExistsAtPath:cacheFile] != TRUE) continue;
//                    
//                
//                NSLog(@"%@", cacheFile);                                        
//                if([fm removeItemAtPath:cacheFile error:&er] == FALSE){
//                    // when remove error
//                    NSLog(@"err : %@", [er description]);
//                };
//
//
//            }
//
//        }
//        
//        // if file
//        else{
//            
//            // db rename
//            NSString *conditionPath 
//            = [newPath stringByReplacingOccurrencesOfString:[docPath stringByAppendingString:@"/"] withString:@""];
//            oldPath = [oldPath stringByReplacingOccurrencesOfString:[docPath stringByAppendingString:@"/"] withString:@""];            
//            
//            NSString *query 
//            = [NSString stringWithFormat:@"UPDATE ID3DATA SET FILEPATH = \"%@\", FILENAME = \"%@\" WHERE FILEPATH = \"%@\""
//               , conditionPath
//               , [newPath lastPathComponent]
//               , oldPath];
//            
//            NSLog(@"query : %@", query);
//
//            sqlite3_stmt *stmt;
//            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) != SQLITE_OK) NSLog(@"Rename Error File");
//            
//            
//            if (sqlite3_step(stmt) != SQLITE_DONE){      
//                NSLog(@"Rename File Error");
//            }else{
//                NSLog(@"Rename File Success");
//            }
//            
//            sqlite3_finalize(stmt);
//         
//            // cache delete
//            NSString *curDir = [self.fsItem.path stringByDeletingLastPathComponent];
//            NSString *cacheFile = [curDir stringByAppendingPathComponent:@".cache.plst"];
//            
//            NSError *err;
//            if([fm fileExistsAtPath:cacheFile] == TRUE){
//                
//                if([fm removeItemAtPath:cacheFile error:&err] == TRUE){
//                    NSLog(@"Delete cache file");                    
//                }else{
//                    NSLog(@"Delete fail cache file");
//                }
//
//            }else{
//                NSLog(@"No cache file");
//            }
//
//        }
        
        sqlite3_close(database);

        // 파일일경우 캐쉬, id3db 변경? 
        // 디렉토리일경우 폴더캐쉬삭제 id3 삭제 후 파일탭으로 돌아올때 업데이트
        
        // set new fsitem
        self.fsItem = [FSItem fsItemWithDir:[newPath stringByDeletingLastPathComponent] fileName:newName];;

        [self.tableView reloadData];
        
    }
    
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (section == 1) {
        
        switch (row) {
            case 0:
                [self alertChangeName];
                break;
                
            case 1:
            {
                
                // if a file is dir then cancel
                if ([self.attribute.fileType isEqualToString:@"NSFileTypeDirectory"]) break;

                
                NSURL *FileUrl = [NSURL fileURLWithPath:fsItem.path];
                
                NSLog(@"Select File Name : %@", FileUrl);

                // open document interfaction
                self.docInteractionController 
                    = [UIDocumentInteractionController interactionControllerWithURL:FileUrl];
                self.docInteractionController.delegate = self;
                
                [self.docInteractionController presentOptionsMenuFromRect:self.tabBarController.view.frame
                                                                  inView:self.tabBarController.view
                                                                animated:YES];
                
                             
            }   
                
                
                break;
                
            default:
                break;
        }
    }
    
    
}


#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}


@end


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

