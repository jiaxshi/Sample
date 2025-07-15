
ROS2_DISTRO=${1:-jazzy}
SRC_DIR=${2:-.}

echo "ROS2_DISTRO: ${ROS2_DISTRO}, Source dir: ${SRC_DIR}"

# Add QCOM PPA
sudo add-apt-repository ppa:ubuntu-qcom-iot/qcom-noble-ppa
sudo add-apt-repository ppa:ubuntu-qcom-iot/qirp
sudo apt update

# Add ROS key
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg || exit $?

# Add ROS 2 repository to the source list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null || exit $?

# Install development tools
sudo apt update && sudo apt install -y \
  debhelper \
  dh-python \
  ros-dev-tools \
  fakeroot || exit $?

# Initialize rosdep
sudo rosdep init
rosdep update

# Add QCOM yaml file
# Temp link for debug purpose
sudo wget https://github.com/qualcomm-qrb-ros/qrb_ros_distro/blob/080a6ba7bbcd335736335125f11cdd31c05c9f54/jazzy/qcom-distribution.yaml -O /etc/ros/rosdep/sources.list.d/qcom-distribution.yaml
echo "yaml file:///etc/ros/rosdep/sources.list.d/qcom-distribution.yaml" | sudo tee -a /etc/ros/rosdep/sources.list.d/20-default.list

# Install required dependencies
rosdep install -y --rosdistro "$ROS2_DISTRO" --from-paths ${SRC_DIR} --ignore-src

# Source ROS 2 environment
source /opt/ros/$ROS2_DISTRO/setup.bash || exit $?