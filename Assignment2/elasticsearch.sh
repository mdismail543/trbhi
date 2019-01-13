docker network create elk
echo " Installing elasticserach"
docker run -d --name elasticsearch --net elk -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:6.4.0
sleep 30
echo " Status of Elastic search"
curl http://127.0.0.1:9200/_cat/health
curl 'http://localhost:9200/?pretty'