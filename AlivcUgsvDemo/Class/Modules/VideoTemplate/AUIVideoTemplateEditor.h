//
//  AUIVideoTemplateEditor.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/9/22.
//

#import "AUIFoundation.h"
#import "AUIVideoTemplateItem.h"
#import "AUIVideoTemplateOutputParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateEditor : AVBaseViewController

@property (nonatomic, strong) AUIVideoTemplateItem *templateItem;
@property (nonatomic, strong) AUIVideoTemplateOutputParam *outputParam;

- (instancetype)initWithTemplatePath:(NSString *)templatePath;


+ (void)openEditor:(AUIVideoTemplateItem *)templateItem outputParam:(nullable AUIVideoTemplateOutputParam *)param currentVC:(UIViewController *)currentVC;

@end

NS_ASSUME_NONNULL_END
