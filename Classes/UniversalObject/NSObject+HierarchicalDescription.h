//
//  NSObject+HierarchicalDescription.h
//  ulib
//
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef NSObject_HierarchicalDescription_h
#define NSObject_HierarchicalDescription_h 1

@interface NSObject(HierarchicalDescription)

- (NSString *)hierarchicalDescriptionWithPrefix:(NSString *)prefix;

@end

#endif
