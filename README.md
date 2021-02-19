# homeltan
![header](https://github.com/alt9800/homeltan/blob/main/%E3%83%98%E3%83%83%E3%82%BF%E3%82%99%E8%A4%92%E3%82%81%E3%82%8B%E3%81%9F%E3%82%93_%E7%B8%AE%E5%B0%8F.png)

# これはなに
[@homeltan](https://twitter.com/homeltan)に「褒めて」とリプライをすると過去24時間のツイート状況を教えてくれて、
インターネットから適切に距離をとってると褒めてくれるbot
のソースコード

 # 現状の問題点
 
 - グラフ出力を行った際にディレクトリの容量が膨れ上がる可能性がある。
 - グラフの軸の調整
 - グラフの文字入力に問題がある(フォントも含めて)
 
 ~~リプライ読み込みでRESTを使っているのでユーザーからのリプライに対して全返信してしまう~~
 ~~STREAMのAPIを使ってリプライすべきユーザおよびツイートを適切に絞り込む必要がある。~~


# 今後実装する機能

- ツイート時間をlogとして取得しているので、これを何らかの形でリプしたユーザに詳細に伝えられればいいと思う。
-- 実装した(GR　plotでツイート概況を画像として返す)

- 現状配列に格納したキーワードで真偽判定して駆動しているので、「ほめるたんのリプライを見た人からのリプライ」には対応してないので、もうちょっとコーナーケースを攻めたい
　[参考](https://twitter.com/homeltan/status/1361636958733168646?s=20)


# fork元

## [ほめたもん](https://github.com/seven320/metamon_code)
正確にはリスペクトしてコンセプトを引き継いだもの。

# その他

## 実運用上は`config.yaml`を同ディレクトリに作って
```
# user_id = CONFIG["user_id"]
consumer_key = CONFIG["consumer_key"]
consumer_secret = CONFIG["consumer_secret"]
access_token = CONFIG["access_token"]
access_token_secret = CONFIG["access_token_secret"]
```
を読み込ませる



## 本番環境がCentなのでGRのgemはそれ用のバイナリを配置する必要がある。
https://github.com/sciapp/gr/releases

```
curl -OL https://github.com/sciapp/gr/releases/download/v0.54.0/gr-0.54.0-CentOS-x86_64.tar.gz
tar -zxvf gr-0.54.0-CentOS-x86_64.tar.gz
echo "export GRDIR=/home/alt9800/dev/homeltan/gr" >>~/.bashrc
gem install ruby-gr
gem install numo-narray
```

なおcron駆動を行う都合上、GRDIRはshellにも記載すること

## 仕様など

[GR.rbはCentOS8ではqt(qt5devel)の破損によりフル機能が使えない様子](https://gitter.im/red-data-tools/ja?at=5e24f49f805f17428de65339)

また、フォント周りの警告ダイアログがついて回るのでこちらも要検討


