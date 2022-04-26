FROM debian:bullseye-slim AS base-unsquashed

ENV \
	DEBIAN_FRONTEND='noninteractive' \
	GEOMETRY='1280x1024' \
	LANG='en_US.UTF-8' \
	LANGUAGE='en_US:en' \
	LC_ALL='en_US.UTF-8' \
	TZ='America/Los_Angeles'

RUN \
	apt-get -y update && \
	apt-get install -y --no-install-recommends \
	        apt-transport-https \
	        ca-certificates \
	        curl \
	        gnupg2 && \
	curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
	echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list && \
	apt-get -y update && \
	apt-get install -y --no-install-recommends \
		google-chrome-stable \
		locales \
		socat \
		tigervnc-standalone-server \
		tzdata \
		wmctrl \
		xdotool \
		xterm && \
	rm -rf /var/lib/apt/lists/*

RUN \
	ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
	echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
	dpkg-reconfigure --frontend noninteractive tzdata locales

RUN \
	groupadd -r chrome && \
	useradd -u 1000 -g chrome -G audio,video chrome && \
	mkdir -p /home/chrome/Downloads && \
	mkdir -p /data && \
	chown -R chrome:chrome /home/chrome /data

USER chrome

WORKDIR /home/chrome

COPY init /

EXPOSE 5900
EXPOSE 9222

CMD ["/init"]
