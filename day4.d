import std.range : isInputRange;
import std.algorithm : map, sum, filter;

auto stage1(R)(R input) if (isInputRange!R) {
	import std.math : pow;
	return input
		.filter!(x => x > 0)
		.map!(x => pow(2, x-1))
		.sum;
}

auto stage2(R)(R input) if (isInputRange!R) {
	int[] count = new int[input.length];
	count[] = 1;	// Set all fields to 1
	foreach (i, n; input)
		foreach (x; 0 .. n)
			count[i + x+1] += count[i];
	return count.sum;
}

void main() {
	import std.range : dropOne, front, tail, zip;
	import std.algorithm.iteration : splitter;
	import std.algorithm.searching : count;
	import std.stdio : stdin, writeln;
	import std.conv : to;

	import std.array : array;
	auto data = stdin.byLineCopy
		.filter!(x => x.length > 0)
		.map!(x => x.splitter(":").dropOne.front)
		.map!(x => x.splitter("|"))
		.map!(x => x.map!(splitter))
		.map!(map!(map!(to!int)))
		.map!(x => (x.front.map!(y => x.tail(1).front.count(y))))
		.map!(sum)
		.array;

	writeln("stage1: ", data.stage1);
	writeln("stage2: ", data.stage2);
}
