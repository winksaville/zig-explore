// Actor dispatcher

const ActorPtr = @import("actor.zig").ActorPtr;

pub fn ActorDispatcher(comptime maxActors: usize) type {
    return struct {
        const Self = this;

        pub actors_count: usize,
        pub actors: [maxActors]ActorPtr,

        pub fn init() Self {
            return Self {
                .actors_count = 0,
                .actors = undefined,
            };
        }

        /// NOT thread safe
        pub fn add(self: *Self, actorPtr: var) !void {
            if (self.actors_count >= self.actors.len) return error.TooManyActors;
            self.actors[self.actors_count] = @ptrCast(ActorPtr, actorPtr);
            self.actors_count += 1;
        }

        pub fn loop(self: *Self) {
            while (true) {
                for (actors) |actor| {
                    actor.handleMessage(msg);
                }
            }
        }
    };
}

