. spec/spec_helper.sh

module post_receive

describe "post_receive"

before ()
{
	REPOS_URL="http://repos.example.com/commit/@@REVISION@@"
	TRACKER_TOKEN="let-me-in-tracker"
}

it_posts_to_tracker ()
{
	trap "rm -f /tmp/some-tempfile" EXIT
	
	local curl_was_called
	curl () {
		curl_was_called=$2
	}

	git () {
		echo "$@"
	}

	git_revisions () {
		echo $2
	}

	post_git_line_to_tracker "old-rev" "new-rev" "/tmp/some-tempfile"
	
	test "$curl_was_called" = "X-Git-Revision: new-rev"
}

it_requires_the_tracker_api_token ()
{
	trap "rm -f /tmp/some-tempfile" EXIT

	unset TRACKER_TOKEN
	local curl_was_called
	curl () {
		curl_was_called=$$
	}

	git () {
		exit -127 # should not happen
	}

	post_git_line_to_tracker "new-rev" "/tmp/some-tempfile" || :

	test -z "$curl_was_called"
}

it_git_log_url_formats_the_repository_url ()
{
	url=`git_log_url sha`

	test "$url" = "http://repos.example.com/commit/sha"
}

it_git_log_url_returns_empty_string_for_url ()
{
	unset REPOS_URL

	url=`git_log_url sha`

	test -z "$url"
}

it_log_to_xml_formats_the_xml ()
{
	git_log_message () {
		echo "message"
	}
	git_log_author () {
		echo "author"
	}

	xml=`log_to_xml sha`

	test "$xml" = '<?xml version="1.0" encoding="UTF-8"?>
<source_commit>
  <message>message</message>
  <author>author</author>
  <commit_id>sha</commit_id>
  <url>http://repos.example.com/commit/sha</url>
</source_commit>'
}

it_git_revisions_returns_the_revision_list ()
{
	git_rev_list() {
		test "$1" = "--reverse"
		test "$2" = "old-rev..new-rev"
	}
	git_rev_parse() {
		echo "$1"
	}
	git_revisions "old-rev" "new-rev"
}

it_git_revisions_returns_the_revision_list_for_new_repos ()
{
	git_rev_list () {
		test "$1" = "--reverse"
		test "$2" = "new-rev"
	}
	git_rev_parse () {
		echo "$1"
	}
	git_revisions "00000" "new-rev"
}
