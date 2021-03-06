# SupremeRestKit

[![CI Status](http://img.shields.io/travis/apadalko/SupremeRestKit.svg?style=flat)](https://travis-ci.org/apadalko/SupremeRestKit)
[![Version](https://img.shields.io/cocoapods/v/SupremeRestKit.svg?style=flat)](http://cocoapods.org/pods/SupremeRestKit)
[![License](https://img.shields.io/cocoapods/l/SupremeRestKit.svg?style=flat)](http://cocoapods.org/pods/SupremeRestKit)
[![Platform](https://img.shields.io/cocoapods/p/SupremeRestKit.svg?style=flat)](http://cocoapods.org/pods/SupremeRestKit)




# IN DEVELOPMENT

## "Why I should use this?"

You have json model like this :

```json
{
    "id":1,
    "title": "first title"
},
{
    "id":2,
    "title": "title for article 2"
}
```
You parsed it in this array: [Article1,Article2]. Then, move forward this array somewhere in your App , for example , in Table View.
Very common - is that on cell selection you will push to a new View Controller and load more detailed object for article with Id = 1 : 
```json
{
    "id":1,
    "title": "Awesome title" , //title have been updated
    "text": "Some text",
    "user":{
        "id": 109,
        "username": "awesome1"
    }
}
```
So you will parse it as another article object. But unfortunately it will be another Article object instance . SupremeRestKit solve this problem:
```objc
SRKClient * client = [[SRKClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.awesomeapp.com/v1"]];
[client makeRequest:
[SRKRequest GETRequest:@"articles" urlParams:nil 
    mapping:
        [[[SRKObjectMapping mappingWithPropertiesArray:@[@"title"]] setIdentifierKeyPath:@"id"]
        setStorageName:@"Article"]]
    andResponseBlock:^(SRKResponse *response) {
        NSArray * articlesList = [response objects];
        //articlesList have two objects type of SRKObject
        NSString * firstTitle = articlesList.firstObject[@"title"];
}]];
```
You load list if articles stored them in articleList. Then you will load a detailed article
```objc
[client makeRequest:[SRKRequest GETRequest:@"articles" urlParams:nil 
    mapping:[
        [[[SRKObjectMapping mappingWithPropertiesArray:@[@"title",@"text"]] 
        setIdentifierKeyPath:@"id"] setStorageName:@"Article"]
        addRelationFromKey:@"user" toKey:@"fromUser" relationMapping:
            [SRKObjectMapping mappingWithProperties:@{@"username":@"username",@"id":@"objectId"}]
        ] 
    andResponseBlock:^(SRKResponse *response) {
        NSArray * fullArticleObject = [response first];

        [[articlesList firstObject] isEqual:fullArticleObject] // returns true
        [articlesList firstObject][@"fromUse"] // as well is object in array is the same - it have user
        [articlesList firstObject][@"title"] // Awesome title - new updated title

}]];
```

Loading detailed object, and it will be the same object that you stored in articleList, so object that in array have updated property title , new properties text and user. So your tableView Cell will have updated object.
Note, there is move simple way and elegant way to perform this task with SRKit 

## Usage

### Basic
```objc
//define client
SRKClient * client = [[SRKClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.awesomeapp.com/v1"]];
//define mapping
SRKObjectMapping * mapping = [SRKObjectMapping mappingWithPropertiesArray:@[@"title"]];
//add id for mapping
[mapping setIdentifierKeyPath:@"id"];
/*set RAM storage name where you will store this type of object,
not needed if you are using subclases**/
[mapping setStorageName:@"Article"];
//if you have a nested objects - add a relation with mapping
SRKObjectMapping * nestedMapping = [SRKObjectMapping mappingWithProperties:
@{
@"id":@"objectId",// objectId - default indifiter key
@"username":@"username"
}];
//RAM Storage Name for nested object
[nestedMapping setStorageName:@"User"];
//adding relation
[mapping addRelationFromKey:@"user" toKey:@"fromUser" relationMapping:nestedMapping];
//or [mapping addRelation:[SRKMappingRelation realtionWithFromKey:@"user" toKey:@"fromUser" mapping:mapping]];


//create request
SRKRequest * request = 
[SRKRequest GETRequest:@"articles" urlParams:nil mapping:mapping andResponseBlock:^(SRKResponse *response) {

}];
//make request
[client makeRequest:request];
```
### Subclassing
Idea behind subclassing is that evry dynamic property meant to be a value from response, data
```objc
@interface User : SRKObject
@property (nonatomic,retain) NSString * username;
@end
@implementation User
@dynamic username;
@end
@interface Article :SRKObject
@property (nonatomic,retain) User * fromUser;
@property (nonatomic,retain)NSString * title;
@property (nonatomic,retain)NSString * text;
@end
@implementation Article
@dynamic title,text,fromUser;
@end
//you can access property as normal
user.username
//or as subscript
user[@"username"]
//or
[user objectForKey:@"username"]
```
every SRKObject subclass have ability to generate Mapping Object
```objc
SRKObjectMapping * articleMapping = [[Article mapping]
    setPropertiesFromDictionary:@{@"title":@"title",@"id":@"objectId"}];
SRKObjectMapping * userMapping = [[[User mapping]
    setPropertiesFromArray:@[@"username"]] setIdentifierKeyPath:@"id"];
[articleMapping addRelationFromKey:@"user" toKey:@"fromUser" relationMapping:userMapping];
```






## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SupremeRestKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SupremeRestKit"
```

## Author

apadalko, a.padalko@icloud.com

## License

SupremeRestKit is available under the MIT license. See the LICENSE file for more info.
