echo "This script should be run from student_worksessions/, not student_worksessions/docker/";
docker build -t numascott/pie-student-worksessions:dev -f docker/Dockerfile .
