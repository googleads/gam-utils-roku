' Copyright 2024 Google LLC
'
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
'
'      https://www.apache.org/licenses/LICENSE-2.0
'
' Unless required by applicable law or agreed to in writing, software
' distributed under the License is distributed on an "AS IS" BASIS,
' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
' See the License for the specific language governing permissions and
' limitations under the License.

library "Roku_Ads.brs"

' Thread entry point.
function runThread()
  debugOutput = True

  ' Set up RAF.
  m.raf = Roku_Ads()
  m.raf.setDebugOutput(debugOutput)

  ' Setup a GAM Utils session.
  m.appSession = newAppSession()
  m.contentSession = m.appSession.newContentSession({
    adWillAutoPlay: True,
    adWillPlayMuted: False,
    continuousPlayback: False,
    descriptionUrl: "https://your-content-website",
    directedForChildOrUnknownAge: False,
    iconsSupported: True,
    publisherProvidedId: "123456",
    raf: m.raf,
    'See skippable-ads.md for supporting skippable ads.
    skippablesSupported: False,
    storageAllowed: True,
    supportedApiFrameworks: [],
    videoHeight: 480,
    videoWidth: 640
  })

  ' Make a mock stream/ads request.
  givn = m.contentSession.getGIVN()
  if debugOutput then print "DEBUG: givn: ";givn
  adTagParameters = {
    "givn": givn,
    "iu": "/22735030358/test_slot",
  }
  makeStreamRequest(adTagParameters)

  ' Use helper code to send beaconing signals on ad start and ad click events.
  m.contentSession.sendStartedBeacon()
  m.contentSession.sendAdClickBeacon()

  ' In production, only send an ad touch beaconsing signal when the user reacts
  ' to an ad. For example, you can listen to the remote control `onKeyEvent`
  ' (https://developer.roku.com/en-gb/docs/references/scenegraph/component-functions/onkeyevent.md)
  ' and call the `sendAdTouchBeacon` function.
  m.contentSession.sendAdTouchBeacon("OK")

  port = createObject("roMessagePort")
  streamTimer = createObject("roTimespan")
  streamIsActive = True

  while streamIsActive
    ' Poll the helper code so it can send progress beacons as needed.
    message = port.waitMessage(1000)
    if message = Invalid then m.contentSession.poll()
    ' For the purposes of this example, the "stream" "ends" after 11s, but in
    ' production this should be tied to the actual stream in the video player.
    if streamTimer.totalSeconds() > 11 then streamIsActive = False
  end while

  ' Use helper code to send beaconing signals on ad complete events.
  m.contentSession.sendEndedBeacon()

end function
