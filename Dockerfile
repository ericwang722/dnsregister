FROM centos:centos7
MAINTAINER qy

# Upgrade...
RUN yum upgrade -y
# add EPEL repo
RUN rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN yum -y update

#install AWS CLI 
RUN yum -y update && \
    yum -y install python-pip && \
    pip install awscli 

#add DNS register scripts and template
ADD scripts/dnsregister.sh  ./dnsregister/dnsregister.sh
ADD scripts/route53_action_template.json    ./dnsregister/route53_action_template.json

RUN chmod 755 ./dnsregister/dnsregister.sh
	
# register
CMD ["./dnsregister/dnsregister.sh"]
