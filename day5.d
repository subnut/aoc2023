import std.algorithm;
import std.range;
import std.stdio;
import std.conv : to;
import std.typecons : Tuple;
import std.string : capitalize;

alias T = long;
alias toT = to!T;

immutable mapnames = "
soil fert water light temp humid loc
".split;

void main() {
	auto seeds = stdin.byLineCopy
		.take(2).array
		.dropBackOne
		.front.split(":")
		.dropOne
		.front.split
		.map!toT;

	auto data = stdin.byLineCopy
		.array.splitter("")
		.filter!(x => x.length)
		.map!dropOne
		.map!(map!splitter)
		.map!(map!(map!toT));

	static foreach(name; mapnames.map!capitalize)
		mixin(name ~ "= data.front.Mapper; data.popFront;");

	"stage1: ".writeln(seeds.stage1);
	"stage2: ".writeln(seeds.stage2);
}

auto stage2(R)(R seeds) if (isInputRange!(R, T)) => seeds.chunks(2).worker;
auto stage1(R)(R seeds) if (isInputRange!(R, T)) => seeds.zip(1.toT.repeat).worker;

auto worker(R)(R input)
if (isInputRange!(ElementType!R, T) || isInputRange!(R, Tuple!(T, T)))
	=> input.map!Range.array.locate.minElement.start;

import std.traits : ReturnType;
static foreach(x; mapnames) {
	mixin("Mapper "~x.capitalize~";");
	mixin("ReturnType!(Mapper.map) "~x~" (X)(X x) => "~x.capitalize~".map(x);");
}
mixin("ReturnType!(Mapper.map) locate (X)(X x) => x."~mapnames.join(".")~";");

struct Range {
	T start, end; // [start, end)
	T len() const => end > start ? end - start : 0;
	this(Tuple!(T, T) t) { t[1] += t[0]; this(t.expand); }
	this(T a, T b) { start = a; end = b; }
	this(R)(R r) if (isInputRange!(R, T)) {
		start = r.front;
		end = r.sum;
	}
	T opCmp(typeof(this) b) const => this.start - b.start;
	typeof(this) opBinary(string _ : "+")(T offset) {
		return typeof(this)(start + offset, end + offset);
	}
}

struct Intersection {
	Range data;
	alias data this;
	bool opCast() const => this.len != 0;
	this(Range a, Range b) {
		start = max(a.start, b.start);
		end = min(a.end, b.end);
	}
}

struct Map {
	T sstart, dstart, len;
	this(R)(R input) if (isInputRange!(R, T)) {
		// maps are like this: dest src len
		static foreach(var; ["dstart", "sstart", "len"])
			mixin(var ~ "= input.front; input.popFront;");
	}
	T opCmp(typeof(this) a) const => this.sstart - a.sstart;
	Range domain() => Range(sstart, sstart + len);
	T offset() => dstart - sstart;
}

struct Mapper {
	Map[] maps;
	this(R)(R r) if (isInputRange!R && isInputRange!(ElementType!R, T)) {
		maps = r.map!Map.array.sort.array;
	}
	import std.traits : isInstanceOf;
	Range[] map(Range[] input) => this.map(input.sort);
	Range[] map(R)(R input) if (isForwardRange!(R, Range)
			&& isInstanceOf!(SortedRange, R)) {
		Range[] output;
		auto maps = this.maps.save;
		auto ref map() => maps.front;
		auto ref current() => input.front;
		while (!input.empty) {
			while (!maps.empty && map.domain.end <= current.start)
				maps.popFront;
			if (maps.empty) {
				output ~= current;
				input.popFront;
				continue;
			}
			while (!input.empty && current.end <= map.domain.start) {
				output ~= current;
				input.popFront;
			} if (input.empty) continue;
			auto intersect = map.domain.Intersection(current);
			if (!intersect) continue;
			if (current.start < intersect.start) {
				output ~= Range(current.start, intersect.start);
				current.start = intersect.start;
			}
			output ~= intersect + map.offset;
			if (current.end > intersect.end) {
				current.start = intersect.end;
				continue;
			}
			input.popFront;
		}
		return output;
	}
}

import std.range.primitives : isForwardRange;
enum bool isForwardRange(R, T) = isInputRange!(R, T)
	&& std.range.primitives.isForwardRange!R;
