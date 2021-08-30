FROM centos:latest

COPY mongodb-org.repo /etc/yum.repos.d/mongodb-org.repo
RUN yum -y install mongodb-org

RUN yum -y install epel-release
RUN yum -y install mosquitto

WORKDIR /usr/src

COPY *.sh ./

CMD /usr/src/entrypoint.sh
