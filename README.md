# CardTest
Sample of weird animation when embedding vc via a segue


I created a control to simulate navigating via a set of cards.  Swiping in either direction would take a snapshot of 
the view being simulated to navigate (*navigationView*) and leave it in the center view while moving the actual view to the new card.
Once the animation completed the snapshot would be removed then the *navigationView* would be replaced in the center card and
finally the cards would all be replaced in there original positions.

When I built this originally I added the *CardNavigationController* to my test view programatically using **addChild()** and
embedding the view in a container view.  Then I attempted to embed the *CardNavigationController* using an **embedSegue** and
discovered that the animation logic I had created was suddenly broken.  Instead of my snapshot and movement of the *navigationView*
making it appear that we'd navigated to a new page, I was suddenly seeing my snapshot get placed on the incoming card and 
my exiting card being left blank.  After lots of logging and testing I discovered that when placed using an **embedSegue** my
card views were magically jumped into new positions that would allow my animation to slide them into there final positions.
Meaning instead of having my center card slide completely to my right cards position and my left card sliding into my center
cards position, I was seeing my center card suddenly jump to my left cards position my right card jumping to my center cards
position and then my animation completing.  Obviously this broke my logic for moving the *navigationView* and taking a snapshot.

### But Why?
I have no answer, but here is a project that shows what is happening
