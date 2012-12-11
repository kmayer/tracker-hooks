post_receive () {
	while read old_rev new_rev refname
	do
		xml_file=`tmp_file`
		log_to_xml "$new_rev" > $xml_file
		curl_to_tracker $xml_file
		rm $xml_file
	done
}

tmp_file () {
	date "+/tmp/$$.%s"
}
git_log_message () {
	git log -1 --format="%B" $1
}

git_log_author () {
	git log -1 --format="%an " $1
}

git_log_url () {
	echo "http://atlas.mobileiron.com/fisheye/changelog/polaris?cs=$1"
}

log_to_xml () {
	revision=$1

	cat <<-SH
<?xml version="1.0" encoding="UTF-8"?>
<source_commit>
  <message>`git_log_message "$revision"`</message>
  <author>`git_log_author "$revision"`</author>
  <commit_id>$revision</commit_id>
  <url>`git_log_url "$revision"`</url>
</source_commit>
SH
}

curl_to_tracker () {
	curl -X POST -H "X-TrackerToken: $TRACKER_TOKEN" -H "Content-type: application/xml" -d @$1 http://www.pivotaltracker.com/services/v3/source_commits
}

