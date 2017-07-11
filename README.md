# docker-php56

run docker
```bash
    $ docker run --name isse -v $(pwd)/../:/var/www/html -p 80:80 -p 443:443 --net=bridge -d paliari/php56-ssl
```
