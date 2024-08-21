# Skippable ads

This guide demonstrates how to use the GAM Utils for Roku to create an ad
request for skippable ads, render the skip button according to
[Google Ads requirements](//support.google.com/admanager/answer/3522024#trueview-and-skippable-video-ads),
and send the associated tracking events.

## Prerequisites

Before you continue, you need a Roku app integrated with GAM Utils. See the
[GAM utils readme](https://github.com/googleads/gam-utils-roku/blob/main/README.md)
for more info.

## Include the skippablesSupported parameter when creating content session

When creating a new content session, include `skippablesSupported: True` with
`appSession.newContentSession()`. If it is not set, support for skippable ads
defaults to `False`. With `skippablesSupported: True` set, the `&givn=` string
created from this session makes ad responses eligible for skippable ads. The
following example sets the `skippablesSupported` value on the content session:

#### Example

```brs
' Create a new content session.
m.contentSession = m.appSession.newContentSession({
  // Other content session parameters set here
  ...
  skippablesSupported: True
 })
```

## Skip button requirements

For skippable ads, render the skip button with the following design
requirements. Failure to follow these requirements may lead to restrictions
being placed on Google ads being served to your app.

### Countdown timer

The ad must not be skippable until the `skipoffset` time specified in the VAST.
During this unskippable period, a notice must display to the user informing
them that the ad can be skipped in a given number of seconds. The notice must be
translated into the user's language.

### Button positioning

For a left-to-right language, place the skip button on the bottom right side of
the video player. For a right-to-left language, place the skip button on the
bottom left side of the video player.

### Button sizing

The button and text must be large enough to be legible in a lean-back
experience.

### Text and icon

The skip button must have both text and iconography.

### Accessibility

The user can navigate to the skip button using the remote control. The app
must focus the skip button after the countdown is complete.

### Internationalization

The skip text must be translated into the user's language.

### Ad pods

If the ad is in an
[ad pod](https://support.google.com/admanager/answer/9204133), the skip button
can either skip to the next ad in the pod or skip the entire pod.

## "Skip ad" translations

Use this JSON for translating your "Skip ad" text based on the user's locale.

<details>
  <summary>"Skip ad" translations</summary>

  ```json
  {
    "skipAdTranslations": [
      {
        "languageCode": "am",
        "language": "Amharic",
        "translatedText": "ማስታወቂያ ዝለል"
      },
      {
        "languageCode": "ar",
        "language": "Arabic",
        "translatedText": "تخطي الإعلان"
      },
      {
        "languageCode": "ar-EG",
        "language": "Arabic (Egypt)",
        "translatedText": "تخطي الإعلان"
      },
      {
        "languageCode": "ar-JO",
        "language": "Arabic (Jordan)",
        "translatedText": "تخطي الإعلان"
      },
      {
        "languageCode": "ar-MA",
        "language": "Arabic (Morocco)",
        "translatedText": "تخطي الإعلان"
      },
      {
        "languageCode": "bg",
        "language": "Bulgarian",
        "translatedText": "Пропускане на рекламата"
      },
      {
        "languageCode": "bs",
        "language": "Bosnian",
        "translatedText": "Preskoči oglas"
      },
      {
        "languageCode": "ca",
        "language": "Catalan",
        "translatedText": "Omet l'anunci"
      },
      {
        "languageCode": "cs",
        "language": "Czech",
        "translatedText": "Přeskočit reklamu"
      },
      {
        "languageCode": "da",
        "language": "Danish",
        "translatedText": "Spring annoncen over"
      },
      {
        "languageCode": "de",
        "language": "German",
        "translatedText": "Überspringen"
      },
      {
        "languageCode": "de-AT",
        "language": "German (Austria)",
        "translatedText": "Überspringen"
      },
      {
        "languageCode": "de-CH",
        "language": "German (Switzerland)",
        "translatedText": "Überspringen"
      },
      {
        "languageCode": "el",
        "language": "Greek",
        "translatedText": "Παράλειψη διαφήμισης"
      },
      {
        "languageCode": "en",
        "language": "English",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "en-AU",
        "language": "English (Australia)",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "en-CA",
        "language": "English (Canada)",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "en-GB",
        "language": "English (United Kingdom)",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "en-IE",
        "language": "English (Ireland)",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "en-IN",
        "language": "English (India)",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "en-NZ",
        "language": "English (New Zealand)",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "en-SG",
        "language": "English (Singapore)",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "en-ZA",
        "language": "English (South Africa)",
        "translatedText": "Skip Ad"
      },
      {
        "languageCode": "es",
        "language": "Spanish",
        "translatedText": "Saltar anuncio"
      },
      {
        "languageCode": "es-419",
        "language": "Spanish (Latin America)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-AR",
        "language": "Spanish (Argentina)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-BO",
        "language": "Spanish (Bolivia)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-CL",
        "language": "Spanish (Chile)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-CO",
        "language": "Spanish (Colombia)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-CR",
        "language": "Spanish (Costa Rica)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-DO",
        "language": "Spanish (Dominican Republic)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-EC",
        "language": "Spanish (Ecuador)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-GT",
        "language": "Spanish (Guatemala)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-HN",
        "language": "Spanish (Honduras)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-MX",
        "language": "Spanish (Mexico)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-NI",
        "language": "Spanish (Nicaragua)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-PA",
        "language": "Spanish (Panama)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-PE",
        "language": "Spanish (Peru)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-PR",
        "language": "Spanish (Puerto Rico)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-PY",
        "language": "Spanish (Paraguay)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-SV",
        "language": "Spanish (El Salvador)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-US",
        "language": "Spanish (United States)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-UY",
        "language": "Spanish (Uruguay)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "es-VE",
        "language": "Spanish (Venezuela)",
        "translatedText": "Omitir anuncio"
      },
      {
        "languageCode": "et",
        "language": "Estonian",
        "translatedText": "Jäta reklaam vahele"
      },
      {
        "languageCode": "eu",
        "language": "Basque",
        "translatedText": "Saltatu iragarkia"
      },
      {
        "languageCode": "fa",
        "language": "Farsi",
        "translatedText": "رد شدن از آگهی"
      },
      {
        "languageCode": "fi",
        "language": "Finnish",
        "translatedText": "Ohita mainos"
      },
      {
        "languageCode": "fil",
        "language": "Filipino",
        "translatedText": "Laktawan ang Ad"
      },
      {
        "languageCode": "fr",
        "language": "French",
        "translatedText": "Ignorer l'annonce"
      },
      {
        "languageCode": "fr-CA",
        "language": "French (Canada)",
        "translatedText": "Ignorer l'annonce"
      },
      {
        "languageCode": "fr-CH",
        "language": "French (Switzerland)",
        "translatedText": "Ignorer l'annonce"
      },
      {
        "languageCode": "gl",
        "language": "Galician",
        "translatedText": "Saltar anuncio"
      },
      {
        "languageCode": "gu",
        "language": "Gujarati",
        "translatedText": "જાહેરાત છોડો"
      },
      {
        "languageCode": "he",
        "language": "Hebrew",
        "translatedText": "דילוג על המודעה"
      },
      {
        "languageCode": "hr",
        "language": "Croatian",
        "translatedText": "Preskoči oglas"
      },
      {
        "languageCode": "hu",
        "language": "Hungarian",
        "translatedText": "A hirdetés kihagyása"
      },
      {
        "languageCode": "id",
        "language": "Indonesian",
        "translatedText": "Lewati Iklan"
      },
      {
        "languageCode": "is",
        "language": "Icelandic",
        "translatedText": "Sleppa auglýsingu"
      },
      {
        "languageCode": "it",
        "language": "Italian",
        "translatedText": "Salta annuncio"
      },
      {
        "languageCode": "iw",
        "language": "Hebrew",
        "translatedText": "דילוג על המודעה"
      },
      {
        "languageCode": "jp",
        "language": "Japanese",
        "translatedText": "広告をスキップ"
      },
      {
        "languageCode": "ko",
        "language": "Korean",
        "translatedText": "광고 건너뛰기"
      },
      {
        "languageCode": "ln",
        "language": "Lingala",
        "translatedText": "Ignorer l'annonce"
      },
      {
        "languageCode": "lo",
        "language": "Lao",
        "translatedText": "ຂ້າມໂຄສະນາ"
      },
      {
        "languageCode": "lt",
        "language": "Lithuanian",
        "translatedText": "Praleisti skelbimą"
      },
      {
        "languageCode": "lv",
        "language": "Latvian",
        "translatedText": "Izlaist reklāmu"
      },
      {
        "languageCode": "ml",
        "language": "Malayalam",
        "translatedText": "പരസ്യം ഒഴിവാക്കുക"
      },
      {
        "languageCode": "mo",
        "language": "Romanian",
        "translatedText": "Închide anunțul"
      },
      {
        "languageCode": "mr",
        "language": "Marathi",
        "translatedText": "जाहिरात वगळा"
      },
      {
        "languageCode": "ms",
        "language": "Malay",
        "translatedText": "Langkau Iklan"
      },
      {
        "languageCode": "nb",
        "language": "Norwegian",
        "translatedText": "Hopp over annonsen"
      },
      {
        "languageCode": "nl",
        "language": "Dutch",
        "translatedText": "Advertentie overslaan"
      },
      {
        "languageCode": "no",
        "language": "Norwegian",
        "translatedText": "Hopp over annonsen"
      },
      {
        "languageCode": "pa",
        "language": "Punjabi",
        "translatedText": "ਵਿਗਿਆਪਨ ਛੱਡੋ"
      },
      {
        "languageCode": "pl",
        "language": "Polish",
        "translatedText": "Pomiń reklamę"
      },
      {
        "languageCode": "pt",
        "language": "Portuguese",
        "translatedText": "Pular anúncio"
      },
      {
        "languageCode": "pt-BR",
        "language": "Portuguese (Brazil)",
        "translatedText": "Pular anúncio"
      },
      {
        "languageCode": "pt-PT",
        "language": "Portuguese (Portugal)",
        "translatedText": "Pular anúncio"
      },
      {
        "languageCode": "ro",
        "language": "Romanian",
        "translatedText": "Închide anunțul"
      },
      {
        "languageCode": "ru",
        "language": "Russian",
        "translatedText": "Пропустить рекламу"
      },
      {
        "languageCode": "sk",
        "language": "Slovak",
        "translatedText": "Preskočiť reklamu"
      },
      {
        "languageCode": "sl",
        "language": "Slovenian",
        "translatedText": "Preskoči oglas"
      },
      {
        "languageCode": "sr",
        "language": "Serbian",
        "translatedText": "Прескочи оглас"
      },
      {
        "languageCode": "sv",
        "language": "Swedish",
        "translatedText": "Hoppa över annons"
      },
      {
        "languageCode": "sw",
        "language": "Swahili",
        "translatedText": "Ruka Tangazo"
      },
      {
        "languageCode": "ta",
        "language": "Tamil",
        "translatedText": "விளம்பரத்தைத் தவிர்"
      },
      {
        "languageCode": "te",
        "language": "Telugu",
        "translatedText": "ప్రకటనను దాటవేయి"
      },
      {
        "languageCode": "th",
        "language": "Thai",
        "translatedText": "ข้ามโฆษณา"
      },
      {
        "languageCode": "tl",
        "language": "Tagalog",
        "translatedText": "Laktawan ang Ad"
      },
      {
        "languageCode": "tr",
        "language": "Turkish",
        "translatedText": "Reklamı atla"
      },
      {
        "languageCode": "uk",
        "language": "Ukrainian",
        "translatedText": "Пропустити оголошення"
      },
      {
        "languageCode": "ur",
        "language": "Urdu",
        "translatedText": "اشتہار نظر انداز کریں"
      },
      {
        "languageCode": "vi",
        "language": "Vietnamese",
        "translatedText": "Bỏ qua quảng cáo"
      },
      {
        "languageCode": "zh",
        "language": "Chinese",
        "translatedText": "跳过广告"
      },
      {
        "languageCode": "zh-CN",
        "language": "Chinese (China mainland)",
        "translatedText": "跳过广告"
      },
      {
        "languageCode": "zh-HK",
        "language": "Chinese (Hong Kong)",
        "translatedText": "略過廣告"
      },
      {
        "languageCode": "zh-TW",
        "language": "Chinese (Taiwan)",
        "translatedText": "略過廣告"
      },
      {
        "languageCode": "zu",
        "language": "Zulu",
        "translatedText": "Yeqa Isikhangiso"
      }
    ]
  }
  ```
</details>

## Send the ad skip event {:#send-skip-event}

Call the `skip` tracking event URL to notify Google ad servers when the user
skips the ad. Additionally, supporting skippable ads requires calling the
[VAST tracking URLs for ad events](https://github.com/googleads/gam-utils-roku/blob/main/README.md#9-send-vast-tracking-events).
See the VAST code snippet to find the `skip` ad tracking event URL:

```xml
...
<Linear skipoffset="00:00:05">
  <Duration>00:00:10</Duration>
  <TrackingEvents>
    <Tracking event="skip">
      <![CDATA[ https://pubads.g.doubleclick.net/...]]>
    </Tracking>
```

Now your app is able to target skippable ad demand from Google ad servers.