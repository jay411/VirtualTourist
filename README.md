# VirtualTourist
Requires Cocoapods version --1.6.x
Udacity Data Persistence project
Frameworks/Libraries used--
Core Data
Alamofire
SwiftyJSON

First Page-
 Map view that allows user to tap on existing pin or add new pin

Second Page-
Photo collection and mapview, the second controller contains 2 container views. The first container view contains map view that is zoomed in around the pin areaand displays the pin as well.The second container view contains a collection view and a buttons to fetch and save new collection (from Flickr). Tapping on an image cell would delete the image and reload the collection view.
Model-
Contains core data model

FlickrClient-
Classes for Flickr calls and constants

GCDBlackBox-
helper to run code on main thread (from Udacity examples)

AlertPopUp-
view controller extension to create alerts
