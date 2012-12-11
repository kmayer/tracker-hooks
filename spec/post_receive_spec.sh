. spec/spec_helper.sh

module post_receive

describe "post_receive"

it_reads_each_row_from_standard_input () {
	cat sample_data | post_receive
	test $? = 0
}

it_posts_to_tracker () {
	local tracker_ref
	echo "empty" "8627db4" "refs/heads/master" | post_receive
}