import std.conv : to;
import std.array : array;
import std.string : tr, format;
import std.stdio : stdin, writeln;
import std.algorithm : map, sum, filter, reverse;

int stage1(string[] input) {
	return input
		.map!(x => x.tr("abcdefghijklmnopqrstuvwxyz", "", "d"))
		.map!(x => format("%c%c", x[0], x[$-1]))
		.map!(to!int)
		.sum;
}

int stage2(string[] input) {
	return input
		.map!(x => x.sub ~ x.revsub)
		.array
		.stage1;
}

void main() {
	auto input = stdin.byLineCopy
		.filter!(x => x.length > 0)
		.array;
	writeln("stage1 ", input.stage1);
	writeln("stage2 ", input.stage2);
}

import std.algorithm.iteration : substitute;
auto sub = (string x) => x.substitute!(
	"one",   "1",
	"two",   "2",
	"three", "3",
	"four",  "4",
	"five",  "5",
	"six",   "6",
	"seven", "7",
	"eight", "8",
	"nine",  "9"
).to!string;
auto revsub = (string x) => x.array.reverse.substitute!(
	"one"	.array.reverse.to!string, "1",
	"two"	.array.reverse.to!string, "2",
	"three"	.array.reverse.to!string, "3",
	"four"	.array.reverse.to!string, "4",
	"five"	.array.reverse.to!string, "5",
	"six"	.array.reverse.to!string, "6",
	"seven"	.array.reverse.to!string, "7",
	"eight"	.array.reverse.to!string, "8",
	"nine"	.array.reverse.to!string, "9"
).array.reverse.to!string;
