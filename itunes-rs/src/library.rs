use std::ptr;

use cocoa::base::{id, class};
use cocoa::foundation::NSString;

#[link(name = "iTunesLibrary", kind = "framework")]
extern {
    pub static ITLibMediaEntityPropertyPersistentID: id; // something to link
}

pub trait ITLibrary {
    unsafe fn libraryWithAPIVersion(_: Self, version: id, error: *mut id) -> id {
        msg_send![class("ITLibrary"), libraryWithAPIVersion:version error:error]
    }
}

impl ITLibrary for id {}

#[test]
fn test_library_init() {
    use cocoa::base::nil;
    unsafe {

        let library_version = NSString::alloc(nil).init_str("1.0");
        let error: id = ptr::null_mut();
        let library = ITLibrary::libraryWithAPIVersion(nil, library_version, &error as *mut id);


    }
}
