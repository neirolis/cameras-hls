#!/bin/sh

# check required environment variables
if [ -z ${RTMIPDIR} ]; then
  >&2 echo "RTMIPDIR not specified" 
  exit 1
fi
if [ -z ${VIDEODIR} ]; then
  >&2 echo "VIDEODIR not specified" 
  exit 1
fi
if [ -z ${CAMERANAME} ]; then
  >&2 echo "CAMERANAME not specified" 
  exit 1
fi


# default variables
framerate=5
quality=3


# parse arguments
args=("$@")
for (( i=1; i<=${#args[@]}; i+=2 )); do
    case ${args[$i]} in
      --framerate)
      framerate=${args[$i+1]}
      ;;
    esac
done

# prepare directory
rm -f $RTMIPDIR/$VIDEODIR/$CAMERANAME/*
mkdir -p $RTMIPDIR/$VIDEODIR/$CAMERANAME/


# start
$RTMIPDIR/ffmpeg -hide_banner -fflags nobuffer \
 -fflags discardcorrupt \
 -loglevel level+info \
 -timeout 5000000 \
 -rtsp_transport tcp \
 -i $1\
 -c:v mjpeg \
 -huffman optimal \
 -q:v $quality \
 -vf fps=$framerate,realtime \
 -f image2pipe \
 - \
 -an \
 -vsync 0 \
 -copyts \
 -vcodec copy \
 -movflags frag_keyframe+empty_moov \
 -hls_flags delete_segments+append_list \
 -f segment \
 -remove_at_exit 1 \
 -segment_wrap 10 \
 -segment_list_flags live \
 -segment_time 0.5 \
 -segment_list_size 2 \
 -segment_format mpegts \
 -segment_list $RTMIPDIR/$VIDEODIR/$CAMERANAME/index.m3u8 \
 -segment_list_type m3u8 \
 -segment_list_entry_prefix /$VIDEODIR/$CAMERANAME/ \
 $RTMIPDIR/$VIDEODIR/$CAMERANAME/%3d.ts