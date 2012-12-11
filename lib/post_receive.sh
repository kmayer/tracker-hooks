post_receive () {
	while read old_rev new_rev refname
	do
		message=`git_log_message "$new_rev"`
		author=`git_log_author "$new_rev"`
		url=`git_log_url "$new_rev"`
		log_to_xml "$message" "$author" "$new_rev" "$url"
	done
}

git_log_message () {
	git log -1 --format="%B" $1
}

git_log_author () {
	git log -1 --format="Commited by %an" $1
}

git_log_url () {
	"http://example.com/project/commites/$1"
}

log_to_xml () {
	sed <<-SH
<source_commit>
  <message>@@MESSAGE@@</message>
  <author>@@AUTHOR@@</author>
  <commit_id>@@REVISION@@</commit_id>
  <url>@@URL@@</url>
</source_commit>
	SH
}

# Commit by Fiona Tay & Sarah Chandler
# Indicate in deltas when a person's person-range comes to an end [Finishes #35267257]
# https://github.com/pivotalprivate/allocations/commit/425cef31d5f75354bf6249e768bc25a7465726c5

# curl -H "X-TrackerToken: $TOKEN" -X POST -H "Content-type: application/xml" \
#     -d "<source_commit><message>$MESSAGE</message><author>$AUTHOR</author><commit_id>$REVISION</commit_id><url>$URL</url></source_commit>" \
#     http://www.pivotaltracker.com/services/v3/source_commits

# <source_commit>
#   <message>@@MESSAGE@@</message>
#   <author>@@AUTHOR@@</author>
#   <commit_id>@@REVISION@@</commit_id>
#   <url>@@URL@@</url>
# </source_commit>