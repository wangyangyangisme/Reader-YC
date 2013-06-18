Reader-YC
=========

Reader|YC is a native hackernews client built with Cascades for the UI and the Blackberry-tart python entry point for the Logic. Instead of using often unstable APIs, this app directly scrapes Hackernews for posts (and soon comments) to ensure maximum uptime. 
The post scraping is based heavily off of Dimillian's Sublime plugin found [here] (https://github.com/Dimillian/Sublime-Hacker-News-Reader)

It is currently in a very early alpha stage. More features will be coming quickly, I just decided to push this build to github. 


## Steps to build:
**REQUEST DEBUG TOKEN BAR**
blackberry-debugtokenrequest -storepass STOREPASS -devicepin DEVICEPIN debugtoken.bar

note: the storepass is the password you used to first register for debug tokens with RIM

**BUILD DEBUG BAR**
./build.sh

**BUILD RELEASE BAR**
./release.sh

**SIGN BAR FILE IF RELEASE**
blackberry-signer -storepass STOREPASS NAMEOFBAR

**INSTALL APP TO DEVICE**
blackberry-deploy -installApp -password DEVICEPASS -device DEVICEIP -package NAMEOFBAR

## Features:
###Current Features:
Get the main hackernews pages (top, ask HN, new)

###Current Issues:
Does not handle a lack of internet connectivity. At all.

###Coming Feature roadmap (dates are really guesses):
View text posts, comments and articles all from within the app V1.0 (Will be available on BB-World at this point)
  ETA: July 1 
  
Comment caching for recent articles  V1.1
	ETA: End of July hopefully
	
Favouriting posts for later viewing from a 'History' option
	ETA: Week after V1.2
	
Collapsable comments, load more results V1.3
	ETA: End of Summer
	
Logging in and upvoting/commenting V2.0
	ETA: Probably never, but I do hope to add this
