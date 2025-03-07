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

function init() as Void
  requestMockStreamButton = m.top.findNode("requestMockStreamButton")
  requestMockStreamButton.observeField("buttonSelected", "requestMockStream")
  sendAdClickBeaconButton = m.top.findNode("sendAdClickBeaconButton")
  sendAdClickBeaconButton.observeField("buttonSelected", "sendAdClickBeacon")
  sendStartedBeaconButton = m.top.findNode("sendStartedBeaconButton")
  sendStartedBeaconButton.observeField("buttonSelected", "sendStartedBeacon")
  sendEndedBeaconButton = m.top.findNode("sendEndedBeaconButton")
  sendEndedBeaconButton.observeField("buttonSelected", "sendEndedBeacon")
  transferFocusToVideoButton = m.top.findNode("transferFocusToVideoButton")
  transferFocusToVideoButton.observeField("buttonSelected", "transferFocusToVideo")
  m.video = m.top.findNode("FakeVideo")
  m.video.observeField("pressedKey", "onVideoKeyPress")
  m.transferFocusToVideoButton = transferFocusToVideoButton
  requestMockStreamButton.setFocus(true)
  ' RAF only works from task or main() thread, so dispatch off to one.
  m.adsTask = createObject("roSGNode", "AdsTask")
  m.adsTask.control = "RUN"
end function

function requestMockStream() As Void
  m.adsTask.requestStream = True
end function

function sendAdClickBeacon() As Void
  m.adsTask.sendAdClickBeacon = True
end function

function sendStartedBeacon() As Void
  m.adsTask.sendStartedBeacon = True
end function

function sendEndedBeacon() As Void
  m.adsTask.sendEndedBeacon = True
end function

function transferFocusToVideo() As Void
  m.video.setFocus(true)
end function

function onVideoKeyPress() As Void
  key = m.video.pressedKey
  if key = ""
    return
  end if
  m.adsTask.sendAdTouchBeacon = key
  ' If back or up is pressed, transfer focus back up to the buttons
  if key = "back" or key = "up"
    m.transferFocusToVideoButton.setFocus(true)
  end if
  ' Reset so that we get the next key press, even if it's a repeat of the last key
  m.video.pressedKey = ""
end function
