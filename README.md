# Tracker Hooks

This library is a collection (so far, just one, post-receive) to help integrate a `git` repository with Pivotal Tracker.

Tracker API: [https://www.pivotaltracker.com/help/api#scm_post_commit](https://www.pivotaltracker.com/help/api#scm_post_commit)

## Installation

1. Anywhere

    ```sh```
    git clone git://github.com/kmayer/tracker-hooks.git
		
2. In your git repository's hook directory (i.e. `.git/hooks`)
    
    ```sh```
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

I use [roundup](https://github.com/ohrite/roundup) for testing:

    git submodule init
    git submodule update
    gem install bundler
    bundle
    vendor/roundup/roundup.sh

Will run the test suite.
  
There is a [guard](http://github.com/hawx/guard-shell) file, too.
  
### Integration Testing
  
There's an integration test that will create a local & remote repository, and confirm that the commits were sent to pivotaltracker.com in the proper order.
  
If you set:
  
    TRACKER_TOKEN
    #and optionally
    TRACKER_STORY
  
To your Pivotal Tracker API token and a test story, respectively, then you will see the test commits post updates to the story.

## Contributing

1. Fork on github
2. Branch
3. Write tests & code
5. Push to github
6. Pull request

