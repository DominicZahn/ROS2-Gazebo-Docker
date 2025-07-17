ROS_DISTRO=jazzy
CONTAINER_NAME=ros2-$(ROS_DISTRO)
GPU:=$(shell command -v nvidia-smi >/dev/null 2>&1 && echo true || echo false)
build:
	mkdir -p $(CURDIR)/ws/src
	chmod -R o+rwx $(CURDIR)/ws
	docker build -t $(CONTAINER_NAME) .

run:
	xhost +local:docker
	-docker rm -f $(CONTAINER_NAME) 2>/dev/null || true
	docker run -it \
		--user robot \
		--hostname $(CONTAINER_NAME) \
		$(if $(filter true, $(GPU)),--gpus all --runtime=nvidia --env="NVIDIA_VISIBLE_DEVICES=all" --env="NVIDIA_DRIVER_CAPABILITIES=all",) \
		--env="DISPLAY" \
		--env="QT_X11_NO_MITSHM=1" \
		--net=host \
		--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
		--mount type=bind,src=$(CURDIR)/ws,dst=/home/robot/ws \
		--mount type=bind,src=$(CURDIR)/../pkgs,dst=/home/robot/ws/pkgs \
		--privileged \
		--name $(CONTAINER_NAME) \
		$(CONTAINER_NAME)
stop:
	-docker stop $(CONTAINER_NAME) || true

clean:
	sudo rm -rf $(CURDIR)/ws/build/
	sudo rm -rf $(CURDIR)/ws/install/
	sudo rm -rf $(CURDIR)/ws/log/
	-docker rmi -f $(CONTAINER_NAME) 2>/dev/null || true
rebuild:
	$(MAKE) clean
	docker build --no-cache -t $(CONTAINER_NAME) .
	$(MAKE) run
