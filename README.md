# SupremeRestKit

[![CI Status](http://img.shields.io/travis/apadalko/SupremeRestKit.svg?style=flat)](https://travis-ci.org/apadalko/SupremeRestKit)
[![Version](https://img.shields.io/cocoapods/v/SupremeRestKit.svg?style=flat)](http://cocoapods.org/pods/SupremeRestKit)
[![License](https://img.shields.io/cocoapods/l/SupremeRestKit.svg?style=flat)](http://cocoapods.org/pods/SupremeRestKit)
[![Platform](https://img.shields.io/cocoapods/p/SupremeRestKit.svg?style=flat)](http://cocoapods.org/pods/SupremeRestKit)




## Why I should use this

probably, have model like this :

```json
{
    "id":1,
    "title": first title 
},
{
    "id":2,
    "title":title for article 2
}
```
So  u successfully parsed it and get this array [Article1,Article2] . 
Then move this array forward somewhere in your App , for ex , in Table View.
Very common - is that on  cell selection you will move to a new View Controller and load more detailed object for article with Id = 1 : 
```json
{
    "id":1,
    "title": "Awesome title" , //title have been updated
    "text": "Some text",
    "user":{
        "id": 109
        "username": "awesome1"
    }
}
```
So you will parse it as another article object . But unfortunately it will be another Article object instance . SupremeRestKit solve this problem:

Example, Example 

Loading list if objects , storing it in articleList

Example example 

Loading detailed object, and it will be the same object that you stored in articleList, so object that in array have updated property title , new properties text and user. So your tableView Cell will have updated object.
Note, there is move simple way and elegant way to perform this task with SRKit 



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
