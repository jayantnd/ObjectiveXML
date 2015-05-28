//
//    The MIT License (MIT)
//
//    Copyright (c) 2015 Jayant Dash
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

//    You can find Original Code at:
//    https://github.com/jayantnd/ObjectiveXML
//

#import "ObjectiveXML.h"

@interface ObjectiveXML()
{
    NSMutableArray          *m_cObjLastTravesedNodePtr;
    NSMutableString         *m_cObjParsedStringPtr;
    NSError                 *m_cObjParserErrorPtr;
}

@end

@implementation ObjectiveXML

-(id)init
{
    if((self = [super init]))
    {
        
    }
    
    return self;
}

-(NSDictionary*)parseWithXMLData:(NSData*)pXMLData Error:(NSError**)pError
{
    NSDictionary *lObjParsedDictPtr = nil;
    
    
    NSXMLParser *lObjParserPtr = [[NSXMLParser alloc] initWithData:pXMLData];
    lObjParserPtr.delegate = self;
    
    if ([lObjParserPtr parse])
    {
        lObjParsedDictPtr = [m_cObjLastTravesedNodePtr lastObject];
    }
    else if (pError && *pError == nil)
    {
        *pError = m_cObjParserErrorPtr;
    }
    
    m_cObjLastTravesedNodePtr = nil;

    return lObjParsedDictPtr;
}

-(NSDictionary*)parseWithXMLString:(NSString*)pXMLString Error:(NSError**)pError
{
    return [self parseWithXMLData:[pXMLString dataUsingEncoding:NSUTF8StringEncoding] Error:pError];
}

-(NSDictionary*)parseWithXMLFilePath:(NSString*)pURLPath Error:(NSError**)pError
{
    return [self parseWithXMLData:[NSData dataWithContentsOfFile:pURLPath] Error:pError];
}

-(NSString*)JSONStringWithXMLData:(NSData*)pXMLData Error:(NSError**)pError
{
    NSDictionary *lObjParsedDict = [self parseWithXMLData:pXMLData Error:pError];
    if(lObjParsedDict)
    {
        NSData *lData = [NSJSONSerialization dataWithJSONObject:lObjParsedDict
                                    options:NSJSONWritingPrettyPrinted
                                                      error:pError];
        return [[NSString alloc] initWithData:lData encoding:NSUTF8StringEncoding];
    }
    else
    {
        return nil;
    }
}

-(NSString*)JSONStringWithXMLString:(NSString*)pXMLString Error:(NSError**)pError
{
    NSDictionary *lObjParsedDict = [self parseWithXMLData:[pXMLString dataUsingEncoding:NSUTF8StringEncoding] Error:pError];
    if(lObjParsedDict)
    {
        NSData *lData = [NSJSONSerialization dataWithJSONObject:lObjParsedDict
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:pError];
        return [[NSString alloc] initWithData:lData encoding:NSUTF8StringEncoding];
    }
    else
    {
        return nil;
    }
}

-(NSString*)JSONStringWithXMLFilePath:(NSString*)pURLPath Error:(NSError**)pError
{
    NSDictionary *lObjParsedDict = [self parseWithXMLData:[NSData dataWithContentsOfFile:pURLPath] Error:pError];
    if(lObjParsedDict)
    {
        NSData *lData = [NSJSONSerialization dataWithJSONObject:lObjParsedDict
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:pError];
        return [[NSString alloc] initWithData:lData encoding:NSUTF8StringEncoding];
    }
    else
    {
        return nil;
    }
}


#pragma mark - NSXMLParser Delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    m_cObjParsedStringPtr = [[NSMutableString alloc]init];
    m_cObjLastTravesedNodePtr = [[NSMutableArray alloc]init];
    [m_cObjLastTravesedNodePtr addObject:[[NSMutableDictionary alloc]init]];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    m_cObjParsedStringPtr = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    id lObj = [m_cObjLastTravesedNodePtr lastObject];
    
    if([lObj isKindOfClass:[NSMutableDictionary class]])
    {
        if(![lObj objectForKey:elementName])
        {
            [lObj setObject:[[NSMutableDictionary alloc]init] forKey:elementName];
            [m_cObjLastTravesedNodePtr addObject:[lObj objectForKey:elementName]];
        }
        else
        {
            id lObjDict = [lObj objectForKey:elementName];
            [lObj removeObjectForKey:elementName];
            NSMutableArray *lObjArr = [[NSMutableArray alloc]init];
            [lObj setObject:lObjArr forKey:elementName];
            [m_cObjLastTravesedNodePtr removeLastObject];
            [m_cObjLastTravesedNodePtr addObject:lObjArr];
            [lObjArr addObject:lObjDict];
            [lObjArr addObject:[[NSMutableDictionary alloc]init]];
            [m_cObjLastTravesedNodePtr addObject:[lObjArr lastObject]];
        }
    }
    else if([lObj isKindOfClass:[NSMutableArray class]])
    {
        [lObj addObject:[[NSMutableDictionary alloc]init]];
        [m_cObjLastTravesedNodePtr addObject:[lObj lastObject]];
    }
    
    [[m_cObjLastTravesedNodePtr lastObject]addEntriesFromDictionary:attributeDict];
    
    [m_cObjParsedStringPtr setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if(m_cObjParsedStringPtr.length >0)
    {
        [m_cObjLastTravesedNodePtr removeLastObject];
        id lObj = [m_cObjLastTravesedNodePtr lastObject];
        if([lObj isKindOfClass:[NSMutableDictionary class]])
        {
            id lTargetObj = [lObj objectForKey:elementName];
            if(((NSDictionary*)lTargetObj).count > 0)
            {
                [lTargetObj setValue:[NSString stringWithString:m_cObjParsedStringPtr] forKey:elementName];
            }
            else
            {
                [lObj removeObjectForKey:elementName];
                [lObj setValue:[NSString stringWithString:m_cObjParsedStringPtr] forKey:elementName];
            }
        }
        else if([lObj isKindOfClass:[NSMutableArray class]])
        {
            [lObj removeLastObject];
            [lObj addObject:[NSString stringWithString:m_cObjParsedStringPtr]];
        }
        [m_cObjParsedStringPtr setString:@""];
    }
    else
    {
        [m_cObjLastTravesedNodePtr removeLastObject];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [m_cObjParsedStringPtr appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    m_cObjParserErrorPtr = parseError;
    m_cObjParsedStringPtr = nil;
    m_cObjLastTravesedNodePtr = nil;
}

@end
