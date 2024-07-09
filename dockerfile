ARG BASE_IMAGE=nvidia/cuda:12.2.0-devel-ubuntu20.04
ARG WORKING_DIR=/workspace
ARG PYTHON_VERSION="3.9.16"
ARG PYENV_URL="https://github.com/pyenv/pyenv.git"
# ARG PYENVVIRTUAL_URL="https://github.com/pyenv/pyenv-virtualenv.git"
ARG POETRY_URL="https://install.python-poetry.org"

FROM ${BASE_IMAGE}

# FONT
ENV DEBIAN_FRONTEND="noninteractive" \
	LC_ALL="C.UTF-8" \
	LANG="C.UTF-8"

# TIMEZONE
ENV TZ=Asia/Tokyo

# For software-development and easy to install for before python3.7
RUN apt-get update && apt-get install --no-install-recommends -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa

# For installing libraries
RUN apt-get update && apt-get install --no-install-recommends -y \
	autoconf \
	build-essential \
	ca-certificates \
	gcc \
	make \
	cmake \
	automake \
	libssl-dev \
	libffi-dev \
	libncurses5-dev \
	libncursesw5-dev \
	zlib1g \
	zlib1g-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev \
	liblzma-dev \
	libdbus-1-dev \
	libxml2-dev \
	libxmlsec1-dev \
	less \
	tree \
	llvm \
	xz-utils \
	tk-dev \
	ssh \
	openssh-client \
	python-openssl \
	vim \
	git \
	curl \
	wget \
	ffmpeg \
	sox \
	libasound-dev \
	portaudio19-dev \
	libportaudio2 \
	libportaudiocpp0 \
	libav-tools

# For setting pyenv ###############################################
# RUN pip install --upgrade pip
# https://github.com/pyenv/pyenv
ENV PYENV_ROOT=${HOME}/.pyenv
ENV PATH="$PYENV_ROOT/bin:$PATH"
ENV PATH="$HOME/.pyenv/shims:$PATH"

RUN git clone ${PYENV_URL} ${HOME}/.pyenv \
	&& ${PYENV_ROOT}/src/configure \
	&& make -C ${PYENV_ROOT}/src \
	&& echo '' >> ${HOME}/.bashrc \
	&& echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${HOME}/.bashrc \
	&& echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ${HOME}/.bashrc \
	&& echo 'export PATH="$PYENV_ROOT/shims:$PATH"' >> ${HOME}/.bashrc \
	&& echo 'eval "$(pyenv init -)"' >> ${HOME}/.bashrc
# For pyenv-virtualenv
# https://github.com/pyenv/pyenv-virtualenv
# RUN git clone ${PYENVVIRTUAL_URL} $(pyenv root)/plugins/pyenv-virtualenv \
#	echo 'eval "$(pyenv virtualenv-init -)"' >> ${HOME}/.bashrc
	
RUN . ${HOME}/.bashrc

# For Installing the specified Python and configure it for global recognition
RUN pyenv install ${PYTHON_VERSION} \
	&& pyenv global ${PYTHON_VERSION}

# For poetry installation #########################################
# https://python-poetry.org/docs/#installing-with-the-official-installer
# path for poetry install
#ENV POETRY_HOME_DIR=/opt/poetry
# update pip
RUN pip install --upgrade pip
# poetry install, ver specific directory
#RUN curl -sSL ${POETRY_URL} | POETRY_HOME=${POETRY_HOME_DIR} python3 - \
#	&& cd /usr/local/bin \
#	&& ln -s /opt/poetry/bin/poetry
#ENV PATH="$POETRY_HOME_DIR/bin:$PATH"

# simplified
RUN curl -sSL ${POETRY_URL} | python3 - \
	&& echo 'export PATH="$HOME/.local/bin:$PATH"' >> ${HOME}/.bashrc
ENV PATH="$HOME/.local/bin"
# The official Poetry documentation recommends that virtual environments be enabled even,
# when using Docker containers.
# true when you need virtualenv
RUN poetry config virtualenvs.create true
# false when you Don't need virtualenv
#RUN poetry config virtualenvs.create false


# For user custom #################################################
WORKDIR ${WORKING_DIR}
# Copy all local content into docker
COPY . ${WORKING_DIR}
