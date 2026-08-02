#[macro_export]
macro_rules! debug {
    ($fmt:expr $(, $arg:expr)*) => {
        $crate::println!(concat!("[DEBUG] \t", $fmt) $(, $arg)*);
    };
}

#[macro_export]
macro_rules! log {
    ($fmt:expr $(, $arg:expr)*) => {
        $crate::println!(concat!("[LOG] \t", $fmt) $(, $arg)*);
    };
}

#[macro_export]
macro_rules! info {
    ($fmt:expr $(, $arg:expr)*) => {
        $crate::println!(concat!("[INFO] \t\t", $fmt) $(, $arg)*);
    };
}

#[macro_export]
macro_rules! error {
    ($fmt:expr $(, $arg:expr)*) => {
        $crate::println!(concat!("[ERROR] \t", $fmt) $(, $arg)*);
    };
}

#[macro_export]
macro_rules! warn {
    ($fmt:expr $(, $arg:expr)*) => {
        $crate::println!(concat!("[WARN] \t", $fmt) $(, $arg)*);
    };
}
