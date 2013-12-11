express-static-angular-seo
==========================

A simple reverse proxy that takes any URL and uses PhantomJS to fetch a version that has the JavaScript executed. Set the Host HTTP header to use this for more than one domain.

This app listens on port `8888` by default, it can be changed by setting the environment variable `NODE_PORT`.

When loading is done on your webpage, you should call 

```javascript
if(typeof window.callPhantom === "function") {
	window.callPhantom({rendered: true});
}
```

Or if you prefer coffeescript

```coffeescript
if typeof window.callPhantom is "function"
	window.callPhantom rendered: true
```
