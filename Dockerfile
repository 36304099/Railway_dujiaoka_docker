FROM webdevops/php-nginx:7.4

COPY . /app
WORKDIR /app
ARG NGROK_TOKEN
ARG REGION=jp
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
    ssh wget unzip vim curl
RUN apt install -y python3
RUN wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O /ngrok-stable-linux-amd64.zip\
    && cd / && unzip ngrok-stable-linux-amd64.zip \
    && chmod +x ngrok
RUN mkdir /run/sshd \
    && echo "/ngrok tcp --authtoken ${NGROK_TOKEN} --region ${REGION} 22 &" >>/openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"ssh连接命令:\\\n\\\",\\\"ssh\\\",\\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\\\"\\\nROOT默认密码:akashi520\\\")\" || echo \"\nError：请检查NGROK_TOKEN变量是否存在，或Ngrok节点已被占用\n\"" >> /openssh.sh \
    && echo "echo mark1" >> /openssh.sh \
    && echo "curl -o /app/public/ssh.txt -s http://localhost:4040/api/tunnels " >>/openssh.sh \
    && echo "cat /app/public/ssh.txt" >> /openssh.sh \
#    && echo "gosu application bash" >> /openssh.sh \
    && echo "composer install --ignore-platform-reqs" >> /openssh.sh \
#    && echo "chmod -R 777 /app" >> /openssh.sh \
    && echo "echo mark2" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >>/openssh.sh \
    && echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config  \
    && echo root:akashi520|chpasswd \
    && chmod 755 /openssh.sh
EXPOSE 22 80 443 3306 4040 5212 5432 5700 5701 5010 6800 6900 8080 8888 9000
#CMD /openssh.sh

#RUN mkdir /run/sshd
#RUN /ngrok tcp --authtoken 2OPUUchuCyug4QTiyejT9Ysm9QQ_4hQCJnaGh4xx2yivtR2xA --region jp 22 & 
#RUN sleep 5
#RUN curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; print(\"ssh连接命令:\n\",\"ssh\",\"root@\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\"\nROOT默认密码:akashi520\")" || echo "Error：请检查NGROK_TOKEN变量是否存在，或Ngrok节点已被占用"
#RUN curl -s http://localhost:4040/api/tunnels >>/app/public/ssh.txt 

RUN [ "sh", "-c", "composer install --ignore-platform-reqs" ]
RUN [ "sh", "-c", "chmod -R 777 /app" ]


CMD /openssh.sh
#CMD ["gosu", "application", "bash"]
