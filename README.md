## Overview
This is a minimalistic, production ready, performance first Docker PHP webserver, realized with Nginx 1.13.7 and PHP 7.1.12. It's basically a boilerplate for our other, more specialized Docker images, but can be used for any PHP project ootb. 

Thankfully forked from [richarvey/nginx-php-fpm](https://github.com/richarvey/nginx-php-fpm).

## Quick Start
#### To pull from docker hub:
```
docker pull visenda/php-webserver:latest
```
#### Running
By just running the container, it will show you a php_info page:
```
docker run -d -p 80:80 --name php-project visenda/php-webserver
```

You can easily attach your local project dir to /var/www/html, to be able to see your project:
```
docker run -d -p 80:80 --name php-project -v /Users/.../shop-project:/var/www/html visenda/php-webserver
```
Hint: The nginx user has uid 1000 and gid 1001, so make sure that your project files are executable. 

Now browse to ```http://<DOCKER_HOST>``` to see your project.

## Extending
As already said, this is a boilerplate image. It provides basic php extensions (see Dockerfile) and is meant to be extended with more special settings/configs/extensions.

To do so, follow this steps:

- Create a Dockerfile ```FROM visenda/php-webserver:latest```
- Use ```RUN apk add --no-cache dep1 dep2 dep3...``` to install dependencies
- Use ```RUN docker-php-ext-install mysqli ...``` to install PHP extensions
- Feel free to customize the webserver for your app
- Build