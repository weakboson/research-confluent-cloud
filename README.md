# Confluent Cloud の調査メモ

## 認証

SASL[^1]/PLAINが使えるようだ。ClusterのAPI keysを生成するとAPI keyがusernameとして、API secretがpasswordとして設定される。

### kcat

https://github.com/edenhill/kcat?tab=readme-ov-file#examples

```sh
$ kcat -b mybroker:9092 -X security.protocol=SASL_SSL -X sasl.mechanism=PLAIN -X sasl.username=myapikey -X sasl.password=myapisecret ...
```

### ruby-kafka(zendesk/ruby-kafka)

未検証。サンプルのコピペ。
https://github.com/zendesk/ruby-kafka?tab=readme-ov-file#plain

```rb
kafka = Kafka.new(
  ["mybroker:9092"],
  ssl_ca_cert: File.read('/etc/openssl/cert.pem'),
  sasl_plain_username: 'myapikey',
  sasl_plain_password: 'myapisecret'
  # ...
)
```

### Kafka Connect

https://docs.confluent.io/ja-jp/platform/7.1/kafka/authentication_sasl/authentication_sasl_plain.html#kconnect-long

#### properties

```properties
sasl.mechanism=PLAIN
security.protocol=SASL_SSL
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
  username="KAFKA_USERNAME" \
  password="KAFKA_PASSWORD";
```

#### docker-compose

```yaml
  debezium:
    image: debezium/connect:2.6.1.Final
    environment:
      - CONNECT_SASL_MECHANISM=PLAIN
      - CONNECT_SECURITY_PROTOCOL=SASL_SSL
      - CONNECT_SASL_JAAS_CONFIG=org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_USERNAME}" password="${KAFKA_PASSWORD}";
```

[^1]:Simple Authentication and Security Layer
