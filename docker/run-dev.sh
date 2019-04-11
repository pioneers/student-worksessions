
echo "Note:This script should be run from student_worksessions/, not student_worksessions/docker/\n";

docker_command="docker run -it --rm -p 3000:3000 -v "$PWD:/usr/src/app" numascott/pie-student-worksessions:dev bash"
if [[ "$OSTYPE" == "msys"* ]]; then
	echo "Running for Git Bash on Windows"
   eval winpty $docker_command
else
   eval $docker_command
fi
