
<p align="center">
<img src="https://raw.githubusercontent.com/goposse/haitch/assets/haitch_logo.png" align="center" width="460">
</p>

>H (named aitch /ˈeɪtʃ/ or haitch /ˈheɪtʃ/ in Ireland and parts of Australasia; plural aitches or haitches)

Haitch is an HTTP Client written in Swift for iOS and Mac OS X.

# Features

- Full featured, but none of the bloat
- Easy to understand, Builder-based architecture
- `Request` / `Response` injection allowing for "plug-in" functionality
- Extensible `Response` interface so you can design for whatever specific response your app requires


# The basics

Making a request is easy

```swift
let httpClient: HttpClient = HttpClient()
let req: Request = Request.Builder()
  .url(url: "http://my.domain.com/path", params: params)
  .method("GET")
  .build()

httpClient.execute(req) { (response: Response?, error: NSError?) -> Void in
  // deal with the response data (NSData) or error (NSError)
}
```

## JSON

Getting back JSON is simple

```swift
client.execute(request: req, responseKind: JsonResponse.self) { 
  (response, error) -> Void in
    if let jsonResponse: JsonResponse = response as? JsonResponse {
      print(jsonResponse.json)      // .json == AnyObject?
    }
  }
```


# FAQ

## Why is there no `sharedClient` (or some such)?

Because it's about your needs and not what we choose for you. You should both understand AND be in control of your network stack. If you feel strongly about it, subclass `HttpClient` and add it yourself. Simple.


## Why should I use this?

It's up to you. There are other fantastic frameworks out there but, in our experience, we only need a small subset of the things they do. The goal of Haitch was to allow you to write modular, reusable notworking logic that matches your specific requirements. Not to deal with the possiblity of "what if?".

## Has it been tested in production? Can I use it in production?

The code here has been written based on Posse's experiences with clients of all sizes. It has been production tested. That said, this incarnation of the code is our own. It's fresh. We plan to use it in production and we plan to keep on improving it. If you find a bug, let us know!

## Who the f*ck is Posse?

We're the best friggin mobile shop in NYC that's who. Hey, but we're biased. Our stuff is at [http://goposse.com](http://goposse.com). Go check it out.

# Outro

## Credits

Haitch is sponsored, owned and maintained by [Posse Productions LLC](http://goposse.com). Follow us on Twitter [@goposse](https://twitter.com/goposse). Feel free to reach out with suggestions, ideas or to say hey.

### Security

If you believe you have identified a serious security vulnerability or issue with Haitch, please report it as soon as possible to apps@goposse.com. Please refrain from posting it to the public issue tracker so that we have a chance to address it and notify everyone accordingly. 

## License

Haitch is released under a modified MIT license. See LICENSE for details.





