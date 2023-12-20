import std.algorithm;
import std.range;
import std.stdio;
import std.string;
import std.conv : to;
import std.typecons: tuple;

auto LR(string s)
	=> s.repeat.joiner.substitute('L', 0, 'R', 1);

void main() {
	auto firstLine = stdin.readln.chomp;
	auto LR = firstLine.LR;
	auto data = stdin.byLineCopy
		.map!chomp.filter!(x => x.length)
		.map!(x => x.tr("( )", "", "d").split("="))
		.map!(x => tuple(x[0], x[1].split(",")));

	int steps;
	string[2][string] db;
	foreach (x, y; data)
		db[x] = [y[0], y[1]];

	"# stage1".dwriteln;
	steps = 0; LR = firstLine.LR;
	for (string cur = "AAA"; cur != "ZZZ"; steps++) {
		cur.dwrite(" -> ");
		cur = db[cur][LR.front];
		cur.dwriteln; LR.popFront;
	}
	"steps: ".dwriteln(steps);
	"stage1: ".writeln(steps);
	dwriteln;

	return;
	// Current stage2 code runs forever
	// Needs optimization

	"# stage2".dwriteln;
	steps = 0; LR = firstLine.LR;
	for({auto walker = db.keys.filter!(x => x.endsWith('A')).array; walker.dwriteln;}
			walker.map!(x => !x.endsWith('Z')).reduce!"a || b"; steps++, walker.dwriteln, LR.popFront)
		foreach (i, cur; walker)
			walker[i] = db[cur][LR.front];
	"steps: ".dwriteln(steps);
	"stage2: ".writeln(steps);
	dwriteln;
}

debug {
	void dwrite(T...)(T args) => write(args);
	void dwriteln(T...)(T args) => writeln(args);
} else {
	void dwrite(T...)(T _) {}
	void dwriteln(T...)(T _) {}
}
