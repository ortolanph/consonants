const std = @import("std");
const Allocator = std.mem.Allocator;

fn isConsonant(c: u8) bool {
    if (!std.ascii.isAlphabetic(c)) return false;
    return switch (std.ascii.toLower(c)) {
        'a', 'e', 'i', 'o', 'u' => false,
        else => true,
    };
}

/// Returns a newly allocated string with only the uppercase consonants of `input`.
/// Digits, punctuation, whitespace and non-ASCII bytes are dropped.
/// Caller owns the returned slice.
pub fn onlyConsonants(allocator: Allocator, input: []const u8) ![]u8 {
    // Pass 1: count, so we allocate exactly once.
    var n: usize = 0;
    for (input) |c| {
        if (isConsonant(c)) n += 1;
    }

    // Pass 2: fill.
    const out = try allocator.alloc(u8, n);
    var i: usize = 0;
    for (input) |c| {
        if (isConsonant(c)) {
            out[i] = std.ascii.toUpper(c);
            i += 1;
        }
    }
    return out;
}

test "removes vowels, punctuation and uppercases" {
    const allocator = std.testing.allocator;

    const r = try onlyConsonants(allocator, "Hello, World!");
    defer allocator.free(r);
    try std.testing.expectEqualStrings("HLLWRLD", r);
}

test "handles special characters and digits" {
    const allocator = std.testing.allocator;

    const r = try onlyConsonants(allocator, "Zig-lang: 100% fun! #@$");
    defer allocator.free(r);
    try std.testing.expectEqualStrings("ZGLNGFN", r);
}

test "empty and vowel-only inputs give an empty string" {
    const allocator = std.testing.allocator;

    const a = try onlyConsonants(allocator, "");
    defer allocator.free(a);
    try std.testing.expectEqualStrings("", a);

    const b = try onlyConsonants(allocator, "aeiouAEIOU!!!");
    defer allocator.free(b);
    try std.testing.expectEqualStrings("", b);
}