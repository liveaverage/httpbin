FROM registry.access.redhat.com/ubi8/ubi-minimal

LABEL name="httpbin"
LABEL version="0.9.2"
LABEL description="A simple HTTP service."
LABEL org.kennethreitz.vendor="Kenneth Reitz"

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ARG UID=101
ARG GID=101

RUN microdnf -y clean all \
    && microdnf -y update --nodocs \
    && microdnf -y clean all \
    && rm -rf /var/cache/yum \
    && mkdir /tmp/pkgs

RUN microdnf -y install python3 python3-pip git \
    && pip3 install --no-cache-dir pipenv

ADD Pipfile Pipfile.lock /httpbin/
WORKDIR /httpbin
RUN /bin/bash -c "pip3 install --no-cache-dir -r <(pipenv lock -r)"

ADD . /httpbin
RUN pip3 install --no-cache-dir /httpbin

EXPOSE 8000

STOPSIGNAL SIGQUIT

USER $UID

CMD ["gunicorn", "-b", "0.0.0.0:8000", "httpbin:app", "-k", "gevent"]
