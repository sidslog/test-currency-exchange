//
//  CurrencyView.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "CurrencyView.h"

@interface CurrencyView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *available;
@property (weak, nonatomic) IBOutlet UILabel *rate;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, copy) void (^onTextChange)(NSString *);
@property (nonatomic, copy) void (^onBecomeFirstResponder)();

@end

@implementation CurrencyView

+ (instancetype) loadFromNib {
  return [[NSBundle bundleForClass:CurrencyView.class] loadNibNamed:NSStringFromClass(CurrencyView.class) owner:nil options:nil].firstObject;
}

- (void) configure: (NSString *) code
         available: (NSString *) available
              rate: (NSString *) rate
            amount: (NSString *) amount
       fromIsValid: (BOOL) fromIsValid
      onTextChange: (void (^)(NSString *))onTextChange
onBecomeFirstResponder: (void (^)())onBecomeFirstResponder
{
  [self configure:code available:available rate:rate amount:amount fromIsValid:fromIsValid];
  self.onTextChange = onTextChange;
  self.onBecomeFirstResponder = onBecomeFirstResponder;
}

- (void) configure: (NSString *) code
         available: (NSString *) available
              rate: (NSString *) rate
            amount: (NSString *) amount
            fromIsValid: (BOOL) fromIsValid
{
  self.name.text = code;
  self.available.text = available;
  self.rate.text = rate;
  if (!self.textField.isFirstResponder) {
    self.textField.text = amount;
  }
  self.available.textColor = fromIsValid ? [UIColor whiteColor] : [UIColor redColor];
}

- (BOOL)becomeFirstResponder {
  [self.textField becomeFirstResponder];
  return YES;
}

- (BOOL)isFirstResponder {
  return self.textField.isFirstResponder;
}

- (IBAction)onEditingChanged:(id)sender {
  if (self.onTextChange) {
    self.onTextChange(self.textField.text);
  }
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (self.onBecomeFirstResponder) {
    self.onBecomeFirstResponder();
  }
  if (self.onTextChange) {
    self.onTextChange(self.textField.text);
  }
  return YES;
}

@end
