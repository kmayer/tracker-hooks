post_receive () {
	xml_file=`tmp_pathname`

	trap "rm -f $xml_file" EXIT

	while read old_rev new_rev refname
	do
		post_git_line_to_tracker $old_rev $new_rev $xml_file || return 1
	done
}

post_git_line_to_tracker ()
{
	if [ -z "$TRACKER_TOKEN" ]
	then
		echo "TRACKER_TOKEN is not defined"
		return 1
	fi

	revisions=`git_revisions $1 $2`
	tmp_xml_file=$3

	for revision in $revisions; do
		log_to_xml $revision > $tmp_xml_file
		curl_to_tracker $tmp_xml_file $revision
	done
}

tmp_pathname ()
{
	date "+/tmp/$$.%s"
}

git_log_message ()
{
	git log -1 --format="%B" $1
}

git_log_author ()
{
	git log -1 --format="%an" $1
}

git_log_url ()
{
	echo $REPOS_URL | sed -e "s|@@REVISION@@|$1|"
}

log_to_xml ()
{
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

curl_to_tracker ()
{
	curl -H "X-Git-Revision: $2" -X POST -H "X-TrackerToken: $TRACKER_TOKEN" -H "Content-type: application/xml" -d @$1 http://www.pivotaltracker.com/services/v3/source_commits
}

git_revisions () {
	oldrev=$(git_rev_parse $1)
	newrev=$(git_rev_parse $2)

	if expr "$oldrev" : '0*$' >/dev/null
	then
		git_rev_list "${newrev}"
	else
		git_rev_list "${oldrev}..${newrev}"
	fi
}

git_rev_list()
{
	git rev-list "$1"
}

git_rev_parse ()
{
	git rev-parse $1
}


