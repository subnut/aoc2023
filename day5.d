import std.stdio;
import std.range;
import std.algorithm;
import std.conv : to;
import std.string : capitalize;

alias T = long;
alias toT = to!T;

T stage1(T[] seeds)
	=> seeds.zip(1L.repeat)
		.map!array
		.Ranges
		.locate
		.map!(x => x.start)
		.minElement;

T stage2(T[] seeds)	// FIXME: broken.
	=> seeds.chunks(2)
		.Ranges
		.locate
		.map!(x => x.start)
		.minElement;

void main() {
	auto seeds = stdin.byLineCopy
		.takeOne.front
		.splitter.dropOne
		.map!toT
		.array;

	auto data = stdin.byLineCopy
		.array
		.splitter("")
		.filter!(x => x.length)
		.map!(x => x.dropOne)
		.map!(map!splitter)
		.map!(map!(map!toT));

	static foreach(x; fields.map!capitalize)
		mixin(x~"= data.front.Transformer; data.popFront;");

	"stage 1: ".writeln(seeds.stage1);
	"stage 2: ".writeln(seeds.stage2);
}

struct Map {
	T sstart, dstart, len;
	this(R)(R x) if (isInputRange!R) {
		dstart	= x.front; x.popFront;
		sstart	= x.front; x.popFront;
		len	= x.front; x.popFront;
	}
	Range range() => Range(sstart, len);
	T transform() => dstart - sstart;
}
struct Transformer {
	Map[] maps;
	this(R)(R x) if (isInputRange!R) {
		foreach(r; x.map!Map)
			maps ~= r;
	}
	Ranges transform(Ranges ranges) {
		Ranges output;
		foreach (range; ranges) {
			bool intercepted = false;
			foreach (map; maps) {
				if (auto intercept = Intersection(range, map.range)) {
					output ~= Range(intercept.start + map.transform, intercept.len);
					intercepted = true;
					if (intercept.len < range.len) {
						if (range.start < intercept.start)
							output ~= Range(range.start, intercept.start - range.start);
						if (intercept.end < range.end)
							output ~= Range(intercept.end, range.end - intercept.end);
					}
					break;
				}
			}
			if (!intercepted)
				output ~= range;
		}
		return output;
	}
}
struct Range {
	T start, len;
	T end() => start + len;	// non-inclusive
	this(T s, T n) { start = s; len = n; }
	this(R)(R x) if (isInputRange!R) {
		start	= x.front; x.popFront;
		len	= x.front; x.popFront;
	}
}
struct Intersection {
	Range r;
	alias r this;
	bool opCast() const => this.len != 0;
	this(Range a, Range b) {
		start = max(a.start, b.start);
		len = min(a.end, b.end) - start;
		len = len < 0 ? 0 : len;
	}
}
struct Ranges {
	Range[] data;
	alias data this;
	this(R)(R x) if (isInputRange!R) {
		foreach (k; x)
			data ~= Range(k.front, k.dropOne.front);
	}
}


static immutable fields = ["soil", "fert", "water", "light", "temp", "humid", "loc"];
static foreach(x; fields.map!capitalize) mixin("Transformer "~x~";");
static foreach(x; fields) mixin("auto "~x~"(Ranges x) => "~x.capitalize~".transform(x);");
mixin("auto locate(Ranges seeds) => seeds."~fields.join(".")~";");
