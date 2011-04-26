#-*- coding: utf-8 -*-
require 'socket'

kunren = []
kunren.push "auth good"

kunren.push <<-EOM
begin
{"eew":{"total_messages":1,"is_continue":true,"is_final":false,"type":"通常発表","drill_type":"通常","fixing_reason":"M及び震源位置が変化したため","reported_by":"破滅","reported_at":"2011-04-15 23:34:50 +0900","quake_at":"2011-04-15 23:34:19 +0900","id":"20110415233435","revision":4,"epicenter":{"name":"荒川智則","position":"N0.0 E0.0","probability":"防災科研システム(5点以上)[防災科学技術研究所データ]","probability_jma":"テリトリー法(2点)[気象庁データ]"},"depth":10,"magnitude":5.1,"maximum_intensity":"3(訓練)","depth_probability":"防災科研システム(5点以上)[防災科学技術研究所データ]","magnitude_probability":"全点全相(最大5点)[気象庁データ]","land_or_sea":"海域","is_warning":true},"ebi":null}
end
EOM

kunren.push <<-EOM
begin
{"eew":{"total_messages":1,"is_continue":true,"is_final":false,"type":"通常発表","drill_type":"通常","fixing_reason":"M及び震源位置が変化したため","reported_by":"破滅","reported_at":"2011-04-15 23:34:53 +0900","quake_at":"2011-04-15 23:34:16 +0900","id":"20110415233435","revision":5,"epicenter":{"name":"荒川智則浜","position":"N0.0 E0.0","probability":"防災科研システム(5点以上)[防災科学技術研究所データ]","probability_jma":"テリトリー法(2点)[気象庁データ]"},"depth":10,"magnitude":6.6,"maximum_intensity":"6強(訓練)","depth_probability":"防災科研システム(5点以上)[防災科学技術研究所データ]","magnitude_probability":"全点P相(最大5)[気象庁データ]","land_or_sea":"陸域","is_warning":true},"ebi":[{"area":"荒川浜通り","estimated_intensity":"6弱から6強(訓練)","estimated_arriving_at":null,"has_warning":true,"already_arrived":true},{"area":"某ヒガシニホンバシ","estimated_intensity":"5弱から5強(訓練)","estimated_arriving_at":null,"has_warning":true,"already_arrived":true}]}
end
EOM

kunren.push "ping"

server = TCPServer.open("0.0.0.0",6743)
i = 0
socket = server.accept
Thread.new do
  while buf = socket.gets
    p buf
  end
end
while STDIN.gets
  puts "-> #{kunren[i].inspect}"
  socket.puts kunren[i]
  i += 1
end
