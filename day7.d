import std.algorithm;
import std.range;
import std.stdio;
import std.conv : to;
import std.typecons : Tuple;

void main() {
	auto input = stdin.byLineCopy
		.filter!(x => x.length)
		.array;

	"stage1: ".writeln(input.stage1);
	"stage2: ".writeln(input.stage2);
}

auto stage1(string[] input) => input.map!split.map!(x => Tuple!(Hand,      int)(x[0].Hand,      x[1].to!int)).worker;
auto stage2(string[] input) => input.map!split.map!(x => Tuple!(JokerHand, int)(x[0].JokerHand, x[1].to!int)).worker;

auto worker(R)(R input)
	=> input.array.sort!"a[0].type < b[0].type".groupBy
		.map!(x => x.array.sort!"a[0] < b[0]").join
		.enumerate(1).map!(x => x[0] * x[1][1])
		.sum;

// Weaker hands have lower index
enum HandType {
	HighCard,
	OnePair,
	TwoPair,
	ThreeOfKind,
	FullHouse,
	FourOfKind,
	FiveOfKind,
}

// Weaker cards have lower index
immutable cards =	"23456789TJQKA";
immutable jokercards =	"J23456789TQKA";










// ~~~~codegen~~~~ //
// here be dragons //

static foreach(x; [["CardEnum", cards], ["JokerCardEnum", jokercards]])
	mixin("enum "~x[0]~" { "
		~ zip('_'.repeat, x[1])
		.map!array.map!(y => y ~ ",")
		.join.to!string ~ " }");

import std.string : l = toLower;
static foreach(x; ["", "Joker"]) mixin(`
struct `~x~`Card {
	`~x~`CardEnum card;
	alias card this;
	this(typeof(card) x) { card = x; }
	this(dchar c) {
		import std.string : indexOf;
		card = `~x.l~`cards.indexOf(c).to!(typeof(card));
	}
	string toString() const
		=> [`~x.l~`cards[card]];
}`);

static foreach(x; ["", "Joker"]) mixin(`
struct `~x~`Hand {
	`~x~`Card[] hand;
	HandType type;
	alias hand this;
	string toString() const
		=> hand.array.map!(x => x.toString).join;
	this(string s) {
		auto cards = s.map!`~x~`Card.tee!(x => this.hand ~= x).array.sort.uniq.array;
		auto hand = this.hand.array; // This line must be below the above line.
` ~
(x.length ?  // Joker specific
`		if (hand.count(`~x~`CardEnum._J) && cards.length != 1) {	// avoid JJJJJ
			cards = cards.filter!(x => x != `~x~`CardEnum._J).array;
			hand = hand.replace(`~x~`CardEnum._J.`~x~`Card,
					hand.filter!(x => x != `~x~`CardEnum._J.`~x~`Card)
					.map!(x => [x, hand.count(x)])
					.array.sort!"a[1] > b[1]"
					.front.front.to!`~x~`CardEnum.`~x~`Card).array;
		}
`:``) ~
`		final switch(cards.length) {
			case 1: type = HandType.FiveOfKind;	break;
			case 5: type = HandType.HighCard;	break;
			case 4: type = HandType.OnePair;	break;
			case 2, 3:
			final switch (cards.map!(x => hand.count(x)).array.sort.map!(to!string).join) {
				case "23": type = HandType.FullHouse; break;
				case "14": type = HandType.FourOfKind; break;
				case "113": type = HandType.ThreeOfKind; break;
				case "122": type = HandType.TwoPair; break;
			} break;
		}
	}
}
`);
