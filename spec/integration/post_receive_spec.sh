. spec/spec_helper.sh

module post_receive

describe "post_receive integration"

before ()
{
	REPOS_URL="http://repos.example.com/commit/@@REVISION@@"
	TRACKER_TOKEN="let-me-in-tracker"
	TRACKER_HOOKS=`pwd`
}

it_sends_a_commit_post_for_each_revision ()
{
	test_root=`tmp_pathname`

	trap "rm -rf $test_root" EXIT

	local_repos=$test_root/local
	mkdir -p $local_repos
	pushd $local_repos
	git init .
	echo "file" > file1
	git add file1
	git commit -m 'Initial commit'
	echo "file" > file2
	git add file2
	git commit -m 'Second commit'
	echo "changed" > file1
	git add file1
	git commit -m 'Third commit'

	remote_repos=$test_root/remote
	mkdir -p $remote_repos
	pushd $remote_repos
	git init --bare .
	curl_count=$test_root/curls
	cat < /dev/null > $curl_count
	cat > hooks/post-receive <<-SH
	#!/bin/sh
	export TRACKER_TOKEN=let-me-in
	curl () {
		echo "curl \$@" >> ${curl_count}
	}
	. $TRACKER_HOOKS/lib/post_receive.sh
	post_receive
	SH
	chmod +x hooks/post-receive
	popd

	git remote add origin $remote_repos
	git push origin master

	expr "`wc -l $curl_count`" : " *3 $curl_count"
}