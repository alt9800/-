require 'twitter'
require 'yaml'
require 'gr/plot'
# 安定版に時刻をコレクション、および、画像出力機能を追加していく



# 画像作成機能

def mkimg(counts,timeline)
  timeline_rev = timeline.reverse.slice(0,24).map {|t|t.strftime("%H")}
  GR.barplot(timeline_rev, counts)
  GR.savefig("date_#{@reply_user}.jpg",title: "#{@reply_user}\'s \nlast 24 hours tweets.(#{@just_time})")
end



# 1時間毎のツイート数をカウントしていく
def count_tweets
  timeline =[] #stdtimeから3600 * 24, 23 , 22 ,とリストに入れてタイムラインを作る
  (0..24).each do |i|
    timeline << @just_time - (3600 * i) 
  end
  counts = []
  # p timeline
  timeline.reverse.each_cons(2) do |a,b|
    count = 0
    @cons_arr.each do |j|
      if a <= j && j <= b then
        count += 1
      end
    end
    counts << count
  end 
  # p counts 
  mkimg(counts,timeline)
end



# 24時間以内のアクティビティを抽出する
# 6時間を境界としてツイート状況をフィードバックする
def last24hours 
  @cons_arr = [] 
  @arr.each do |record| 
    if Time.parse("#{record[0].to_s} #{record[1].to_s}") > (@just_time - (3600 * 24) )  then
      @cons_arr << Time.parse("#{record[0].to_s} #{record[1].to_s}")
    end
  end
  @cons_arr << @just_time - (3600 * 24) #24時間前を含むスパンが最大だった場合にそこを選ぶためにケツに追加する
  diff = []
  p @cons_arr
  @cons_arr.each_cons(2) do |front , back|
    diff << front - back 
  end
  @maxspan = ((diff.max)/3600).to_i
  if diff.max / 3600 > 6.0 then
    @branch = "インターネットから程よく距離が取れててえらいめる〜！"
  else
    @branch = "こまめな確認はえらいめるけど、たまには画面から目を離す時間が必要める〜！"
  end
  @cons_arr.delete_at(-1)
  # p @cons_arr
  count_tweets
end

# ツイート時刻を算出する
def tweet_id2time(id) 
  Time.at(((id.to_i >> 22) + 1288834974657) / 1000.0) 
end


#リプライしたユーザのツイートを取ってきて配列に格納する #RTであるものは除く(他のユーザからリツイートされたものに当人のIDが乗るため)

def pickedup 
  @arr = Array.new
  @client.search("from:#{@reply_user}").take(150).each do |text|
    if text.full_text.split(" ")[0] != "RT"
      @arr << tweet_id2time(text.id).to_s.split(" ")[0..1]
    end
  end
  last24hours
end


#主機能部分 リプライの文言に「褒めて」または「教えて」があったら駆動して上のメソッドを走らせる。 # 過去60秒のツイート(リプライ)のみを対象にする
def mentionTimeline 
  @just_time = Time.now
  search_span = 60.0
  # search_span = 60.0 * 60 * 24  #n時間のツイートを拾ってくる デバッグ用
  @client.mentions_timeline.each do |tweet|
    if tweet.is_a?(Twitter::Tweet)
      if tweet.text.split(" ")[1] == ("褒めて"||"教えて") && tweet_id2time(tweet.id) >= @just_time -  search_span then
        p @reply_user = tweet.user.screen_name
        pickedup
        # ちなみにclient.updateも標準出力に渡せたりするらしい
        images = []
        images << File.new("date_#{@reply_user}.jpg")
        puts "@#{tweet.user.screen_name}\n過去24時間の#{tweet.user.name}さんがTwitterから離れていた時間は最大で#{@maxspan}時間だっためる〜！\n#{@branch}"
        @client.update_with_media("@#{tweet.user.screen_name}\n過去24時間の#{tweet.user.name}さんがTwitterから離れていた時間は最大で#{@maxspan}時間だっためる〜！\n#{@branch}", images ,options = {:in_reply_to_status_id => tweet.id})
        # imageを伴わないツイートを行う場合
        # @client.update("@#{tweet.user.screen_name}\n過去24時間の#{tweet.user.name}さんがTwitterから離れていた時間は最大で#{@maxspan}時間だっためる〜！\n#{@branch}", options = {:in_reply_to_status_id => tweet.id}) 
      end
    end
  end
end


CONFIG = YAML.load_file('config.yaml')

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

# mentionTimeline -> pickedup -> tweet_id2time + last24hours -> count_tweets  -> mkimgといった構成