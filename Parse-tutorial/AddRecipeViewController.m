//
//  AddRecipeViewController.m
//  Parse-tutorial
//
//  Created by Asuka Nakagawa on 2016-06-06.
//  Copyright © 2016 Asuka Nakagawa. All rights reserved.
//

#import "AddRecipeViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "Recipe.h"
#import "MBProgressHUD.h"

@interface AddRecipeViewController ()
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet PFImageView *recipeImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *prepTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *ingredientsTextField;

@end

@implementation AddRecipeViewController

//- (id)initWithStyle:(UIViewStyle)style {
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameTextField.delegate = self;
    _prepTimeTextField.delegate = self;
    _ingredientsTextField.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"Successfully saved the recipe" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
//            
//            // Notify table view to reload the recipes from Parse cloud
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
//            
//            // Dismiss the controller
//            [self dismissViewControllerAnimated:YES completion:nil];
//            
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
//            
//        }
//        
//    }];
//}

- (IBAction)save:(id)sender {
    PFObject *recipe = [PFObject objectWithClassName:@"Recipe"];
    [recipe setObject:self.nameTextField.text forKey:@"name"];
    [recipe setObject:self.prepTimeTextField.text forKey:@"prepTime"];
    NSArray *ingredients = [self.ingredientsTextField.text componentsSeparatedByString:@","];
    [recipe setObject:ingredients forKey:@"ingredients"];
    
    // Recipe image
    NSData *imageData = UIImageJPEGRepresentation(self.recipeImageView.image, 0.8);
    NSString *filename = [NSString stringWithFormat:@"%@.png", self.nameTextField.text];
    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
    [recipe setObject:imageFile forKey:@"imageFile"];
    // show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading";
    [hud show:YES];
    // upload recipe to Parse
    [recipe saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
        
        if (!error) {
            // show success msg
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Upload complete" message:@"Successfully saved the recipe" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
        }
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setRecipeImageView:nil];
    [self setNameTextField:nil];
    [self setPrepTimeTextField:nil];
    [self setIngredientsTextField:nil];
    [super viewDidUnload];
}


#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - PhotoLibary delegate
- (void)showPhotoLibary {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return;
    }
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc]init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // Displays saved pictures from the Camera Roll album.
    mediaUI.mediaTypes = @[(NSString*) kUTTypeImage];
    // Hides the controls for moving & scaling pictures
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = self;
    
    [self.navigationController presentViewController:mediaUI animated:YES completion:nil];
}

// when user taps "add"Button at the first time, we call photoLibrary
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self showPhotoLibary];
    }
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    //selected image is then assigned to the image view of the new recipe.
    self.recipeImageView.image = originalImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}



@end
