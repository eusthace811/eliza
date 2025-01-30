@echo off

@REM gcloud auth configure-docker gcr.io

@REM --no-cache
docker build -t noid-eliza .

docker tag noid-eliza gcr.io/noid-one-development/noid-eliza:latest

docker push gcr.io/noid-one-development/noid-eliza:latest
