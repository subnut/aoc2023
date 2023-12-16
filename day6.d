import std.algorithm;
import std.array;
import std.range;
import std.stdio;
import std.conv : to;

alias T = long;
alias toT = to!T;

void main() {
	auto input = stdin.byLineCopy.array.filter!(x => x.length);
	"stage1: ".writeln(input.stage1);
	"stage2: ".writeln(input.stage2);
}

auto stage1(R)(R input)
if (isInputRange!(R, string))
	=> input.map!split
		.filter!(x => x.length)
		.map!(x => x.dropOne)
		.map!(map!toT)
		.array.transposed
		.map!Race.map!(x => x.waysToWin)
		.reduce!((a, b) => a * b);

auto stage2(R)(R input)
if (isInputRange!(R, string))
	=> input.map!(x => x.splitter(":"))
		.map!(x => x.dropOne)
		.map!(x => x.front)
		.map!split.map!join.map!toT
		.Race.waysToWin;

struct Race {
	T time, record;
	this(R)(R r) if (isInputRange!(R, T)) {
		time = r.front; r.popFront;
		record = r.front; r.popFront;
	}
	T waysToWin()
		// Mathematically elegant,
		//       but looks ugly in code.
		=> iota(0, (time + 1) / 2)
			.map!(x => x * (time - x))
			.filter!(x => x > record)
			.array.length.toT * 2
		   + ((time % 2 == 0) && ((time / 2) ^^ 2 > record) ? 1 : 0);
}
