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
  m.debugOutput = True

  ' Set up RAF.
  m.raf = Roku_Ads()
  m.raf.setDebugOutput(m.debugOutput)

  ' Setup a GAM Utils session at app launch.
  m.appSession = newAppSession()
  ' Do not create the content session until the stream is requested.
  m.contentSession = Invalid

  ' Loop forever, waiting for messages from the main thread.
  port = createObject("roMessagePort")
  m.top.observeField("requestStream", port)
  m.top.observeField("sendAdClickBeacon", port)
  m.top.observeField("sendAdTouchBeacon", port)
  m.top.observeField("sendStartedBeacon", port)
  m.top.observeField("sendEndedBeacon", port)
  while True
    ' Call `poll()` once a second to optimally send progress beacons.
    message = port.waitMessage(1000)
    if message = Invalid and m.contentSession <> Invalid
      m.contentSession.poll()
    end if

    if message = Invalid
      continue while
    end if

    ' Handle messages from the main thread, and reset the field for the next
    ' message.
    field = message.getField()
    data = message.getData()
    if field = "requestStream" and data = True
      requestStream()
      m.top.requestStream = False
      continue while
    end if

    if m.contentSession = Invalid
      continue while
    end if

    if field = "sendAdClickBeacon" and data = True
      m.contentSession.sendAdClickBeacon()
      m.top.sendAdClickBeacon = False
    else if field = "sendAdTouchBeacon" and data <> ""
      m.contentSession.sendAdTouchBeacon(m.top.sendAdTouchBeacon)
      m.top.sendAdTouchBeacon = Invalid
    else if field = "sendStartedBeacon" and data = True
      m.contentSession.sendStartedBeacon()
      m.top.sendStartedBeacon = False
    else if field = "sendEndedBeacon" and data = True
      m.contentSession.sendEndedBeacon()
      m.contentSession = Invalid
      m.top.sendEndedBeacon = False
    end if
  end while
end function

function requestStream()
  if m.contentSession <> Invalid
    m.contentSession.sendEndedBeacon()
    m.contentSession = Invalid
  end if

  ' Set up a new content session and use the GIVN to request a stream.
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
  if m.debugOutput then print "DEBUG: givn: ";givn
  adTagParameters = {
    "givn": givn,
    "iu": "/21775744923/test_slot",
  }
  makeStreamRequest(adTagParameters)

end function
