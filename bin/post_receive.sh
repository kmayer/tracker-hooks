if [ -z "$TRACKER_HOOKS" ]
then
  TRACKER_HOOKS=`cd $(dirname $0)/.. && pwd`
fi

. $TRACKER_HOOKS/lib/post_receive.sh

post_receive