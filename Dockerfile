FROM nginx:alpine

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./mime.types /etc/nginx/mime.types
COPY ./fastcgi_params /etc/nginx/fastcgi_params
COPY ./h5bp /etc/nginx/h5bp

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

