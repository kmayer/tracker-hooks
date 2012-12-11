post_receive () {
	xml_file=`tmp_file`
	while read old_rev new_rev refname
	do
		post_git_line_to_tracker $new_rev $xml_file || return 1
	done
	rm $xml_file
}

post_git_line_to_tracker () {
	if [ -z "$TRACKER_TOKEN" ]
	then
		echo "You are missing a tracker token"
		return 1
	fi
	log_to_xml "$1" > $2
	curl_to_tracker $2
}

tmp_file () {
	date "+/tmp/$$.%s"
}

git_log_message () {
	git log -1 --format="%B" $1
}

git_log_author () {
	git log -1 --format="%an" $1
}

git_log_url () {
	echo $REPOS_URL | sed -e "s|@@REVISION@@|$1|"
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

