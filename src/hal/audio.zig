/// This is the signature for the function that the audio
/// subsystem will call back to when it has run out of data
pub const XAudioCallback = ?*const fn (pac97Device: ?*anyopaque, data: ?*anyopaque) callconv(.c) void;

/// buffer descriptor from AC97 specification
pub const AC97_DESCRIPTOR = extern struct {
    bufferStartAddress: c_uint,
    bufferLengthInSamples: c_ushort, // 0=no smaples
    bufferControl: c_ushort, // b15=1=issue IRQ on completion, b14=1=last in stream
};

/// represents the current ac97 device
pub const AC97_DEVICE = extern struct {
    pcmSpdifDescriptor: [32]AC97_DESCRIPTOR,
    pcmOutDescriptor: [32]AC97_DESCRIPTOR,
    mmio: ?*volatile c_uint,
    nextDescriptor: u8,
    callback: XAudioCallback,
    callbackData: ?*anyopaque,
    sampleSizeInBits: c_int,
    numChannels: c_int,
};

/// The XAudio API is only supposed to be used as a backend. Using SDL2 for
/// audio playback should be preferred for applications.
///
/// Note that currently `sampleSizeInBits` and `numChannels` are ignored. Both
/// are provided to cope with future enhancements. Currently supported samples
/// are 16 bit, 2 channels (stereo)
pub extern fn XAudioInit(sampleSizeInBits: c_int, numChannels: c_int, callback: XAudioCallback, data: ?*anyopaque) void;
pub extern fn XAudioPlay() void;
pub extern fn XAudioPause() void;
pub extern fn XAudioProvideSamples(buffer: [*c]u8, bufferLength: c_ushort, isFinal: c_int) void;
