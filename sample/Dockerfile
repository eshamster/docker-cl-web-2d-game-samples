FROM eshamster/cl-base:2.3

RUN apk add --no-cache git

ENV PRJ_DIR "/root/.roswell/local-projects/work"

RUN mkdir ${PRJ_DIR} && \
    cd ${PRJ_DIR} && \
    git init && \
    git submodule add https://github.com/eshamster/ps-experiment.git && \
    git submodule add https://github.com/eshamster/cl-ps-ecs.git && \
    git submodule add https://github.com/eshamster/cl-web-2d-game.git

RUN ros run -e "(ql:quickload :cl-web-2d-game)" -q

RUN cd ${PRJ_DIR}/cl-web-2d-game/sample && \
    echo | ./sample.ros

COPY "./run.sh" "/root"
WORKDIR "/root"
CMD "./run.sh"
