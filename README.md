# Metalink

Metalink extracts information from URLs and provide uniformed and structured data using [OpenGraph](https://ogp.me/) and [oEmbed](https://oembed.com/).

## Usage

Call `https://metalink.dev` with an `url` parameter. Metalink will try to fetch its OpenGraph metatags and fallback to oEmbed if can't find OpenGraph data.

```http
GET https://metalink.dev/?url={URL_TO_INSPECT}
```

For example:

```http
GET https://metalink.dev/?url=https%3A%2F%2Ftwitter.com%2Fryanflorence%2Fstatus%2F1125041041063665666
```

Will respond with:

```json
{
  "url": "https://twitter.com",
  "favicon": "https://abs.twimg.com/responsive-web/client-web-legacy/icon-ios.b1fc7275.png",
  "title": "Ryan Florence on Twitter",
  "description": "“@dan_abramov @_developit @mjackson The question is not \"when does this effect run\" the question is \"with which state does this effect synchronize with\"\n\nuseEffect(fn) // all state\nuseEffect(fn, []) // no state\nuseEffect(fn, [these, states])”",
  "image": "https://pbs.twimg.com/profile_images/1344410501309030403/L2rNpO6h_400x400.jpg",
  "html": "<blockquote class=\"twitter-tweet\"><p lang=\"en\" dir=\"ltr\">The question is not &quot;when does this effect run&quot; the question is &quot;with which state does this effect synchronize with&quot;<br><br>useEffect(fn) // all state<br>useEffect(fn, []) // no state<br>useEffect(fn, [these, states])</p>&mdash; Ryan Florence (@ryanflorence) <a href=\"https://twitter.com/ryanflorence/status/1125041041063665666?ref_src=twsrc%5Etfw\">May 5, 2019</a></blockquote>\n<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\n",
  "type": "rich",
  "raw": {
    "json_ld": {},
    "oembed": {
      "url": "https://twitter.com/ryanflorence/status/1125041041063665666",
      "author_name": "Ryan Florence",
      "author_url": "https://twitter.com/ryanflorence",
      "html": "<blockquote class=\"twitter-tweet\"><p lang=\"en\" dir=\"ltr\">The question is not &quot;when does this effect run&quot; the question is &quot;with which state does this effect synchronize with&quot;<br><br>useEffect(fn) // all state<br>useEffect(fn, []) // no state<br>useEffect(fn, [these, states])</p>&mdash; Ryan Florence (@ryanflorence) <a href=\"https://twitter.com/ryanflorence/status/1125041041063665666?ref_src=twsrc%5Etfw\">May 5, 2019</a></blockquote>\n<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\n",
      "width": 550,
      "height": null,
      "type": "rich",
      "cache_age": "3153600000",
      "provider_name": "Twitter",
      "provider_url": "https://twitter.com",
      "version": "1.0"
    },
    "open_graph": {
      "type": "article",
      "url": "https://twitter.com/ryanflorence/status/1125041041063665666",
      "title": "Ryan Florence on Twitter",
      "description": "“@dan_abramov @_developit @mjackson The question is not \"when does this effect run\" the question is \"with which state does this effect synchronize with\"\n\nuseEffect(fn) // all state\nuseEffect(fn, []) // no state\nuseEffect(fn, [these, states])”",
      "site_name": "Twitter"
    }
  },
  "meta": {
    "viewport": "width=device-width,initial-scale=1,maximum-scale=1,user-scalable=0,viewport-fit=cover",
    "mobile-web-app-capable": "yes",
    "apple-mobile-web-app-title": "Twitter",
    "apple-mobile-web-app-status-bar-style": "white",
    "theme-color": "#ffffff"
  },
  "search": true,
  "site_name": "Twitter",
  "lang": "es"
}
```

### Extra parameters

Some URLs, such as Twitter, accepts extra parameters, for example:

```http
GET https://metalink.dev/?url=https%3A%2F%2Ftwitter.com%2Fryanflorence%2Fstatus%2F1125041041063665666&hide_thread=true
```

In this case, `hide_thread` is an extra parameter that will be passed to Twitter.

### Taking screenshots

To get a screenshot from a URL, call `https://metalink.dev/screenshot` with an `url` parameter. Metalink will try to fetch the URL in a headless Chrome instance with a 1080x720 window size.

```http
GET https://metalink.dev/screenshot?url={URL_TO_INSPECT}
```
