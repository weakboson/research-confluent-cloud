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

## Terraform

Confluent Cloud は公式 Terraform Provider がよいようだ。(Kafka は Mongey さんがデファクトだと思うが。)

https://registry.terraform.io/providers/confluentinc/confluent/latest

1. Environment, Kafka Cluster を作成。これは `CONFLUENT_CLOUD_API_KEY`, `CONFLUENT_CLOUD_API_SECRET` で作成できる。実際には `OrganizationAdmin` Role の Service Account の API キーで作成するのが良さげ
1. Service Account を作成。Service Account は Organization に所属。特定の Environment に所属しない
1. Service Account に Role を紐づけ。この操作で特定の Environment や Kafka Cluster に対する何らかの権限を持った Role と Service Account が関連付けられる。
1. Service Account に対応した API キーを発行。この API キーで Kafka Cluster にトピックを作成したりできるようになる

[^1]:Simple Authentication and Security Layer
