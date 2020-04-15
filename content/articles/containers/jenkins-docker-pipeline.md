Title:       Jenkins docker-pipeline
Author:      Jan
Date: 	     2017-10-30 19:00
Slug:	     jenkins-docker-pipeline
Tags: 	     jenkins, docker, pipeline, plugin, jenkinsfile, centos, master, slave, 7
Status:      published
Modified:    2017-10-30

in a previous blog post I talked about setting up a [dockerized jenkins master/slave setup]({filename}/articles/containers/dockerized-jenkins.md) and setting up a [private docker registry using nexus]({filename}/articles/containers/nexus-oss-repository.md).

The next thing on the roadmap was to use this jenkins setup to actually build new docker images for specific software. Before going to the different teams and talking how they now build their software and how this could be done using this new containerized setup I setted up a new jenkins job.

This jenkins job will build a generic jenkins slave docker container which will be used by the jenkins master to build some generic jobs.

to be able to build docker images through jenkins there is the [docker-pipeline](https://wiki.jenkins.io/display/JENKINS/Docker+Pipeline+Plugin) plugin which can be used by seeding a repository with the Dockerfile and a Jenkinsfile as described by this [tutorial](https://getintodevops.com/blog/building-your-first-docker-image-with-jenkins-2-guide-for-developers).

To get it configured I had to install the pipeline plugin, configure an SSH key into jenkins and github so jenkins was able to pull the repository together with the docker registry credentials from the private nexus which will be used in the jenkinsfile.

To use the docker-plugin docker needs to be installed on the jenkinsmaster. We already covered that part in the [dockerized jenkins master/slave]({filename}dockerized-jenkins.md) post.

Also the jenkins user needs to be added to the docker group too so it could try to communicate with the docker socket. Which is a weird combination because it's using the docker daemon of the docker node since the socket has been mounted on the jenkins master container.

Because we mount the docker socket from the host to the docker daemon the GID's of the docker group on both host and container need to match to each other. This is explained on the [github](https://github.com/visibilityspots/dockerfile-jenkins-docker#configuration) page which resides the config files for the [jenkins-docker](https://hub.docker.com/r/visibilityspots/jenkins-docker/) image.

## configuration
### GID

The container docker GID is already configured statically to 900 so by changing the one on the host they match and no permission issues should arise concerning this topic.

## credentials

### jenkins

To enable jenkins to read from github a jenkins public SSH key need to be added to repository and the private SSH key needs to be configured in jenkins

Next to the repository credentials we also need to configure credentials of the docker repository hosted on our nexus instance and refer to the ID in the jenkinsfile so the pipeline plugin can act accordingly.

## Jenkinsfile

The steps to be executed are defined in a Jenkinsfile this file can be added in a repository next to the Dockerfile and will perform some stages;

### clone repository
* perform a git checkout to the latest update
* trim the first 6 chars of the last commit to use as a tag version for the docker image to be builded

### build image
* build the image based on the Dockerfile

### test image
* use dgoss to perform a test based on the goss.yaml file

### push image
* push the created and tested image to the registry with the latest tag and with the short commit hash

```
node ('generic') {
  def container

  ansiColor('xterm') {
    stage('Clone repository') {
      checkout scm
      shortCommit = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
    }

    stage('Build image') {
      container = docker.build('visibilityspots/jenkins-docker')
    }

    stage('Test image') {
      sh 'export GOSS_FILES_STRATEGY=cp && /usr/local/bin/dgoss  run --name jenkins-docker-dgoss-test --rm -ti visibilityspots/jenkins-docker'
    }

    stage('Push image') {
      docker.withRegistry('https://nexus.repository', 'nexus-credentials-id') {
        container.push("${shortCommit}")
        container.push('latest')
      }
    }
  }
}
```

## testing the docker image

there is this tool called [goss](https://github.com/aelsabbahy/goss) which uses a simple yaml based approach to perform some tests against a server the same way serverspe wcorks. But there is a great wrapper script created called [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) which uses the same yaml file to perform the tests against a docker container it spins up especially for the testing case.

When one of the defined tests fails after the image has been build using the Dockerfile, the jenkins pipeline will abort and will not push the image to the registry. To be able to run the goss test suite the software is also preinstalled on our jenkins-slave docker images.

```
[jenkins-docker] Running shell script
export GOSS_FILES_STRATEGY=cp
/usr/local/bin/dgoss run --name jenkins-docker-dgoss-test --rm -ti visibilityspots/jenkins-docker
INFO: Starting docker container
INFO: Container ID: e0849245
INFO: Sleeping for 0.2
INFO: Running Tests
User: jenkins: exists: matches expectation: [true]
User: jenkins: groups: matches expectation: [["jenkins","docker"]]
Group: docker: exists: matches expectation: [true]
Group: docker: gid: matches expectation: [900]
Package: docker-ce: installed: matches expectation: [true]
Package: file: installed: matches expectation: [true]
Command: /usr/bin/file /etc/localtime: exit-status: matches expectation: [0]
Command: /usr/bin/file /etc/localtime: stdout: matches expectation: [/etc/localtime: symbolic link to /usr/share/zoneinfo/Etc/UTC]

Total Duration: 0.076s
Count: 8, Failed: 0, Skipped: 0
INFO: Deleting container
```

## jenkins job
Next up is the configuration of a pipeline defined jenkins job where the only config is the git repository and a pointer to the Jenkinsfile. If everything went well jenkins will execute the steps defined in the Jenkinsfile and store the docker image as a result in the nexus docker repository.

### configuration
| Name	| Value |
|-------|-------|
|Poll SCM | */1 * * * * |

## references

[https://getintodevops.com/blog/building-your-first-docker-image-with-jenkins-2-guide-for-developers](https://getintodevops.com/blog/building-your-first-docker-image-with-jenkins-2-guide-for-developers)
