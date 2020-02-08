# Milestone Projects 10-12 - Photo captions

https://www.hackingwithswift.com/100/50

Bonus:
- Swipe left to delete item

## Challenge

From [Hacking with Swift](https://www.hackingwithswift.com/guide/5/3/challenge):
>Your challenge is to put two different projects into one: I’d like you to let users take photos of things that interest them, add captions to them, then show those photos in a table view. Tapping the caption should show the picture in a new view controller, like we did with project 1. So, your finished project needs to use elements from both project 1 and project 12, which should give you ample chance to practice.
>
>This will require you to use the picker.sourceType = .camera setting for your image picker controller, create a custom type that stores a filename and a caption, then show the list of saved pictures in a table view. Remember: using the camera is only possible on a physical device.
>
>It might sound counter-intuitive, but trust me: one of the best ways to learn things deeply is to learn them, forget them, then learn them again. So, don’t be worried if there are some things you don’t recall straight away: straining your brain for them, or perhaps re-reading an older chapter just briefly, is a great way to help your iOS knowledge sink in a bit more.
>
>Here are some hints in case you hit problems:
>
>- You’ll need to make ViewController build on UITableViewController rather than just UIViewController.
>- Just like in project 10, you should create a custom type that stores an image filename and a caption string, then use either Codable or NSCoding to load and save that.
>- Use a UIAlertController to get the user’s caption for their image – a single text field is enough.
>- You’ll need to design your detail view controller using Interface Builder, then call instantiateViewController to load it when a table view row is tapped.


## Screenshots

![screenshot1](screenshots/screen01.png)
![screenshot2](screenshots/screen02.png)
