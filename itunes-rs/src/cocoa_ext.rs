use cocoa::base::{id, class};
use cocoa::foundation::{NSString, NSInteger};

pub trait NSError {
    unsafe fn errorWithDomain_code_userInfo(_: Self, domain: id, code: NSInteger, userInfo: id) -> id {
        msg_send![class("NSError"), errorWithDomain:domain code:code userInfo:userInfo]
    }

    unsafe fn code(self) -> NSInteger;
    unsafe fn domain(self) -> id;
    unsafe fn userInfo(self) -> id;
    unsafe fn localizedDescription(self) -> id;
}

impl NSError for id {
    unsafe fn code(self) -> NSInteger {
        msg_send![self, code]
    }

    unsafe fn domain(self) -> id {
        msg_send![self, domain]
    }

    unsafe fn userInfo(self) -> id {
        msg_send![self, userInfo]
    }

    unsafe fn localizedDescription(self) -> id {
        msg_send![self, localizedDescription]
    }
}

#[test]
fn test_error() {
    use std::ffi::CStr;

    use cocoa::base::nil;
    use cocoa::foundation::NSAutoreleasePool;

    unsafe {
        let _pool = NSAutoreleasePool::new(nil);

        let domain = NSString::alloc(nil).init_str("myDomain");
        let error = NSError::errorWithDomain_code_userInfo(nil, domain, 42, nil);

        assert_eq!(42, error.code());

        let c_domain = CStr::from_ptr(error.domain().UTF8String());
        assert_eq!("myDomain", c_domain.to_string_lossy());
    }
}
