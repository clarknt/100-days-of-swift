# Milestone Projects 19-21

https://www.hackingwithswift.com/100/82

This is a Playground project.

Bonus:
- Display UIView animation in playground

## Challenge

>Your challenge this time is not to build a project from scratch. Instead, I want you to implement three Swift language extensions using what you learned in project 24. I’ve ordered them easy to hard, so you should work your way from first to last if you want to make your life easy!
>
>Here are the extensions I’d like you to implement:
>
>1. Extend UIView so that it has a bounceOut(duration:) method that uses animation to scale its size down to 0.0001 over a specified number of seconds.
>2. Extend Int with a times() method that runs a closure as many times as the number is high. For example, 5.times { print("Hello!") } will print “Hello” five times.
>3. Extend Array so that it has a mutating remove(item:) method. If the item exists more than once, it should remove only the first instance it finds. Tip: you will need to add the Comparable constraint to make this work!
>
>As per usual, please try and complete this challenge yourself before you read my hints below. And again, don’t worry if you find this challenge challenging – the clue is in the name, these are designed to make you think!
>
>Here are some hints in case you hit problems:
>
>1. Animation timings are specified using a TimeInterval, which is really just a Double behind the scenes. You should specify your method as bounceOut(duration: TimeInterval).
>2. If you’ve forgotten how to scale a view, look up CGAffineTransform in project 15.
>3. To add times() you’ll need to make a method that accepts a closure, and that closure should accept no parameters and return nothing: () -> Void.
>4. Inside times() you should make a loop that references self as the upper end of a range – that’s the value of the integer you’re working with.
>5. Integers can be negative. What happens if someone writes let count = -5 then uses count.times { … } and how can you make that better?
>6. When it comes to implementing the remove(item:) method, make sure you constrain your extension like this: extension Array where Element: Comparable.
>7. You can implement remove(item:) using a call to firstIndex(of:) then remove(at:).
