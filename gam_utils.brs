' Copyright 2024 Google LLC
'
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
'
'     http://www.apache.org/licenses/LICENSE-2.0
'
' Unless required by applicable law or agreed to in writing, software
' distributed under the License is distributed on an "AS IS" BASIS,
' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
' See the License for the specific language governing permissions and
' limitations under the License.
'
' GAM Utils v2.0.0b0
'
' GAM Utils is a small BrightScript library that helps enable programmatic
' monetization on Google Ad Manager for Roku apps. It serves as a lightweight
' alternative to the IMA SDK
' (https://developers.google.com/interactive-media-ads).


' Creates a new AppSession for the entire duration of the channel.
Function newAppSession() As Object
  deviceInfo = createObject("roDeviceInfo")
  instance = {
    _appInfo: createObject("roAppInfo"),
    _appManager: createObject("roAppManager"),
    _deviceInfo: deviceInfo,
    _osVersion: deviceInfo.getOSVersion(),
    _sessionId: deviceInfo.getRandomUUID(),
    _urlTransfer: createObject("roUrlTransfer")
  }

  instance._booleanAsString = Function(booleanValue, trueValue, falseValue)
    If booleanValue = Invalid Then Return Invalid
    If booleanValue = True Then Return trueValue
    Return falseValue
  End Function

  instance._buildUrlQueryString = Function(map As Object) As String
    keyValues = []
    for each keyValuePair in map.items()
      If keyValuePair.value <> Invalid And keyValuePair.value <> ""
        keyValues.push(keyValuePair.key + "=" + keyValuePair.value)
      End If
    End For
    Return keyValues.join("&")
  End Function

  instance._webSafeBase64Encode = Function(uncodedString As String) As String
    byteArray = createObject("roByteArray")
    byteArray.fromAsciiString(uncodedString)
    Return byteArray.toBase64String().replace("/", "_").replace("+", "-").replace("=", ".")
  End Function

  instance._getUserAgent = Function() As String
    product = m._appInfo.getTitle() + "/" + m._appInfo.getVersion()
    platformComponents = [
      "Roku " + m._osVersion.major + "." + m._osVersion.minor + "." + m._osVersion.revision,
      m._deviceInfo.getCurrentLocale(),
      m._deviceInfo.getModelDisplayName(),
      "Build/" + m._osVersion.build,
    ]
    Return m._urlTransfer.escape(product + " (" + platformComponents.join("; ") + ")")
  End Function

  instance._buildGIVN = Function(args As Object) As String
    signals = {
      "url": m._urlTransfer.escape(m._appInfo.getTitle() + ".adsenseformobileapps.com/"),
      "vpa": m._booleanAsString(args.adWillAutoPlay, "auto", "click"),
      "vpmute": m._booleanAsString(args.adWillPlayMuted, "1", "0"),
      "vconp": m._booleanAsString(args.continuousPlayback, "2", "1"),
      "pss": m._booleanAsString(args.skippablesSupported, "1", "0"),
      "wta": m._booleanAsString(args.iconsSupported, "1", "0"),
      "ppid": args.publisherProvidedId,
      "sid": args.sessionId,
      "sdk_apis": m._urlTransfer.escape(args.supportedApiFrameworks.join(",")),
      "aselc": "1",
      "asscs_correlator": args.asscsCorrelator,
      "msid": m._appInfo.getId(),
      "ctv": "1",
      "is_lat": m._booleanAsString(m._deviceInfo.isRidaDisabled(), "1", "0"),
      "guv": "r.2.0.0b0",
      "imav": "r.3.2.2",
      "ua": m._getUserAgent()
    }
    If args.descriptionUrl <> Invalid And args.descriptionUrl <> "" Then signals["url"] = args.descriptionUrl
    If args.descriptionUrl <> Invalid And args.descriptionUrl <> "" Then signals["video_url_to_fetch"] = args.descriptionUrl
    If args.videoHeight <> Invalid Then signals["vp_h"] = args.videoHeight.toStr()
    If args.videoWidth <> Invalid Then signals["vp_w"] = args.videoWidth.toStr()
    If args.videoHeight <> Invalid And args.videoWidth <> Invalid Then signals["u_so"] = m._booleanAsString(args.videoHeight > args.videoWidth, "p", "l")
    If args.storageAllowed = True And args.directedForChildOrUnknownAge = False
      signals["id_type"] = "rida"
      signals["rdid"] = m._deviceInfo.getRida()
    End If
    signalString = m._buildUrlQueryString(signals)
    Return m._webSafeBase64Encode(signalString)
  End Function

  ' Creates a new content session, for a single given content or program.
  instance.newContentSession = Function(rawSessionArgs As Object) As Object
    sessionArgs = {
      adWillAutoPlay: Invalid,
      adWillPlayMuted: Invalid,
      continuousPlayback: Invalid,
      descriptionUrl: Invalid,
      directedForChildOrUnknownAge: False,
      iconsSupported: False,
      publisherProvidedId: Invalid,
      raf: Invalid,
      storageAllowed: False,
      supportedApiFrameworks: [],
      sessionId: m._sessionId,
      skippablesSupported: False,
      videoHeight: Invalid,
      videoWidth: Invalid
    }
    sessionArgs.append(rawSessionArgs)
    asscsCorrelator = m._deviceInfo.getRandomUUID()
    sessionArgs.append({ asscsCorrelator: asscsCorrelator })
    proto = {
      _activityTimer: createObject("roTimespan"),
      _asscsCorrelator: asscsCorrelator,
      _givn: m._buildGIVN(sessionArgs),
      _instance: m,
      _isActive: False,
      _raf: sessionArgs.raf
    }

    ' Returns the `givn=` value for making ads requests.
    proto.getGIVN = Function() As String
      Return m._givn
    End Function

    ' Sends a beacon to indicate that a clickthrough on an ad has occurred.
    proto.sendAdClickBeacon = Sub()
      m._sendBeacon("3", "Clicked", False, Invalid)
    End Sub

    ' Sends a beacon to indicate that a user touch or click on the ad other than
    ' a clickthrough (for example, skip, mute, tap, etc.) from `onKeyEvent`.
    proto.sendAdTouchBeacon = Sub(key As String)
      m._sendBeacon("4", "Interaction", False, key)
    End Sub

    ' Sends a beacon to indicate that the content activity has started. For
    ' video, this should be called on "video player start". This may be in
    ' response to a user-initiated action (click-to-play) or a channel initiated
    ' action (autoplay).
    proto.sendStartedBeacon = Sub()
      m._isActive = True
      m._activityTimer.mark()
      m._sendBeacon("5", "ProgressStarted", True, Invalid)
    End Sub

    ' Triggers beacons that fire during content activity as time progresses.
    proto.poll = Sub()
      If m._isActive = False Then Return
      If m._activityTimer.totalSeconds() < 5 Then Return
      m._activityTimer.mark()
      m._sendBeacon("6", "Progress", False, Invalid)
    End Sub

    ' Sends a beacon to indicate that the content activity has ended. For video
    ' this should be called when playback ends (for example, when the player
    ' reaches end of stream, or when the user exits playback mid-way, or when
    ' the user quits the channel, or when advancing to the next content item in
    ' a playlist setting).
    proto.sendEndedBeacon = Sub()
      m._isActive = False
      m._sendBeacon("7", "ProgressEnded", False, Invalid)
    End Sub

    proto._sendBeacon = Sub(eventType As String, rafEventType As String, includeAllSignals As Boolean, key)
      signals = {
        "asscs_correlator": m._asscsCorrelator,
        "ctv": "1",
        "dt": "1",
        "et": eventType,
        "id": "asscs",
        "iet": key,
        "hdmic": m._instance._booleanAsString(m._instance._deviceInfo.isHdmiConnected(), "1", "0"),
        "aut": m._instance._appManager.getUpTime().totalMilliseconds().toStr(),
        "lkp": (m._instance._deviceInfo.timeSinceLastKeyPress() * 1000).toStr(),
        "sut": (upTime(0) * 1000).toStr()
      }
      If includeAllSignals
        signals.append({
          "aid": m._instance._appInfo.getId(),
          "av": m._instance._appInfo.getVersion(),
          "cc": m._instance._deviceInfo.getUserCountryCode(),
          "eip": m._instance._deviceInfo.getExternalIp(),
          "fv": m._instance._osVersion.major + "." + m._instance._osVersion.minor + "." + m._instance._osVersion.revision + "." + m._instance._osVersion.build,
          "lcl": m._instance._deviceInfo.getCurrentLocale(),
          "mdl": m._instance._deviceInfo.getModel(),
          "isd": m._instance._booleanAsString(m._instance._appInfo.isDev(), "1", "0")
        })
      End If
      signalString = m._instance._buildUrlQueryString(signals)
      m._raf.fireTrackingEvents({
        "tracking": [{
          "event": rafEventType, "triggered": False,
          "url": "https://pagead2.googlesyndication.com/pagead/gen_204?" + signalString
      }], "adServer": Invalid }, { "type": rafEventType })
    End Sub
    Return proto
  End Function
  Return instance
End Function
