FROM node:7
ADD app.js /app.js
ENTRYPOINT [ "node", "app.js" ]

# docker build -t kubia .
# docker tag kubia cyanial9/kubia
# docker push cyanial9/kubia
# kubectl run kubia --image=cyanial9/kubia --port=8080 --generator=run/v1
# kubectl expose rc kubia --type=LoadBalancer --name kubia-http