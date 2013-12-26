filebot -script fn:replace --filter "[.](srt|sub|ass)$" --def "e=^(.+)([.]\w+)([.]\w+)$" "r=$1$3" %*
