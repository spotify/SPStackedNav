SPSuccinct
==========
by Joachim Bengtsson <joachimb@gmail.com>

In my quest to write the most succinct, short and readable code humanly possible, I've written a few tools to help me. [These tools are elaborately described on my blog](http://overooped.com/post/7456709174/low-verbosity-kvo), but in short:

SPLowVerbosity
--------------

Defines macros for creating your standard containers and "POD" objects (NSNumber, NSString, ...). I've always had such a file copy-pasted between projects, but this particular iteration is very much inspired by the excellent [Jens Alfke's CollectionUtils](https://bitbucket.org/snej/myutilities/src/tip/CollectionUtils.h), plus some ARC fixes and fixes. Unsung heroes: $castIf, $notNull.

SPKVONotificationCenter
-----------------------

A KVO observation needs to be registered and deregistered at the right points. You have this as a concept, but you have no object representing this concept. That sucks. SPKVONotificationCenter gives you an object to represent the concept of a KVO observation that you can manage like any other object; and the world is a nice place to live again.

SPDepends
---------
On top of that, SPDepends experiments with magic, letting you subscribe to say three different KVC key paths on two different objects and getting a callback when anything changes, all in a line or two:

<pre><code>$depends(@"alarm", lock, @"locked", sensor, @"adjacentPeople", @"isOn", self, @"isOn", ^{
  if(lock.locked && sensor.adjacentPeople.count > 0 && sensor.isOn && selff.isOn)
    [selff triggerAlarm];
})
</code></pre>

I find that this really brings out the power in KVO in a way only Bindings have done previously.