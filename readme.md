# docker-webnode #
This docker image used for web, microservice and builtin image optimizer library.

- Nginx v1.14
- PHP v7.2
- Composer v1.6.5
- JpegOptim v1.4.3
- OptiPNG v0.7.6
- Gifsicle 1.88

## Docker run
- Expose port 80
- Mount your sourcecode to `/var/www/src` on container. Such as: `-v /path/to/yourcode:/var/www/src`
- You can mount a local directory to nginx log directory at `/var/log/nginx/`. Such as: `-v /path/to/local/log/dir:/var/log/nginx/`