# TODO consolidate logs
FROM alpine

RUN mkdir /run/nginx

# TODO try gcc instead
RUN apk update && \
    apk add g++ libffi-dev cairo-dev nginx python2 python2-dev py2-pip uwsgi-python

RUN pip install --upgrade pip
ENV PYTHONPATH /opt/graphite/lib/:/opt/graphite/webapp/
RUN pip install --no-binary=:all: https://github.com/graphite-project/whisper/tarball/master && \
    pip install --no-binary=:all: https://github.com/graphite-project/carbon/tarball/master && \
    pip install --no-binary=:all: https://github.com/graphite-project/graphite-web/tarball/master

RUN django-admin.py migrate --settings=graphite.settings --run-syncdb

# RUN pip install gunicorn supervisor
RUN pip install supervisor
RUN mkdir /var/log/supervisor
# RUN gunicorn wsgi --workers=4 --bind=127.0.0.1:8080 --log-file=/var/log/gunicorn.log --preload --daemon --pythonpath=/opt/graphite/webapp/graphite
# ADD nginx.conf /opt/graphite/conf/nginx.conf
RUN echo 'daemon off;' >> /etc/nginx/nginx.conf
ADD nginx.conf /etc/nginx/conf.d/default.conf
ADD uwsgi.ini /opt/graphite/conf/uwsgi.ini
ADD wsgi.py /opt/graphite/conf/wsgi.py
ADD carbon.conf /opt/graphite/conf/carbon.conf
ADD storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD supervisord.conf /opt/graphite/conf/supervisord.conf

CMD supervisord -n -c /opt/graphite/conf/supervisord.conf
