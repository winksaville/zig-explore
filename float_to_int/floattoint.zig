var result: bool = undefined;
var vF32: f32 = 1;

export fn floatToInt() bool {
    const pResult: *volatile bool = &result;
    const pvF32: *volatile f32 = &vF32;

    pResult.* = @floatToInt(u1, pvF32.*) == 1;
    pResult.* = @floatToInt(u1, pvF32.*) == 0;
    
    return pResult.*;
} 
