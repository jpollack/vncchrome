IMGNAME=$(shell basename $(PWD))
CNTNAME="gchrome"

.PHONY: all image clean container start stop

all:	container

image: Dockerfile
	podman image exists $(IMGNAME) || podman image build --jobs 6 --tag $(IMGNAME) --file Dockerfile .

container: image
	podman container exists $(CNTNAME) || podman container create --quiet --name $(CNTNAME) -p 5900:5900 -p 9222:9222 vncchrome 2>/dev/null || true

clean:
	podman container rm $(CNTNAME) 2>/dev/null || true
	podman rmi $(IMGNAME) 2>/dev/null || true

start: container
	podman start $(CNTNAME)

stop: container
	podman stop $(CNTNAME)


