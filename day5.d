import std.stdio;
import std.conv : to;
import std.algorithm;
import std.range;

alias T = long;
alias toT = to!T;

void main() {
	auto seeds = stdin.byLineCopy
		.takeOne.front
		.splitter.dropOne
		.map!toT
		.array;

	import std.array;
	maps = stdin.byLineCopy
			.array
			.splitter("")
			.filter!(x => x.length)
			.map!(x => x.dropOne)
			.map!(map!splitter)
			.map!(map!(map!toT))
			.Maps;

	writeln("stage 1: ", seeds.map!locate.minElement);
}


mixin("auto locate(T x) => seed(x)." ~ fields.join(".") ~ ";");
static immutable fields = ["soil", "fert", "water", "light", "temp", "humid", "loc"];
struct seed { T val; alias val this; this(T v) { val = v; } }
static foreach(i, x; ["seed"] ~ fields[0 .. $-1])
	mixin("struct "~fields[i]~" { "~x~" v; alias v this; this("~x~" s) { val = maps._"~fields[i]~".getDest(s.val); } }");


Maps maps;
struct Maps {
private:
	this(R)(R data) if (isInputRange!R) {
		static foreach(x; fields)
			mixin("this._"~x~" = Map(data.front); data.popFront;");
	}
	struct Map {
		T[] sinks;
		T[2][] srcs;
		this(R)(R data) if (isInputRange!R) {
			foreach (x; data) {
				this.sinks ~= x.front; x.popFront;
				this.srcs ~= [x.front, x.sum];
			}
		}
		T getDest(T src) {
			foreach (i, p; this.srcs)
				if (src >= p[0] && src < p[1])
					return sinks[i] + (src - p[0]);
			return src;
		}
	}
	static foreach(x; fields)
		mixin("Map _"~x~";");
}
