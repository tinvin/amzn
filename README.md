# amzn

- open a safari window/tab
- navigate to amazon fresh or whole foods checkout page, where slots are to be chosen. 
- open script in applescript editor and run
- don't change tab ordering (delete or prepend) on this window, applescript uses tab index for keeping track of amazon tab


Script progress can be viewed in AppleScript Editor console view (little page icon at the bottom "Show or hide the console). Replies view is especially verbose, Messages view shows less verbose output. 


Auto checkout feature will try to continue and submit order.
If amazon redirects you, script will try to navigate back to checkout page. If you have multiple carts, it will select the first one on the page (Order is usually Fresh, Whole Foods, regular/pantry). 

Script will notify you (notifications and audio) when slot is found either way. 

Mostly tested on Amazon Fresh, but Whole Foods is also supported. Tested in NYC. Submit an issue or PR for fixes
