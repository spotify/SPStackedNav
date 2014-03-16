SPStackedNav
============
Joachim Bengtsson <nevyn@spotify.com>

<img src="http://f.cl.ly/items/2H2p0b1H3A2K3T0E040u/mzl.lmmfkkux.480x480-75.jpg" style="float:right; margin-left:1em; border: 1px solid gray" />

SPStackedNavigationController
-----------------------------

SPStackedNavigationController is a UINavigationController drop-in replacement, which represents its content in stacks of panes, rather than one at a time. This interface trend was started by Loren Brichter in Tweetie for iPad, and has spread to many apps in many variations since.

There are two main advantages to this approach:

* You can display two pieces of main content at once, allowing you to navigate in one while using content in the other.
* Navigation is direct instead of indirect, which is faster and more intuitive to use. You actually grab the UI and *pull* it to where you want it. In contrast, a standard navigation controller requires you to find and tap a button with an abstract "back" concept.

The main drawback is that you should no longer use horizontal gestures, as they will interfere with navigation, or the other way around.

At Spotify, we use this style for navigation in our iPad app. We are very proud of the outcome, and are contributing it back to the community, in hopes that others will find it as useful as we do. This code has been used for several years at Spotify and should be very stable.

In our implementation, a page can either be "full size" and thus cover the whole width of the parent container (which we use for the root view controllers in our stacks), or half-size (exactly two will fit in landscape, or one and a half in portrait).

SPSideTabController
-------------------

In addition, SPSideTabController is a drop-in replacement for UITabBarController, but with tabs along the left side rather than along the bottom. This is one of the UIs that are commonly combined with a stacked navigation.

Extra tab bar items can be added along the bottom (e g for "Settings"), and the whole bottom of the screen can have an attachment, which we use to show the currently playing track in Spotify.

Usage Instructions
------------------

1. Pull in "include", "Sources" and "Graphics" into your main project.
2. Go to your project settings, then Build Settings for your app target, and change "Header Search Paths" to include and "{your path to SPStackedNav}/include".
3. #import <SPStackedNav/SPStackedNav.h> either from your prefix header, or the source file where you want to use these classes.

See Examples/StackExample for some example usage.

Version History
---------------

1.0: Initial release