echo "Note:This script should be run from student_worksessions/, not student_worksessions/docker/\n";

# Run a Docker image
docker run\
        -it\ # To open a shell we use interactive mode with tty
        --rm\ # Upon quitting from our shell, clean up and remove the container
        -p 3000:3000\ # Connect port 3000 inside the container to port 3000 on our machine
        -v "$PWD:/usr/src/app"\ # Map /usr/src/app in the container to the files in our present working directory
        numascott/pie-student-worksessions:dev\ # Run this Docker image
        /bin/bash\ # Execute this command on the image to open a shell


