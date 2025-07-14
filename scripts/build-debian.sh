ROS2_DISTRO="$1"
SRC_DIR="${2:-.}"
OUTPUT_DIR="$3"
UNIQUE_VERSION="$4"

echo "SRC_DIR: ${SRC_DIR}"

mkdir -p $OUTPUT_DIR
cd ${SRC_DIR}

# Source ROS 2 environment
source /opt/ros/$ROS2_DISTRO/setup.bash || exit $?

# Do for each ROS 2 packages path
for PACKAGE in $(colcon list -t | cut -f2)
do
  cd $SRC_DIR/$PACKAGE || continue
  # Generate changelogs
  catkin_generate_changelog --all || true

  # Generate Debian rules
  if [ "$UNIQUE_VERSION" == "false" ]
  then
    bloom-generate rosdebian --ros-distro "$ROS2_DISTRO" || exit $?
  else
    bloom-generate rosdebian --ros-distro "$ROS2_DISTRO" -i $(date +%s) || exit $?
  fi

  # Build package using fakeroot
  fakeroot debian/rules binary -j8 || exit $?

  # Install all build result
  sudo dpkg --install ../*.deb || continue

  # Move build result to the output directory
  mv ../*.deb $OUTPUT_DIR &&
   (mv ../*.ddeb $OUTPUT_DIR || true)
  ls -al $OUTPUT_DIR
done