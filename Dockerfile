FROM ros:jazzy
ENV ROS_DISTRO=jazzy

# General packages
RUN apt-get update && apt-get install -y \
    x11-apps \
    tmux \
    htop \
    nvtop \
    git \
    sudo \
    wget \
    gnupg2 \
    mesa-utils \
    python3-pip \
    python-is-python3 \
    python3-pygame

# ROS2 packages
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    ros-${ROS_DISTRO}-rosidl-generator-dds-idl \
    ros-${ROS_DISTRO}-ros-gz \
    ros-${ROS_DISTRO}-ros-gz-sim \
    ros-${ROS_DISTRO}-ros-gz-bridge \
    ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ament-cmake \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    python3-colcon-common-extensions \
    python3-vcstool

RUN rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive

# Create user robot
ARG UID=1000 # set on run
ARG GID=1000 # set on run
RUN echo ${GID} ${UID}
RUN groupadd -g ${GID} robot && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash robot && \
    echo "robot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER robot

# Setup workspace
WORKDIR /home/robot/ws

# bashrc
RUN echo "\
export TERM=xterm-256color\n\
source /opt/ros/${ROS_DISTRO}/setup.bash\n\
source /home/robot/ws/install/setup.bash\n\
alias build='cd /home/robot/ws/ && colcon build --symlink-install && source install/setup.bash'\n\
" >> /home/robot/.bashrc

# GPU plugins in Gazebo
ENV IGN_RENDER_ENGINE=ogre2
ENV OGRE2_RENDER_SYSTEM=gl

# X11 forwarding
ENV DISPLAY=:1
ENV QT_X11_NO_MITSHM=1
ENV XAUTHORITY=/tmp/.docker.xauth

SHELL ["/bin/bash", "-c"]
CMD ["tmux"]
