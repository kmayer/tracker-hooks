. spec/spec_helper.sh

module post_receive

describe "post_receive"

before (){
	REPOS_URL="http://repos.example.com/commit/@@REVISION@@"
	TRACKER_TOKEN="let-me-in-tracker"
}

it_posts_to_tracker () {
	local CURL_WAS_CALLED
	curl () {
		CURL_WAS_CALLED=$$
	}

	git () {
		echo "$@"
	}

	post_git_line_to_tracker "new-rev" "/tmp/some-tempfile"

	test "$CURL_WAS_CALLED" = $$
}

it_formats_the_repository_url () {
	url=`git_log_url sha`

	test "$url" = "http://repos.example.com/commit/sha"
}

it_returns_empty_string () {
	unset REPOS_URL

	url=`git_log_url sha`

	test -z "$url"
}

it_formats_the_xml () {
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

it_requires_the_tracker_api_token () {
	unset TRACKER_TOKEN
	local CURL_WAS_CALLED
	curl () {
		CURL_WAS_CALLED=$$
	}

	git () {
		exit -127 # should not happen
	}

	post_git_line_to_tracker "new-rev" "/tmp/some-tempfile" || :

	test "$CURL_WAS_CALLED" = ""
}
