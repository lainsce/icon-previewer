namespace IconPreview {
	/**
	 * Get a random selection of an array
	 *
	 * If the input is smaller than the expected output then
	 * the result will contain duplicate elements
	 */
	public string[] random_selection (string[] input, int len) ensures (result.length == len) {
		var selection = new string[len];
		var end = (int32) input.length;
		var require_unique = end >= len;
		var i = 0;
		while (i < len) {
			var pos = Random.int_range (0, end);
			var proposed = input[pos];
			if (proposed in selection && require_unique) {
				continue;
			}
			selection[i] = proposed;
			i++;
		}
		return selection;
	}
}
