# homeltan
![header](https://github.com/alt9800/homeltan/blob/main/%E3%83%98%E3%83%83%E3%82%BF%E3%82%99%E8%A4%92%E3%82%81%E3%82%8B%E3%81%9F%E3%82%93_%E7%B8%AE%E5%B0%8F.png)

# これはなに
[@homeltan](https://twitter.com/homeltan)に「褒めて」とリプライをすると過去24時間のツイート状況を教えてくれて、
インターネットから適切に距離をとってると褒めてくれるbot
のソースコード

 # 現状の問題点
 
 リプライ読み込みでRESTを使っているのでユーザーからのリプライに対して全返信してしまう
 STREAMのAPIを使ってリプライすべきユーザおよびツイートを適切に絞り込む必要がある。


#　今後実装する機能

ツイート時間をlogとして取得しているので、これを何らかの形でリプしたユーザに詳細に伝えられればいいと思う。


# fork元
[ほめたもん](https://github.com/seven320/metamon_code)
正確にはリスペクトしてコンセプトを引き継いだもの。

# その他
実運用上は`config.yaml`を同ディレクトリに作って
```
# user_id = CONFIG["user_id"]
consumer_key = CONFIG["consumer_key"]
consumer_secret = CONFIG["consumer_secret"]
access_token = CONFIG["access_token"]
access_token_secret = CONFIG["access_token_secret"]
```
を読み込ませる
