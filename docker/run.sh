
echo "Note:This script should be run from student_worksessions/, not student_worksessions/docker/\n";

docker_command="docker run -it --rm -p 3000:3000 -v "$PWD:/usr/src/app" numascott/pie-student-worksessions:sec bash"
if [[ "$OSTYPE" == "msys"* ]]; then
	echo "Running for Git Bash on Windows"
   eval winpty $docker_command
else
   eval $docker_command
fi

# Run a Docker image
# docker run

# To open a shell we use interactive mode with tty
# -it 

# Upon quitting from our shell, clean up and remove the container
# --rm

# Connect port 3000 inside the container to port 3000 on our machine
# -p 3000:3000 

# Map /usr/src/app in the container to the files in our present working directory
# -v "$C:\Users\Jehan\Documents\PiE\Infrastructure\student_worksessions\usr\src\app" 

# Run this Docker image
# numascott/pie-student-worksessions:dev 

# Execute this command on the image to open a shell
# /bin/bash
