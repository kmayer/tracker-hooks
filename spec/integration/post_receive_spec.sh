. spec/spec_helper.sh

module post_receive

describe "post_receive integration"

before ()
{
	REPOS_URL="http://repos.example.com/commit/@@REVISION@@"
	TRACKER_TOKEN=${TRACKER_TOKEN:-"let-me-in"}
	TRACKER_HOOKS=`pwd`
	TRACKER_STORY=${TRACKER_STORY:-"40639197"}
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
	git commit -m "Initial commit [#${TRACKER_STORY}]"
	echo "file" > file2
	git add file2
	git commit -m "Second commit [#${TRACKER_STORY}]"
	echo "changed" > file1
	git add file1
	git commit -m "Third commit [#${TRACKER_STORY}]"

	remote_repos=$test_root/remote
	mkdir -p $remote_repos
	pushd $remote_repos
	git init --bare .
	curls=$test_root/curls
	cat < /dev/null > $curls
	cat > hooks/post-receive <<-SH
	#!/bin/sh
	export TRACKER_TOKEN=${TRACKER_TOKEN}
	SH
	
	if test "$TRACKER_TOKEN" = "let-me-in"; then
		cat >> hooks/post-receive <<-SH
		curl () {
			echo "curl \$@" >> ${curls}
		}
		SH
	fi
	
	cat >> hooks/post-receive <<-SH	
	. $TRACKER_HOOKS/lib/post_receive.sh
	post_receive
	SH
	
	chmod +x hooks/post-receive
	popd

	git remote add origin $remote_repos
	git push origin master
	
	git rm file1
	git commit -am "Fourth commit [#${TRACKER_STORY}]"
	
	git rm file2
	git commit -am "Fifth commit [#${TRACKER_STORY}]"
	git push origin master
	
	if test "$TRACKER_TOKEN" = "let-me-in"; then
		git rev-list --reverse HEAD > $test_root/rev-list
		awk '{print $4}' < $curls > $test_root/curl_count
		cmp $test_root/rev-list $test_root/curl_count
	else
		echo "YOU SHOULD CHECK ON TRACKER TO SEE IF THE POSTS MADE IT"
	fi
}