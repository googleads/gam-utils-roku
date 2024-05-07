# GAM Utils for Roku

GAM Utils is a small helper script, written in the BrightScript language, that
helps enable programmatic monetization on Google Ad Manager for Roku apps. It
serves as a lightweight alternative to the
[IMA DAI SDK](https://developers.google.com/ad-manager/dynamic-ad-insertion/sdk/roku).

## Prerequisites

You need to have your Google Ad Manager account manager enable your app for
using GAM Utils before integrating it into your Roku app.

## Building the sample app

The `/sample` folder contains a minimal sample integration of `gam_utils.brs`.
To prepare the sample channel for sideload, simply:

1. Copy `./gam_utils.brs` to `./sample/source/gam_utils.brs`
2. Compress all of the contents of `./sample/` into `sample.zip`.

Alternatively, you can run the included shell script:

```bash
$ ./build_sample.sh
```
to automatically copy `./gam_utils.brs` into place and compress the sample as
`sample.zip`.

## Integrating GAM Utils

### 1. Load the Roku Advertising Framework library

Follow Roku's documentation for [integrating
RAF](https://developer.roku.com/docs/developer-program/advertising/integrating-roku-advertising-framework.md).

### 2. Load GAM Utils

1. Place `gam_utils.brs` in your `components` directory.
2. In your component XML file, add a `<script>` tag to load GAM Utils, as seen
below:

```xml
<script type="text/brightscript" uri="gam_utils.brs" />
```

### 3. Create a new app session

Call the `newAppSession` function to create a new app session. Create this app
session as soon as possible on ad start. This session must be reused for the
lifespan of the app.

#### Example

```brs
m.appSession = newAppSession()
```

### 4. Create a new content session

Call the function `appSession.newContentSession()` to create a new content
session for each stream request or content video change. This function takes a
single parameter which is an associative array containing the values described
in the table below:

| **Key** 	| **Value Type** 	| **Description** 	|
|---	|---	|---	|
| `adWillAutoPlay` 	| Boolean 	| Indicates whether video ad starts by autoplay (true) or by click (false). 	|
| `adWillPlayMuted` 	| Boolean 	| Indicates whether playback starts while the video is muted. 	|
| `continuousPlayback` 	| Boolean 	| Indicates whether the player intends to continuously play video content, similar to a TV broadcast. 	|
| `descriptionUrl` 	| Valid URL String 	| Web URL describing the content. See the [Help Center][HC-URL] for more information. 	|
| `directedForChildOrUnknownAge` 	| Boolean 	| Indicates whether the ad request should receive [child directed treatment][CDT]. 	|
| `iconsSupported` 	| Boolean 	| Indicates whether the player supports VAST Icons, such as [Why this ad?][WTA] 	|
| `publisherProvidedId` 	| String 	| The [PPID][PPID] is used for frequency capping, audience segmentation and targeting, sequential ad rotation, and other audience-based ad delivery controls across devices. 	|
| `raf` | Object of type `Roku_Ads()`  | An instance of the (Roku Advertising Framework)[RAF]  |
| `videoHeight` 	| Integer 	| The height of the video player. 	|
| `videoWidth` 	| Integer 	| The width of the video player. 	|
| `storageAllowed` 	| Boolean 	| Indicates whether the user has provided permission to use local storage. 	|
| `supportedApiFrameworks` 	| Array of Integers 	| Indicates all of the [API frameworks][APIS] that this player supports. 	|

#### Example

```brs
' Create a new content session.
m.contentSession = m.appSession.newContentSession({
  adWillAutoPlay: True,
  adWillPlayMuted: False,
  continuousPlayback: False,
  descriptionUrl: "https://your-example-website",
  directedForChildOrUnknownAge: False,
  iconsSupported: True,
  publisherProvidedId: "123456",
  raf: m.raf,
  videoHeight: 480,
  videoWidth: 640,
  storageAllowed: True,
  supportedApiFrameworks: []
 })
```

### 5. Attach `&givn` parameter to stream or ad request

Call the `contentSession.getGivn()` function to retrieve the string value that
must be sent in the `&givn=` parameter. You'll need to add this `&givn=`
parameter to all ad requests that belong to the current video content or stream.
Each time the viewer changes content or starts playing a new stream, call this
function again to get a new `&givn=` parameter value for each video stream.

#### Ad request example

```brs
givn = m.contentSession.getGivn()

' Build a VAST tag URL
adTag = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator="
url = adTag + "&givn=" + givn

' Make an ad request (not implemented here)
xmlResponse = makeGETRequest(adTag)
```

#### Stream request example

```brs
givnStr = m.contentSession.getGivn()
requestBody = formatJson( { givn: givnStr } )
url = "https://dai.google.com/linear/v1/dash/event/0ndl1dJcRmKDUPxTRjvdog/stream"

' Make a stream request (not implemented here)
jsonResponse = makePOSTRequest(url, requestBody)
```

### 6. Trigger started and ended beacons

Before starting ad playback on your stream or video content, call
`contentSession.sendStartedBeacon` to trigger a started beacon. When the
playback ends, call `contentSession.sendEndedBeacon` to trigger an ended beacon.

#### Example

```brs
m.contentSession.sendStartedBeacon()
' begin playback
while adIsActive
  ...
end while
' playback ends
m.contentSession.sendEndedBeacon()
```

### 7. Trigger interaction beacons

While an ad is playing, if the user interacts with their control, that
interaction should be sent to the `contentSession.sendAdTouchBeacon` with the
key code being pressed. In addition, if the interaction is a click through on an
ad, call `contentSession.sendAdClickBeacon` to register an ad click.

#### Example

```brs
function onKeyEvent(key as String, press as Boolean) as Boolean
  if (press AND m.adIsPlaying) then
    ' m.mainAdIsSelected indicates that the user is interacting with the ad
    ' itself, rather than an icon, overlay, or ui element.
    if (key = "OK" AND m.mainAdIsSelected) then
      m.contentSession.sendAdClickBeacon()
      ..
    end if
    m.contentSession.sendAdTouchBeacon(key)
  end if
end function
```

### 8. Trigger ad progress poll

While ad content is playing, call the `contentSession.poll` method once per
second, to notify the Google Ad Manager that the ad is still playing.

#### Example

```brs
messagePort = createObject("roMessagePort")scx cv
while streamIsActive
  ' Poll the helper code so it can send progress beacons as needed.
  message = messagePort.waitMessage(1000)
  m.contentSession.poll()
  ...
end while
```

[hc link]: https://github.com/InteractiveAdvertisingBureau/AdCOM/blob/main/AdCOM%20v1.0%20FINAL.md#list_apiframeworks
[HC-URL]: https://support.google.com/admanager/answer/10678356#description_url
[CDT]: https://support.google.com/admanager/answer/3671211
[RAF]: https://developer.roku.com/en-gb/docs/developer-program/advertising/integrating-roku-advertising-framework.md
[WTA]: https://support.google.com/admanager/answer/2695279?sjid=16481471245632903346-NA#video&zippy=
[PPID]: https://support.google.com/admanager/answer/2880055#requirements
[APIS]: https://github.com/InteractiveAdvertisingBureau/AdCOM/blob/main/AdCOM%20v1.0%20FINAL.md#list_apiframeworks
[IMA DevSite]: https://developers.google.com/interactive-media-ads
