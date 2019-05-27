const std = @import("std");

const allocator = @import("./main.zig").allocator;

const VM = @import("vm.zig").VM;
const Value = @import("value.zig").Value;

extern var vm: *VM;

pub const ObjType = enum {
    String
};

pub const ObjString = struct {
    bytes: []const u8,
    hash: u32,

    pub fn copy(bytes: []const u8) *Obj {
        const hash = hashFn(bytes);

        const interned = vm.strings.get(bytes);
        if (interned) |s| return s.value;

        const heapChars = allocator.alloc(u8, bytes.len) catch unreachable;
        std.mem.copy(u8, heapChars, bytes);

        return allocate(heapChars, hash);
    }

    pub fn take(bytes: []const u8) *Obj {
        const hash = hashFn(bytes);
        
        const interned = vm.strings.get(bytes);
        if (interned) |s| {
            allocator.free(bytes);
            return s.value;
        }

        return allocate(bytes, hash);
    }

    pub fn allocate(bytes: []const u8, hash: u32) *Obj {
        const string = Obj.allocate();
        string.data = Obj.Data { 
            .String = ObjString {
                .bytes = bytes, 
                .hash = hash
            }
        };
        _ = vm.strings.put(bytes, string) catch unreachable;
        return string;
    }

    pub fn eqlFn(a: []const u8, b: []const u8) bool {
        return std.mem.eql(u8, a, b);
    }

    pub fn hashFn(key: []const u8) u32 {
        var hash: u32 = 2166136261;
        var i: u32 = 0;
        while(i < key.len) : (i += 1) {
            hash ^= key[i];
            hash *%= 16777619;
        }
        return hash;
    }
};

pub const ObjFn = struct {

};

pub const Obj = struct {
    data: Data,
    next: ?*Obj,

    pub const Data = union(ObjType) {
        String: ObjString,
    };

    pub fn value(self: *Obj) Value {
        return Value { .Obj = self };
    }

    pub fn toString(self: Obj) []const u8 {
        switch(self.data) {
            .String => |s| return s.bytes,
        }
    }

    fn equal(self: *Obj, other: *Obj) bool {
        switch(self.data) {
            .String => |s| return self == other,
        }
    }
    
    fn allocate() *Obj {
        var object = allocator.create(Obj) catch unreachable;
        object.* = Obj {
            .data = undefined,
            .next = vm.objects,
        };
        vm.objects = object;
        return object;
    }

    pub fn free(self: *Obj) void {
        switch (self.data) {
            .String => |s| {
                allocator.free(s.bytes);
                allocator.destroy(self);
            }
        }
    }
};


