//
//  AUIUgsvMacro.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/27.
//

#ifndef AUIUgsvMacro_h
#define AUIUgsvMacro_h

#import "AUIFoundation.h"

#define AUIUgsvGetImage(key) AVGetImage(key, @"AlivcUgsv")
#define AUIUgsvGetString(key) AVGetString(key, @"AlivcUgsv")

// Picker
#define AUIUgsvPickerImage(key) AUIUgsvGetImage(([NSString stringWithFormat:@"Picker/%@", key]))
// Timeline
#define AUIUgsvTimelineImage(key) AUIUgsvGetImage(([NSString stringWithFormat:@"Timeline/%@", key]))
// Editor
#define AUIUgsvEditorImage(key) AUIUgsvGetImage(([NSString stringWithFormat:@"Editor/%@", key]))
// Crop
#define AUIUgsvClipperImage(key) AUIUgsvGetImage(([NSString stringWithFormat:@"Clipper/%@", key]))
// recorder
#define AUIUgsvRecorderImage(key) AUIUgsvGetImage(([NSString stringWithFormat:@"Recorder/%@", key]))
// template
#define AUIUgsvTemplateImage(key) AUIUgsvGetImage(([NSString stringWithFormat:@"Template/%@", key]))

#endif /* AUIUgsvMacro_h */
