pub extern fn XReboot() void;

/// Retrieves information persisted by the process that launched the current XBE.
///
/// launchDataType will (likely) be one of the LDT_* defines in xboxkrnl.h
///
/// Returns non-zero in the case of failure.
pub extern fn XGetLaunchInfo(launchDataType: *c_ulong, launchData: [*c][*c]const u8) c_int;

/// Launches an XBE.  Examples of xbePath might be:
///
///   c:\\blah.xbe
///
///   c:/foo/bar.xbe
///
/// If the XBE is able to be launched, this method will
/// not return. If there is a problem, then it returns.
pub extern fn XLaunchXBE(xbePath: [*c]const u8) void;

/// Launches an XBE and sets the LAUNCH_DATA_PAGE's LaunchData, which is
/// retrievable by the newly launched process.
///
/// Examples of xbePath might be:
///
///   c:\\blah.xbe
///
///   c:/foo/bar.xbe
///
/// If the XBE is able to be launched, this method will
/// not return. If there is a problem, then it returns.
pub extern fn XLaunchXBEEx(xbePath: [*c]const u8, launchData: *const anyopaque) void;
