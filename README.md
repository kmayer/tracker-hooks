# Tracker Hooks

This library is a collection (so far, just one, post-receive) to help integrate a `git` repository with Pivotal Tracker.

Tracker API: [https://www.pivotaltracker.com/help/api#scm_post_commit](https://www.pivotaltracker.com/help/api#scm_post_commit)

## Installation

Anywhere

	git clone git://github.com/kmayer/tracker-hooks.git
		
In your git repository's hook directory (i.e. `.git/hooks`)

	cat > post-receive <<-SH
	#!/usr/bin/env sh
	
	# REQUIRED
	export TRACKER_TOKEN=<your Pivotal Tracker API token>
	
	# optional
	#   @@REVISION@@ will be replaced with the full git sha
	export REPOS_URL="http://example.com/path/to/your/repos/@@REVISION@@"
	
	exec /the/path/to/tracker-hooks/bin/post-receive
	SH
	
Make sure that `post-receive` is `chmod 0755`

## Testing

	echo "x" `git rev-list -1 HEAD` "refs/heads/master" | ./git/hooks/post-receive

You should see an XML response from the Tracker API. If your latest commit has a Tracker ID (e.g. [#12345]) it will try to post the note to the story.