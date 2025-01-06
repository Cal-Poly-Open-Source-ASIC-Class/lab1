# Select Local or Remote Container
if [ "$1" = "-l" ] || [ "$1" = "--local" ]; then
    CONTAINER=asic
else 
    CONTAINER=fwilken/asic:latest
fi

TERM=xterm-256color
HOST=asic

if [ ! -d workspace ]; then
	mkdir -p workspace
fi


# Mac Install
if [[ "$OSTYPE" == "darwin"* ]]; then
    set -x

    xhost -
    xhost +localhost

    docker run -it --rm \
	--platform linux/amd64 \
        -v $(pwd)/workspace:/home/$HOST/workspace:rw \
        -v ~/.ssh:/home/$HOST/.ssh\
        -v ~/.gitconfig:/home/$HOST/.gitconfig\
        -e DISPLAY=host.docker.internal:0 \
        -e "TERM=$TERM"\
        --hostname $HOST \
        $CONTAINER bash

# Linux/WSL Install
else 
    set -x
    xhost local:root
    docker run -it --rm \
                -v $(pwd)/workspace:/home/$HOST/workspace:rw\
                -v ~/.ssh:/home/$HOST/.ssh\
                -v ~/.gitconfig:/home/$HOST/.gitconfig\
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v /mnt/wslg:/mnt/wslg \
                -e DISPLAY \
                -e WAYLAND_DISPLAY \
                -e XDG_RUNTIME_DIR \
                -e PULSE_SERVER \
                -e "TERM=$TERM"\
                --hostname $HOST \
                --net=host \
                $CONTAINER -s /bin/bash
fi

