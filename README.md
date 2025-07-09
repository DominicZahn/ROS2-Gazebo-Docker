# Template Docker for [ros_gz_project_template](https://github.com/gazebosim/ros_gz_project_template/tree/main)

This is a Docker setup for projects using ROS 2 and Gazebo 2. It is tested and developed especially for the structure in [ros_gz_project_template](https://github.com/gazebosim/ros_gz_project_template/tree/main).

It only uses Docker and Make to manage the Docker. So this setup can be used directly from the command line without requiring any additional software.

## Prerequirements
- Docker
- make
- (for NVIDIA GPUs) [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Useage
### Structure
```
.
+-- ws
|   +-- src
|   |   +-- (*)
|   |
|   +-- build
|   +-- install
|   +-- log
|
+-- Dockerfile
+-- Makefile
+-- .gitignore
+-- README.md

(*) your ROS2 project goes here
```

### Docker Management
The docker is managed by the [Makefile](/Makefile). The four commands bundle some arguments and management commands together to create a more friendly Docker experience.

| Command | Description |
|---------|-------------|
| `run` | launches the docker with `docker run` and enables X11-forwarding on the host machine |
| `build` | - create `ws/src/` and adjust permissions <br>- calls `docker build` with the correct container name |
| `clean` | removes colcon artifacts in `ws` and deletes Docker from the internal list (**this needs sudo privileges**, because Docker had sudo permissions when creating those files)<br> -> full `build` is necessary! |
| `rebuild` | combination of `clean` and `build` without the use of cache |
| `stop` | can be used to stop the docker when the process where `run` was called is not accessible (calls `docker stop`) |

Most of the time you will use `make build` once and then only launch the docker with `make run`.
You only need to build or rebuild if you added some packages to the [Dockerfile](/Dockerfile).

### Inside the Workspace
This Docker container was set up to fit the needs of ROS2 projects that were created from [ros_gz_project_template](https://github.com/gazebosim/ros_gz_project_template/tree/main).
You can put all your projects and ROS2 packages inside the [src](/ws/src/) directory.

To build everything, the alias `build` can be used inside the container to move to the parent workspace folder (`ws`) and then execute `colcon build --symlink-install`. With this setup, the problem of creating random colcon artifacts is a thing of the past.

### Testing
To test if everything is setup a correctly, it is recommended to clone the [QuadrupedA1Controller](https://github.com/faoezg/QuadrupedA1Controller/tree/main) repository inside the [src](/ws/src/) directory. Follow the instructions of the repository to see if the workspace behaves as expected.
