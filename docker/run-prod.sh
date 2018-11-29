
echo "Note:This script should be run from student_worksessions/, not student_worksessions/docker/\n";

docker_command="docker run -it --rm -e SECRET_KEY_BASE='sldkjfskjlsdfdjlksdfsddfskhuhwihuwriugriugriufk2343hhu' -p 3000:3000 numascott/pie-student-worksessions:prod"
if [[ "$OSTYPE" == "msys"* ]]; then
	echo "Running for Git Bash on Windows"
   eval winpty $docker_command
else
   eval $docker_command
fi
