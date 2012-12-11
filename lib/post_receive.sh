post_receive () {
	while read old_rev new_rev refname
	do
		xml_file=`tmp_file`
		log_to_xml "$new_rev" > $xml_file
		curl_to_tracker $xml_file
		# rm $xml_file
	done
}

tmp_file () {
	date "+/tmp/$$.%s"
}
git_log_message () {
	git log -1 --format="%B" $1
}

git_log_author () {
	git log -1 --format="Commited by %an" $1
}

git_log_url () {
	echo "http://example.com/project/commits/$1"
}

log_to_xml () {
	revision=$1
	message=`git_log_message "$revision"`
	author=`git_log_author "$revision"`
	url=`git_log_url "$revision"`

	sed -e "s%@@MESSAGE@@%$message%" \
			-e "s%@@AUTHOR@@%$author%" \
			-e "s%@@REVISION@@%$revision%" \
			-e "s%@@URL@@%$url%"<<-SH
<?xml version="1.0" encoding="UTF-8"?>
<source_commit>
  <message>@@MESSAGE@@</message>
  <author>@@AUTHOR@@</author>
  <commit_id>@@REVISION@@</commit_id>
  <url>@@URL@@</url>
</source_commit>
SH
}

curl_to_tracker () {
	curl -X POST -H "X-TrackerToken: $TRACKER_TOKEN" -H "Content-type: application/xml" -d @$1 http://www.pivotaltracker.com/services/v3/source_commits
}

