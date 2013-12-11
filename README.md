express-static-angular-seo
==========================

A simple reverse proxy that takes any URL and uses PhantomJS to fetch a version that has the JavaScript executed. Set the Host HTTP header to use this for more than one domain.

This app listens on port `8888` by default, it can be changed by setting the environment variable `NODE_PORT`.

When loading is done on your webpage (all XHR, rendering, etc), you should call 

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

## Angular.js

If you are using angular.js, you can use my module [angular-static-seo](https://github.com/alecgorge/angular-static-seo). Instructions are on that readme.

# Nginx Setup

You can setup nginx to automatically send Google, Facebook, Twitter, etc to the pre-rendered versions. Nginx can also automatically cache the results:

## nginx.conf

```
...
http {
	...
	# caching options
	proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=node_express_cache:8m max_size=1000m inactive=600m;
	proxy_temp_path /var/cache/tmp;

	server_names_hash_bucket_size 64;
	...
}
```

## sites-enabled/demo

```
upstream node_express {
    server localhost:9000;
}

upstream express_static_angular_seo {
	server localhost:8888;
}

server {
	listen 80;

	access_log on;
	error_log on;

	root /www/var/express/public;
	index index.html;

	server_name example.com;

	set $is_bot '0';

	if ($http_user_agent ~ '(facebookexternalhit|googlebot|bingbot|twitterbot|teoma|Baiduspider)') {
		set $is_bot '1';
	}

	location / {
		add_header X-Bot $is_bot;

		proxy_cache node_express_cache;

		proxy_redirect off;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_cache_key "$scheme$host$request_uri$is_bot";

		proxy_cache_valid 1d;

		add_header X-Cached $upstream_cache_status;

		proxy_pass http://node_express;
		if ($is_bot = '1') {
			proxy_pass http://express_static_angular_seo;
		}
	}
}
```

## Clearing/purging the cache

```
find /var/cache/nginx/ -type f -delete
service nginx restart
```

Restarting nginx is important after clearing the cache.
