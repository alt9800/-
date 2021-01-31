require 'twitter'
require 'yaml'

def last24hours # 24時間以内ののアクティビティを抽出する # 6時間を境界としてツイート状況をフィードバックする
  cons_arr = []
  @arr.each do |record| 
    if Time.parse("#{record[0].to_s} #{record[1].to_s}") > (Time.now - (3600 * 24) )  then
      cons_arr << Time.parse("#{record[0].to_s} #{record[1].to_s}")
    end
  end
  diff = []
  # puts  cons_arr
  cons_arr.each_cons(2) do |front , back|
    diff << front - back 
  end
  @maxspan = ((diff.max)/3600).to_i
  if diff.max / 3600 > 6.0 then
    @branch = "インターネットから程よく距離が取れててえらいめる〜！"
  else
    @branch = "こまめな確認はえらいめるけど、たまには画面から目を離す時間が必要める〜！"
  end
end


def tweet_id2time(id) #tweetIDから時刻を算出する
  Time.at(((id.to_i >> 22) + 1288834974657) / 1000.0) 
end


def pickedup #リプライしたユーザのツイートを取ってきて配列に格納する #RTであるものは除く
  @arr = Array.new
  @client.search("from:#{@reply_user}").take(150).each do |text|
    if text.full_text.split(" ")[0] != "RT"
      @arr << tweet_id2time(text.id).to_s.split(" ")[0..1]
    end
  end
  last24hours
end

def mentionTimeline #主機能部分 リプライの文言に「褒めて」があったら駆動して上のメソッドを走らせる。 # 過去60秒のツイート(リプライ)のみを対象にする
  just_time = Time.now
  search_span = 60.0
  @client.mentions_timeline.each do |tweet|
    if tweet.is_a?(Twitter::Tweet)
      if tweet.text.split(" ")[1] == "褒めて" && tweet_id2time(tweet.id) >= just_time -  search_span
        @reply_user = tweet.user.screen_name
        pickedup
        @client.update("@#{tweet.user.screen_name}\n過去24時間の#{tweet.user.name}さんがTwitterから離れていた時間は最大で#{@maxspan}時間だっためる〜！\n#{@branch}", options = {:in_reply_to_status_id => tweet.id})
      end
    end
  end
end


CONFIG = YAML.load_file('config.yaml')

# user_id = CONFIG["user_id"]
consumer_key = CONFIG["consumer_key"]
consumer_secret = CONFIG["consumer_secret"]
access_token = CONFIG["access_token"]
access_token_secret = CONFIG["access_token_secret"]


@client = Twitter::REST::Client.new do |config|
  config.consumer_key    = consumer_key
  config.consumer_secret   = consumer_secret
  config.access_token    = access_token
  config.access_token_secret = access_token_secret
end


mentionTimeline

# 実装済みの機能

# リプライをしたユーザの前日の最長ツイート間隔を調べる (150件とってくる)
# ツイートの最大値を「ツイッターからはなれていた時間」とみなしてリプライを行う。

# mentionTimeline -> pickedup -> tweet_id2time + last24hours といった構成
# 