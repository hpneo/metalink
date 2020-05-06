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
  "favicon": "https://abs.twimg.com/favicons/twitter.ico",
  "title": null,
  "image": null,
  "html": "<blockquote class=\"twitter-tweet\" data-conversation=\"none\"><p lang=\"en\" dir=\"ltr\">The question is not &quot;when does this effect run&quot; the question is &quot;with which state does this effect synchronize with&quot;<br><br>useEffect(fn) // all state<br>useEffect(fn, []) // no state<br>useEffect(fn, [these, states])</p>&mdash; Ryan Florence (@ryanflorence) <a href=\"https://twitter.com/ryanflorence/status/1125041041063665666?ref_src=twsrc%5Etfw\">May 5, 2019</a></blockquote>\n<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\n",
  "type": "rich",
  "raw": {
    "url": "https://twitter.com/ryanflorence/status/1125041041063665666",
    "author_name": "Ryan Florence",
    "author_url": "https://twitter.com/ryanflorence",
    "html": "<blockquote class=\"twitter-tweet\" data-conversation=\"none\"><p lang=\"en\" dir=\"ltr\">The question is not &quot;when does this effect run&quot; the question is &quot;with which state does this effect synchronize with&quot;<br><br>useEffect(fn) // all state<br>useEffect(fn, []) // no state<br>useEffect(fn, [these, states])</p>&mdash; Ryan Florence (@ryanflorence) <a href=\"https://twitter.com/ryanflorence/status/1125041041063665666?ref_src=twsrc%5Etfw\">May 5, 2019</a></blockquote>\n<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\n",
    "width": 550,
    "height": null,
    "type": "rich",
    "cache_age": "3153600000",
    "provider_name": "Twitter",
    "provider_url": "https://twitter.com",
    "version": "1.0"
  }
}
```

### Extra parameters

Some URLs, such as Twitter, accepts extra parameters, for example:

```http
GET https://metalink.dev/?url=https%3A%2F%2Ftwitter.com%2Fryanflorence%2Fstatus%2F1125041041063665666&hide_thread=true
```

In this case, `hide_thread` is an extra parameter that will be passed to Twitter.