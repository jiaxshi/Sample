
ROS2_DISTRO=${1:-jazzy}
SRC_DIR=${2:-.}

echo "ROS2_DISTRO: ${ROS2_DISTRO}, Source dir: ${SRC_DIR}"

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

# Install required dependencies
rosdep install -y --rosdistro "$ROS2_DISTRO" --from-paths ${SRC_DIR} --ignore-src

# Source ROS 2 environment
source /opt/ros/$ROS2_DISTRO/setup.bash || exit $?