const std = @import("std");
const testing = std.testing;

const ace = @cImport({
    @cInclude("ace_eval.h");
});

pub const HandEvaluator = struct {
    const Self = @This();
    const deck_size = 52;

    pub fn init(allocator: std.mem.Allocator) !Self {
        const deck = try allocator.alloc(ace.Card, deck_size);
        for (0..deck_size) |i| {
            deck[i] = ace.ACE_makecard(@intCast(i));
        }
        return Self{ ._deck = deck, ._allocator = allocator };
    }

    pub fn deinit(self: *Self) void {
        self._allocator.free(self._deck);
    }

    pub fn eval(self: *const Self, card1: u8, card2: u8, card3: u8, card4: u8, card5: u8, card6: u8, card7: u8) u32 {
        var cards: [7]ace.Card = std.mem.zeroes([7]ace.Card);
        ACE_addcard(&cards, self._deck[card1]);
        ACE_addcard(&cards, self._deck[card2]);
        ACE_addcard(&cards, self._deck[card3]);
        ACE_addcard(&cards, self._deck[card4]);
        ACE_addcard(&cards, self._deck[card5]);
        ACE_addcard(&cards, self._deck[card6]);
        ACE_addcard(&cards, self._deck[card7]);
        return ace.E(&cards);
    }

    //Zig can't handle this macro
    fn ACE_addcard(h: []u32, c: u32) void {
        h[c & 7] += c;
        h[3] |= c;
    }

    _deck: []ace.Card,
    _allocator: std.mem.Allocator,
};

test "royal flush eval" {
    var hand_evaluator = try HandEvaluator.init(std.testing.allocator);
    defer hand_evaluator.deinit();
    const val = hand_evaluator.eval(12, 11, 10, 9, 8, 14, 22);
    try std.testing.expectEqual(9, ace.ACE_rank(val));
}
